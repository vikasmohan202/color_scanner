import 'package:ralpal/provider/auth_provider.dart';
import 'package:ralpal/screen/dash_board_screen.dart';
import 'package:ralpal/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isCheckingLogin = true;

  final List<Map<String, String>> sliderTexts = [
    {
      'title': 'Learn, Scan & Explore Colors On the Go',
      'subtitle':
          'Transform idle moments into color discovery. Scan, learn, and explore shades anytime, anywhere',
    },
    {
      'title': 'Instant Color Detection',
      'subtitle':
          'Quickly identify colors using your camera and learn their names and codes.',
    },
    {
      'title': 'Build Your Palette',
      'subtitle':
          'Save and organize scanned colors into custom palettes for future use.',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();

    if (mounted) {
      setState(() {
        _isCheckingLogin = false;
      });

      // If user is already logged in, navigate to dashboard
      if (authProvider.isLoggedIn) {
        _navigateToDashboard();
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking login status
    if (_isCheckingLogin) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B50FF)),
              ),
              SizedBox(height: 20),
              Text(
                'Checking login status...',
                style: TextStyle(color: Color(0xFF5B50FF), fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Color Scanner',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B50FF),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 40,
                children: [
                  Image.asset('assets/images/Group 3 (2).png'),
                  Image.asset('assets/images/logo.png'),
                  Image.asset('assets/images/home_logo_3.png'),
                  Image.asset('assets/images/Group 4 (1).png'),
                ],
              ),
            ),

            // Slider Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF5B50FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Slider indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      sliderTexts.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 24 : 10,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? Colors.white
                              : Colors.white54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PageView
                  SizedBox(
                    height: 120,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: sliderTexts.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (_, index) {
                        return Column(
                          children: [
                            Text(
                              sliderTexts[index]['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sliderTexts[index]['subtitle']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Check if user is logged in using the provider
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );

                      if (authProvider.isLoggedIn) {
                        _navigateToDashboard();
                      } else {
                        _navigateToLogin();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5B50FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
