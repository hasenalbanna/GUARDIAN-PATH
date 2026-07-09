import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Allow the app to start without a local .env file.
  }

  // Initialize Firebase (Requires flutterfire configure to have been run)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error: $e");
    // In a real scenario, you'd want to handle this gracefully if it fails,
    // e.g. when google-services.json is missing before user configures it.
  }

  runApp(const GuardianPathApp());
}

class GuardianPathApp extends StatelessWidget {
  const GuardianPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Path',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine which screen to show based on Auth status
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is authenticated, check if onboarding is complete
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final data = userSnapshot.data!.data() as Map<String, dynamic>?;
                if (data != null && data.containsKey('name') && data['name'].toString().isNotEmpty) {
                  return const HomeScreen();
                }
              }
              // If user document doesn't exist or doesn't have a name, go to onboarding
              return const OnboardingScreen();
            },
          );
        }

        // Not authenticated
        return const LoginScreen();
      },
    );
  }
}
