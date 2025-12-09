import 'package:camera/camera.dart';
import 'package:ralpal/screen/color_scanner.dart';
import 'package:ralpal/screen/profile_screen.dart';

import 'package:flutter/material.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ColorScannerHomeScreen(),
    // BrowsePaletteScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    // TODO: implement initState
    asyncInit();
    super.initState();
  }

  asyncInit() async {}

  @override
  Widget build(BuildContext context) {
    // final cameras =  availableCameras();

    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ColorScannerScreen();
              },
            ),
          );
        },
        backgroundColor: const Color(0xFF5B50FF),
        child: const Icon(Icons.center_focus_strong),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: _selectedIndex == 0
                      ? const Color(0xFF5B50FF)
                      : Colors.grey,
                  size: 30,
                ),
                onPressed: () => _onTabTapped(0),
              ),
              // IconButton(
              //   icon: Icon(Icons.explore_outlined,
              //       color: _selectedIndex == 1
              //           ? const Color(0xFF5B50FF)
              //           : Colors.grey,
              //       size: 30),
              //   onPressed: () => _onTabTapped(1),
              // ),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: _selectedIndex == 1
                      ? const Color(0xFF5B50FF)
                      : Colors.grey,
                  size: 30,
                ),
                onPressed: () => _onTabTapped(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
