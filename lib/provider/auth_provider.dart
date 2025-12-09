import 'dart:convert';
import 'dart:io';
import 'package:ralpal/network/call_helper.dart';
import 'package:ralpal/network/models/plan_model.dart';
import 'package:ralpal/network/models/subscription_model.dart';
import 'package:ralpal/network/models/user_model.dart';
import 'package:ralpal/network/network_calls/auth_api.dart';
import 'package:ralpal/screen/otp_screen.dart';
import 'package:ralpal/screen/upgrade_dialogue.dart';
import 'package:ralpal/utils/constants.dart';
import 'package:ralpal/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  UserModel user = UserModel(
    id: '',
    name: '',
    email: '',
    phoneNo: '',
    profile: '',
    scans: '0',
  );
  String? _resetEmail; // Store email for password reset flow

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  String? get resetEmail => _resetEmail;
  SubscriptionPlan? _currentSubscriptionPlan;
  List<SubscriptionPlan> _availablePlans = [];
  SubscriptionPlan? get currentSubscriptionPlan => _currentSubscriptionPlan;
  List<SubscriptionPlan> get availablePlans => _availablePlans;
  bool _isProcessingPayment = false;
  String? _paymentError;
  String? _clientSecret;
  String? _paymentIntentId;

  bool get isProcessingPayment => _isProcessingPayment;
  String? get paymentError => _paymentError;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  SubscriptionModel? subscriptionModel;
  Future<ApiResponseWithData> getActiveSubscription() async {
    _setLoading(true);
    String userId = SharedPrefUtil.getValue(userIdPref, '') as String;
    var response = await AuthAPIs().getSubscriptionPlan(userId);
    if (response.success) {
      subscriptionModel = SubscriptionModel.fromJson(response.data['data']);
    }
    _setLoading(false);
    return response;
  }

  Future<bool> createPaymentIntent(String planId) async {
    _setPaymentProcessing(true);
    _setPaymentError(null);

    try {
      final response = await CallHelper().postWithData<Map<String, dynamic>>(
        'api/subscription/create-intent',
        {'planId': planId},
        {},
      );

      _setPaymentProcessing(false);

      if (response.success) {
        _clientSecret = response.data!['data']['clientSecret'];
        _paymentIntentId = response.data!['data']['paymentIntentId'];
        return true;
      } else {
        _setPaymentError(response.message);
        return false;
      }
    } catch (e) {
      _setPaymentProcessing(false);
      _setPaymentError('An error occurred: $e');
      return false;
    }
  }

  Future<bool> processPayment(String planId) async {
    _setPaymentProcessing(true);
    _setPaymentError(null);

    try {
      // First, create payment intent
      final intentCreated = await createPaymentIntent(planId);
      if (!intentCreated || _clientSecret == null) {
        _setPaymentProcessing(false);
        return false;
      }

      // Initialize Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: _clientSecret,
          merchantDisplayName: 'Color Scanner App',
          style: ThemeMode.light,
          // merchantCountryCode: 'US',
        ),
      );

      // Display payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful
      _setPaymentProcessing(false);

      // Update user subscription status
      await _updateSubscriptionStatus(planId);

      return true;
    } catch (e) {
      _setPaymentProcessing(false);
      _setPaymentError('Payment failed: $e');
      return false;
    }
  }

  Future<void> _updateSubscriptionStatus(String planId) async {
    try {
      // Call your backend to confirm subscription
      final response = await CallHelper().postWithData<Map<String, dynamic>>(
        'api/subscription/confirm',
        {'planId': planId, 'paymentIntentId': _paymentIntentId},
        {},
      );

      if (response.success) {
        // Refresh user data to get updated subscription status
        await getUser();
        await getSubscriptionPlan();
      }
    } catch (e) {
      print('Error updating subscription status: $e');
    }
  }

  Future<bool> subscribeToPlan(String planId) async {
    return await processPayment(planId);
  }

  void _setPaymentProcessing(bool processing) {
    _isProcessingPayment = processing;
    notifyListeners();
  }

  Future<bool> increaseScanCount(BuildContext context) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await CallHelper().postWithData<Map<String, dynamic>>(
        'api/scan/free-scan',
        {},
        {},
      );

      _setLoading(false);

      if (response.success) {
        return true;
      } else {
        int scanCount = SharedPrefUtil.getScanCount();
        if (scanCount > 3) {
          Navigator.of(
            // ignore: use_build_context_synchronously
            context,
          ).push(
            MaterialPageRoute(
              builder: (context) => UpgradeDialog(isPlanExpired: true),
            ),
          );
        } else {
          Navigator.of(
            // ignore: use_build_context_synchronously
            context,
          ).push(
            MaterialPageRoute(builder: (context) => const UpgradeDialog()),
          );
        }

        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An error occurred: $e');
      return false;
    }
  }

  void _setPaymentError(String? error) {
    _paymentError = error;
    notifyListeners();
  }

  void clearPaymentError() {
    _paymentError = null;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setResetEmail(String email) {
    _resetEmail = email;
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await CallHelper().post('api/auth/forgot-password', {
        'email': email,
      });

      _setLoading(false);

      if (response.success) {
        _resetEmail = email; // Store email for OTP verification
        return true;
      } else {
        _setError(response.message ?? 'Failed to send reset email');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An error occurred: $e');
      return false;
    }
  }

  Future<bool> updateProfile({required String name, File? imageFile}) async {
    try {
      var uri = Uri.parse("${CallHelper.baseUrl}api/auth/update-profile");
      var request = http.MultipartRequest("PUT", uri);

      request.fields['name'] = name;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("files", imageFile.path),
        );
      }

      String accessToken =
          SharedPrefUtil.getValue(accessTokenPref, "") as String;

      request.headers['Authorization'] = "Bearer ${accessToken}";

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = json.decode(responseData);

        await getUser();
        notifyListeners();

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Update profile error: $e");
      return false;
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await CallHelper().postWithData<Map<String, dynamic>>(
        'api/auth/signup/verify-otp',
        {'email': email, 'otp': otp},
        {},
      );

      _setLoading(false);

      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Invalid OTP');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An error occurred: $e');
      return false;
    }
  }

  Future<bool> getUser() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await CallHelper().getWithData<Map<String, dynamic>>(
        'api/auth/profile',
        {},
      );

      _setLoading(false);

      if (response.success) {
        user = UserModel.fromJson(response.data['data']);
        int count = user.scans.isNotEmpty ? int.parse(user.scans) : 0;
        SharedPrefUtil.setValue(scanCountKey, count);
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An error occurred while fetching user data: $e');
      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await CallHelper().postWithData(
        'api/auth/reset-password',
        {'email': email, 'otp': otp, 'newPassword': newPassword},
        {},
      );

      _setLoading(false);

      if (response.success) {
        _resetEmail = null;
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An error occurred: $e');
      return false;
    }
  }

  Future<bool> getSubscriptionPlan() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await CallHelper().getWithData<Map<String, dynamic>>(
        'api/plan/active',
        {},
      );

      _setLoading(false);

      if (response.success) {
        if (response.data!['data'] is List) {
          _availablePlans = (response.data!['data'] as List)
              .map((planJson) => SubscriptionPlan.fromJson(planJson))
              .toList();
        } else {
          _currentSubscriptionPlan = SubscriptionPlan.fromJson(
            response.data!['data'],
          );
          _availablePlans = [_currentSubscriptionPlan!];
        }
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An error occurred while fetching subscription plans: $e');
      return false;
    }
  }

  // http://localhost:7878/api/auth/forgot-password%27
  Future<bool> resendOTP(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await CallHelper().postWithData<Map<String, dynamic>>(
        'api/auth/forgot-password',
        {'email': email},
        {},
      );

      _setLoading(false);

      if (response.success) {
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An error occurred: $e');
      return false;
    }
  }

  Future<ApiResponseWithData> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    _setLoading(true);
    _setError(null);

    Map<String, dynamic> data = {'email': email, 'password': password};
    try {
      final response = await CallHelper().postWithData<Map<String, dynamic>>(
        'api/auth/login',
        data,
        {},
      );

      _setLoading(false);

      if (response.success) {
        if (response.data['message'] ==
            'Your account is not verified. OTP has been re-sent to your email.') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => OTPScreen(email: email)),
          );
          return response;
        } else {
          await _saveLoginData(response.data['data']);
          _isLoggedIn = true;
          notifyListeners();
          return response;
        }

        return response;
      } else {
        _setError(response.message ?? 'Login failed');
        return response;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An error occurred during login: $e');
      return ApiResponseWithData(e, false);
    }
  }

  Future<void> _saveLoginData(Map<String, dynamic> data) async {
    try {
      final accessToken = data['token']['accessToken'] ?? data['token'];
      final refreshToken = data['token']['refreshToken'];
      final userId = data['user']?['_id'] ?? data['userId'];
      user = UserModel.fromJson(data['user']);

      if (accessToken != null) {
        await SharedPrefUtil.setValue(accessTokenPref, accessToken);
      }
      if (refreshToken != null) {
        await SharedPrefUtil.setValue(refreshTokenPref, refreshToken);
      }
      if (userId != null) {
        await SharedPrefUtil.setValue(userIdPref, userId.toString());
      }
      await getUser();
      getActiveSubscription();
    } catch (e) {
      print('Error saving login data: $e');
    }
  }

  Future<bool> checkLoginStatus() async {
    try {
      final accessToken =
          SharedPrefUtil.getValue(accessTokenPref, '') as String;
      _isLoggedIn = accessToken.isNotEmpty;

      if (_isLoggedIn) {
        await getUser();
        await getActiveSubscription();
      }

      notifyListeners();
      return _isLoggedIn;
    } catch (e) {
      print('Error checking login status: $e');
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updateData) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await CallHelper().putWithData<Map<String, dynamic>>(
        'api/auth/profile',
        updateData,
        {},
      );

      _setLoading(false);

      if (response.success && response.data != null) {
        user = UserModel.fromJson(response.data!['data']);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An error occurred while updating profile: $e');
      return false;
    }
  }

  // 🔴 DELETE ACCOUNT
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _setError(null);

    try {
      final String token =
          SharedPrefUtil.getValue(accessTokenPref, '') as String;

      if (token.isEmpty) {
        _setLoading(false);
        _setError('No access token found');
        return false;
      }

      // Using your given endpoint:
      // DELETE http://34.206.193.218:7878/api/auth/deleteMyAccount
      final uri = Uri.parse('${CallHelper.baseUrl}api/auth/deleteMyAccount');

      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _setLoading(false);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Clear local data & tokens
        SharedPrefUtil.logOut();
        await _clearLoginData();
        return true;
      } else {
        _setError('Failed to delete account. (${response.statusCode})');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An error occurred while deleting account: $e');
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _setLoading(true);

    try {
      // Call logout API if needed
      final refreshToken =
          SharedPrefUtil.getValue(refreshTokenPref, '') as String;
      if (refreshToken.isNotEmpty) {
        await CallHelper().post('auth/logout', {'refreshToken': refreshToken});
      }
    } catch (e) {
      print('Error during logout API call: $e');
    } finally {
      await _clearLoginData();
      _setLoading(false);
    }
  }

  Future<void> _clearLoginData() async {
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }
}
