import 'package:color_scanner/provider/auth_provider.dart';
import 'package:color_scanner/screen/splash_screen.dart';
import 'package:color_scanner/utils/shared_pref.dart';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' show Stripe;
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefUtil.init();
  Stripe.publishableKey =
      'pk_test_51SB8NbABTAXJRiRxQVcI0GM7RF1qgFQAlyXVCyxZN350CGNSEayQjWTDhIZbz6xpFYufGAUEnGXhoDVyGdWzbSwP00ABAE0dHN';
  Stripe.merchantIdentifier = 'merchant.flutter.stripe';
  Stripe.urlScheme = 'flutterstripe';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  bool isDark = false;

  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }
}
