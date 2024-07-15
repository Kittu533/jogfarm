import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jogfarmv1/screens/auth/login_screen.dart';
import 'package:jogfarmv1/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: const Color(0xFF2D4739),
        ),
        child: const Center(
          child: SizedBox(
            width: 150.0,
            height: 150.0,
            child: Image(image: AssetImage('images/logo_jogfarm.png')),
          ),
        ),
      ),
    );
  }
}
