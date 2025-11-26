import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:color_scanner/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:country_code_picker/country_code_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _gradientAnimation;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Pin controller for OTP
  final TextEditingController _pinController = TextEditingController();
  StreamController<ErrorAnimationType>? _pinErrorController;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;
  File? _selectedImage;
  bool _showOtpScreen = false;

  bool _isVerifyingOtp = false;
  bool _isStep0Valid = false;
  bool _isStep1Valid = false;
  bool _isStep2Valid = false;
  String _nameError = '';
  String _emailError = '';
  String _phoneError = '';

  // Country code picker
  String _selectedDialCode = '+1'; // default India

  Timer? _countdownTimer;
  bool _canResend = true;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _pinErrorController = StreamController<ErrorAnimationType>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _gradientAnimation = ColorTween(
      begin: const Color(0xFF667EEA),
      end: const Color(0xFF764BA2),
    ).animate(_animationController);

    // Add listeners to text controllers for real-time validation
    _fullNameController.addListener(_validateStep0);
    _phoneController.addListener(_validateStep0);
    _emailController.addListener(_validateStep1);
    _passwordController.addListener(_validateStep2);
    _confirmPasswordController.addListener(_validateStep2);
  }

  // Validation methods
  bool _validateName(String name) {
    if (name.isEmpty) {
      _nameError = 'Name is required';
      return false;
    }
    if (name.length < 2) {
      _nameError = 'Name must be at least 2 characters';
      return false;
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      _nameError = 'Name can only contain letters and spaces';
      return false;
    }
    _nameError = '';
    return true;
  }

  bool _validateEmail(String email) {
    if (email.isEmpty) {
      _emailError = 'Email is required';
      return false;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      _emailError = 'Please enter a valid email address';
      return false;
    }
    _emailError = '';
    return true;
  }

  bool _validatePhone(String phone) {
    if (phone.isEmpty) {
      _phoneError = 'Phone number is required';
      return false;
    }

    // Digits only
    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Minimum 6 digits (since we also have country code separately)
    if (cleanedPhone.length < 6) {
      _phoneError = 'Phone number must be at least 6 digits';
      return false;
    }

    // Maximum 15 digits
    if (cleanedPhone.length > 15) {
      _phoneError = 'Phone number must not exceed 15 digits';
      return false;
    }

    _phoneError = '';
    return true;
  }

  // Validation methods for each step
  void _validateStep0() {
    final bool isNameValid = _validateName(_fullNameController.text.trim());
    final bool isPhoneValid = _validatePhone(_phoneController.text.trim());
    final bool hasImage = _selectedImage != null;

    setState(() {
      _isStep0Valid = isNameValid && isPhoneValid && hasImage;
    });
  }

  void _validateStep1() {
    final bool isEmailValid = _validateEmail(_emailController.text.trim());
    setState(() {
      _isStep1Valid = isEmailValid;
    });
  }

  void _validateStep2() {
    final bool isValid =
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text &&
        _passwordController.text.length >= 6;
    setState(() {
      _isStep2Valid = isValid;
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      _validateStep0();
      if (!_isStep0Valid) {
        if (_fullNameController.text.trim().isEmpty) {
          _nameError = 'Name is required';
        }
        if (_phoneController.text.trim().isEmpty) {
          _phoneError = 'Phone number is required';
        }
        if (_selectedImage == null) {
          _showErrorSnackBar('Please upload a profile image');
        } else {
          _showErrorSnackBar('Please fix the validation errors');
        }
        setState(() {});
        return;
      }
    }

    if (_currentStep == 1) {
      _validateStep1();
      if (!_isStep1Valid) {
        if (_emailController.text.trim().isEmpty) {
          _emailError = 'Email is required';
        }
        _showErrorSnackBar('Please fix the email validation error');
        setState(() {});
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();

    _pinController.dispose();
    _pinErrorController?.close();

    _countdownTimer?.cancel();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _validateStep0(); // Revalidate step after image selection
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (!_isStep0Valid || !_isStep1Valid || !_isStep2Valid) {
      _showErrorSnackBar('Please complete all steps before signing up');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        "http://34.206.193.218:7878/api/auth/signup/request-otp",
      );

      var request = http.MultipartRequest("POST", url);
      request.fields['name'] = _fullNameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['password'] = _passwordController.text;

      // build full phone number with country code
      final cleanedPhone = _phoneController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      final dialCode = _selectedDialCode; // e.g. +91
      request.fields['phoneNo'] = '$dialCode$cleanedPhone';

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('files', _selectedImage!.path),
        );
      }

      var response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(resBody);
        setState(() {
          _showOtpScreen = true;
        });
        _showSuccessSnackBar(data["message"] ?? "OTP sent to your email!");
        _startResendCountdown();
      } else {
        _showErrorSnackBar("Signup failed: ${resBody.toString()}");
      }
    } catch (e) {
      _showErrorSnackBar("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startResendCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    String otp = _pinController.text.trim();

    if (otp.length != 6) {
      _showErrorSnackBar('Please enter complete OTP');
      _pinErrorController?.add(ErrorAnimationType.shake);
      return;
    }

    setState(() {
      _isVerifyingOtp = true;
    });

    try {
      final url = Uri.parse(
        "http://34.206.193.218:7878/api/auth/signup/verify-otp",
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"email": _emailController.text, "otp": otp}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _showVerificationSuccessDialog(
          data["message"] ?? "Account verified successfully!",
        );
      } else {
        _showErrorSnackBar("Verification failed: ${response.body}");
      }
    } catch (e) {
      _showErrorSnackBar("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingOtp = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    // Re-use the sign-up endpoint to request OTP again (or hit your dedicated resend endpoint)
    await _handleSignUp();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showVerificationSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.verified, size: 60, color: Colors.green),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Account Verified!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667EEA),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpScreen() {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _gradientAnimation.value ?? const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildOtpAppLogo(),
                      const SizedBox(height: 24),
                      _buildOtpWelcomeText(),
                      const SizedBox(height: 32),
                      _buildOtpForm(),
                      const SizedBox(height: 30),
                      _buildVerifyButton(),
                      const SizedBox(height: 20),
                      // _buildResendOtpButton(),
                      // const SizedBox(height: 20),
                      _buildBackToSignupButton(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOtpAppLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.verified_user, size: 50, color: Colors.white),
    );
  }

  Widget _buildOtpWelcomeText() {
    return Column(
      children: [
        Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit code sent to',
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
        ),
        const SizedBox(height: 4),
        Text(
          _emailController.text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Enter OTP Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _pinController,
            animationType: AnimationType.fade,
            keyboardType: TextInputType.number,
            autoFocus: true,
            enableActiveFill: true,
            errorAnimationController: _pinErrorController,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(12),
              fieldHeight: 55,
              fieldWidth: 45,
              activeFillColor: Colors.white.withOpacity(0.12),
              inactiveFillColor: Colors.white.withOpacity(0.08),
              selectedFillColor: Colors.white.withOpacity(0.14),
              activeColor: Colors.white70,
              inactiveColor: Colors.white38,
              selectedColor: Colors.white,
            ),
            cursorColor: Colors.white,
            textStyle: const TextStyle(color: Colors.white, fontSize: 20),
            onChanged: (value) {
              // optional: react to changes
            },
            onCompleted: (value) {
              // automatically verify when completed
              _verifyOtp();
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Didn\'t receive the code?',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isVerifyingOtp ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF667EEA),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: _isVerifyingOtp
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                ),
              )
            : const Text(
                'VERIFY ACCOUNT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildResendOtpButton() {
    return Column(
      children: [
        _canResend
            ? TextButton(
                onPressed: _resendOtp,
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            : Text(
                'Resend in $_resendCountdown seconds',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
      ],
    );
  }

  Widget _buildBackToSignupButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _showOtpScreen = false;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_back,
            color: Colors.white.withOpacity(0.8),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Back to Sign Up',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- rest of original UI (signup flow) below ---

  @override
  Widget build(BuildContext context) {
    if (_showOtpScreen) {
      return _buildOtpScreen();
    }

    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _gradientAnimation.value ?? const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAppLogo(),
                      const SizedBox(height: 24),
                      _buildWelcomeText(),
                      const SizedBox(height: 32),
                      _buildSignupForm(),
                      const SizedBox(height: 30),
                      _buildSignupButton(),
                      const SizedBox(height: 20),
                      _buildDivider(),
                      const SizedBox(height: 20),
                      // _buildSocialSignupButtons(),
                      // const SizedBox(height: 30),
                      _buildLoginLink(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- UI helpers ---

  Widget _buildProfileStep() {
    return Column(
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // Full name
        _buildTextField(
          controller: _fullNameController,
          hintText: 'Full Name',
          prefixIcon: Icons.person,
          keyboardType: TextInputType.emailAddress,
          errorText: _nameError.isNotEmpty ? _nameError : null,
        ),
        const SizedBox(height: 15),

        // Phone with country code picker
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _phoneError.isNotEmpty
                      ? Colors.red
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CountryCodePicker(
                    onChanged: (code) {
                      setState(() {
                        _selectedDialCode = code.dialCode ?? '+1';
                      });
                      _validateStep0();
                    },
                    initialSelection: _selectedDialCode, // '+91'
                    favorite: const ['+1', 'US'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    textStyle: const TextStyle(color: Colors.white),
                    dialogTextStyle: const TextStyle(color: Colors.black),
                    searchStyle: const TextStyle(color: Colors.black),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.white24,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (value) {
                        _validateStep0();
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_phoneError.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  _phoneError,
                  style: TextStyle(color: Colors.red[200], fontSize: 12),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 15),

        // Image picker
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedImage == null
                    ? Colors.transparent
                    : Colors.green,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  color: _selectedImage == null ? Colors.white70 : Colors.green,
                ),
                const SizedBox(width: 10),
                Text(
                  _selectedImage == null
                      ? "Upload Profile Image"
                      : "Image Selected ✓",
                  style: TextStyle(
                    color: _selectedImage == null
                        ? Colors.white70
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedImage == null) ...[
          const SizedBox(height: 8),
          Text(
            'Profile image is required',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 20),
        _buildActionButtons(showNext: true),
      ],
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.color_lens, size: 50, color: Colors.white),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Join ColorScanner',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create your colorful journey',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStepperIndicator(),
          const SizedBox(height: 20),
          _buildStepContent(),
        ],
      ),
    );
  }

  Widget _buildStepperIndicator() {
    return Row(
      children: [
        _buildStepCircle(0, 'Profile'),
        _buildStepLine(),
        _buildStepCircle(1, 'Account'),
        _buildStepLine(),
        _buildStepCircle(2, 'Security'),
      ],
    );
  }

  Widget _buildStepCircle(int stepNumber, String label) {
    bool isActive = stepNumber == _currentStep;
    bool isCompleted = stepNumber < _currentStep;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? Colors.white
                : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 18, color: Color(0xFF667EEA))
              : Center(
                  child: Text(
                    (stepNumber + 1).toString(),
                    style: TextStyle(
                      color: isActive ? const Color(0xFF667EEA) : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildProfileStep();
      case 1:
        return _buildAccountStep();
      case 2:
        return _buildSecurityStep();
      default:
        return _buildProfileStep();
    }
  }

  Widget _buildAccountStep() {
    return Column(
      children: [
        const Text(
          'Account Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _emailController,
          hintText: 'Email Address',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError.isNotEmpty ? _emailError : null,
        ),
        const SizedBox(height: 20),
        _buildActionButtons(showNext: true, showPrevious: true),
      ],
    );
  }

  Widget _buildSecurityStep() {
    return Column(
      children: [
        const Text(
          'Security Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildPasswordField(
          controller: _passwordController,
          hintText: 'Password',
          obscureText: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 15),
        _buildPasswordField(
          controller: _confirmPasswordController,
          hintText: 'Confirm Password',
          obscureText: _obscureConfirmPassword,
          onToggle: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
        ),
        const SizedBox(height: 15),
        _buildPasswordRequirements(),
        const SizedBox(height: 20),
        _buildActionButtons(showNext: false, showPrevious: true),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.transparent,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon, color: Colors.white70),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            keyboardType: keyboardType,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red[200], fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.white70),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: onToggle,
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;
    final hasMinLength = password.length >= 6;
    final passwordsMatch =
        ((_passwordController.text == _confirmPasswordController.text) &&
        (_passwordController.text.isNotEmpty ||
            _confirmPasswordController.text.isNotEmpty));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          _buildRequirementItem('At least 6 characters', hasMinLength),
          _buildRequirementItem('Passwords match', passwordsMatch),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? Colors.green : Colors.white.withOpacity(0.5),
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: isMet ? Colors.green : Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons({
    required bool showNext,
    bool showPrevious = false,
  }) {
    // Determine if next button should be enabled based on current step
    bool isNextEnabled = false;
    if (_currentStep == 0) {
      isNextEnabled = _isStep0Valid;
    } else if (_currentStep == 1) {
      isNextEnabled = _isStep1Valid;
    }

    return Row(
      children: [
        if (showPrevious)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('BACK'),
            ),
          ),
        if (showPrevious) const SizedBox(width: 10),
        if (showNext)
          Expanded(
            child: ElevatedButton(
              onPressed: isNextEnabled ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isNextEnabled
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                foregroundColor: isNextEnabled
                    ? const Color(0xFF667EEA)
                    : Colors.white.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'NEXT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isNextEnabled
                      ? const Color(0xFF667EEA)
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSignupButton() {
    final isSignUpEnabled = _isStep0Valid && _isStep1Valid && _isStep2Valid;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isSignUpEnabled && !_isLoading ? _handleSignUp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSignUpEnabled
              ? Colors.white
              : Colors.white.withOpacity(0.3),
          foregroundColor: isSignUpEnabled
              ? const Color(0xFF667EEA)
              : Colors.white.withOpacity(0.5),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                ),
              )
            : Text(
                'CREATE ACCOUNT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSignUpEnabled
                      ? const Color(0xFF667EEA)
                      : Colors.white.withOpacity(0.5),
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'Or sign up with',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
        ),
      ],
    );
  }

  Widget _buildSocialSignupButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.g_mobiledata,
          onPressed: () {},
          color: Colors.red,
        ),
        const SizedBox(width: 20),
        _buildSocialButton(
          icon: Icons.facebook,
          onPressed: () {},
          color: Colors.blue,
        ),
        const SizedBox(width: 20),
        _buildSocialButton(
          icon: Icons.apple,
          onPressed: () {},
          color: Colors.black,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              // decoration: TextDecoration.underline,
              shadows: [
                Shadow(blurRadius: 5, color: Colors.black.withOpacity(0.3)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
