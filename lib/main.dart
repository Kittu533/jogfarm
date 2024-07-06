import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jogfarmv1/firebase_options.dart';
import 'package:jogfarmv1/screens/home_screen.dart';
import 'package:jogfarmv1/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          // Show a loading spinner while Firebase initializes
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Once complete, show the main application
          if (snapshot.connectionState == ConnectionState.done) {
            return const HomeScreen(); // Update to HomeScreen
          }
          // If initialization failed, show an error message
          if (snapshot.hasError) {
            return Center(
                child: Text('Error initializing Firebase: ${snapshot.error}'));
          }
          // Default case, should not be reached
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
