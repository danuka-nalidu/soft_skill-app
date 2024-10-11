import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:uee_project/pages/home_screen.dart'; // Regular user screen
import 'package:uee_project/pages/login.dart'; // Login screen
import 'package:uee_project/pages/admin_profile.dart'; // Admin screen
import 'pages/app_main_screen.dart'; // Regular user screen
import 'providers/course_provider.dart'; // Import CourseProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthStateWrapper(),
      ),
    );
  }
}

// This widget handles authentication state and role-based navigation
class AuthStateWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while waiting for auth state
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, now we fetch their role
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                String role =
                    userData['role'] ?? 'user'; // Default to 'user' role

                // Navigate based on the user's role
                if (role == 'admin') {
                  return AdminProfile(); // Admin profile
                } else {
                  return const AppMainScreen(); // Regular user screen
                }
              }

              return const LoginScreen(); // In case fetching role fails, send back to login
            },
          );
        }

        // If user is not logged in, show login screen
        return const LoginScreen();
      },
    );
  }
}
