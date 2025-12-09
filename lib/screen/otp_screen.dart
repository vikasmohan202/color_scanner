// otp_screen.dart
import 'dart:async';

import 'package:ralpal/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'new_password_screen.dart';

class OTPScreen extends StatefulWidget {
  final String email;

  const OTPScreen({super.key, required this.email});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _gradientAnimation;
  final TextEditingController _pinController = TextEditingController();
  StreamController<ErrorAnimationType>? _errorController;

  bool _isLoading = false;
  bool _canResend = true;
  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _errorController = StreamController<ErrorAnimationType>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _gradientAnimation = ColorTween(
      begin: const Color(0xFF667EEA),
      end: const Color(0xFF764BA2),
    ).animate(_animationController);

    _startResendCountdown();
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

  Future<void> _verifyOTP(String otp) async {
    if (otp.length != 6) {
      _showErrorSnackBar('Please enter the complete 6-digit OTP');
      _errorController?.add(ErrorAnimationType.shake);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOTP(widget.email, otp);

    if (success && mounted) {
      _navigateToNewPasswordScreen(otp);
    } else if (mounted) {
      _showErrorSnackBar(authProvider.errorMessage ?? 'Invalid OTP');
      _errorController?.add(ErrorAnimationType.shake);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resendOTP(widget.email);

    if (success && mounted) {
      _showSuccessSnackBar('OTP sent successfully');
      _startResendCountdown();
    } else if (mounted) {
      _showErrorSnackBar(authProvider.errorMessage ?? 'Failed to resend OTP');
    }
  }

  void _navigateToNewPasswordScreen(String otp) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NewPasswordScreen(email: widget.email, otp: otp),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pinController.dispose();
    _errorController?.close();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _gradientAnimation.value!,
                  _gradientAnimation.value!.withOpacity(0.8),
                  const Color(0xFFF093FB),
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildPinSection(),
                const SizedBox(height: 30),
                _buildVerifyButton(),
                const SizedBox(height: 20),
                _buildResendSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.sms, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 20),
        Text(
          'Enter OTP',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a 6-digit code to ${widget.email}',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildPinSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _pinController,
            animationType: AnimationType.fade,
            keyboardType: TextInputType.number,
            autoFocus: true,
            enableActiveFill: true,
            errorAnimationController: _errorController,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(12),
              fieldHeight: 48,
              fieldWidth: 45,
              activeFillColor: Colors.white.withOpacity(0.05),
              inactiveFillColor: Colors.white.withOpacity(0.03),
              selectedFillColor: Colors.white.withOpacity(0.06),
              activeColor: Colors.white70,
              inactiveColor: Colors.white38,
              selectedColor: Colors.white,
            ),
            cursorColor: Colors.white,
            textStyle: const TextStyle(color: Colors.white, fontSize: 20),
            onChanged: (value) {
              // you can react to text changes here if needed
            },
            onCompleted: (value) {
              // called when all 6 digits are filled (including paste)
              _verifyOTP(value);
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Enter the 6-digit code sent to your email',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ElevatedButton(
              onPressed: () => _verifyOTP(_pinController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF667EEA),
                ),
              ),
            ),
    );
  }

  Widget _buildResendSection() {
    return Center(
      child: Column(
        children: [
          Text(
            "Didn't receive the code?",
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 10),
          _canResend
              ? TextButton(
                  onPressed: _resendOTP,
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Text(
                  'Resend in $_resendCountdown seconds',
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
        ],
      ),
    );
  }
}
