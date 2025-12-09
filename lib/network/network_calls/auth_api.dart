import 'dart:io';
import 'dart:convert';

import 'package:ralpal/network/call_helper.dart';
import 'package:ralpal/utils/constants.dart';
import 'package:ralpal/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class AuthAPIs {
  AuthAPIs() : super();

  Future<ApiResponseWithData<Map<String, dynamic>>> createPayment(
    String planId,
  ) async {
    Map<String, String> data = {'planId': planId};

    return await CallHelper().postWithData(
      'api/subscription/create-intent',
      data,
      {},
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> increaseCount() async {
    return await CallHelper().postWithData('api/scan/free-scan', {}, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> activatePlan(
    String planId,
    String paymentIntentId,
  ) async {
    Map<String, String> data = {
      "planId": planId,
      "paymentIntentId": paymentIntentId,
    };

    return await CallHelper().postWithData(
      'api/subscription/activate',
      data,
      {},
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    Map<String, String> data = {'email': email, 'password': password};

    return await CallHelper().postWithData('api/auth/login', data, {});
  }

  //
  Future<ApiResponse> refresh(String refreshToken) async {
    Map<String, String> data = {'refreshToken': refreshToken};
    return await CallHelper().post('api/users/refreshToken', data);
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> verifyOTP(
    String email,
    String otp,
  ) async {
    Map<String, String> data = {'email': email, 'otp': otp};
    return await CallHelper().postWithData('api/users/verifyOTP', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> resendOtp(
    String email,
    String otp,
  ) async {
    Map<String, String> data = {'email': email, 'otp': otp};
    return await CallHelper().postWithData('api/users/resend-otp', data, {});
  }

  Future<ApiResponse> setPassword(String email, String password) async {
    Map<String, String> data = {"email": email, "password": password};
    return await CallHelper().post('api/users/set-password', data);
  }

  //api/subscription/create-intent

  Future<ApiResponse> passwordReset(
    String email,
    String otp,
    String password,
  ) async {
    Map<String, String> data = {
      'email': email,
      'otp': otp, //6 digit
      "newPassword": password,
    };

    return await CallHelper().post('api/auth/reset-password', data);
  }

  Future<ApiResponse> logout() async {
    String refToken = SharedPrefUtil.getValue(refreshTokenPref, "") as String;

    Map<String, String> data = {'refreshToken': refToken};

    var res = await CallHelper().post('auth/logout', data);
    return res;
  }

  Future<ApiResponse> forgetPassword(String email) async {
    Map<String, String> data = {'email': email};

    return await CallHelper().post('api/auth/forgot-password', data);
  }

  Future<ApiResponse> changePassword(
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    Map<String, String> data = {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
      "confirmNewPassword": confirmNewPassword,
    };
    return await CallHelper().post('api/users/changePassword', data);
  }

  Future<ApiResponseWithData> deleteAccount() async {
    var userId = SharedPrefUtil.getValue(userIdPref, "") as String;
    Map<String, dynamic> data = {"status": 0};
    return await CallHelper().putWithData(
      "update-user-status-admin/$userId/status",
      data,
      {},
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getNotifications() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData('notifications', data);
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getUser() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData('api/auth/profile', data);
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getSubscriptionPlan(
    String userId,
  ) async {
    Map<String, String> data = {};

    return await CallHelper().getWithData(
      'api/subscription/active/${userId}',
      data,
    );
  }
}
