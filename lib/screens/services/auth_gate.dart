// lib/screens/services/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_screen.dart';
import '../signin_screen.dart';
import '../welcome_screen.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This StreamBuilder listens directly to Firebase for login/logout events
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // While waiting for Firebase to tell us the auth state, show a loader
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // If Firebase says a user is logged in (authSnapshot.hasData is true)
        if (authSnapshot.hasData) {
          final user = authSnapshot.data!;
          // We then fetch that user's specific data from Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userDocSnapshot) {
              // While fetching from Firestore, show a loader
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              // If the Firestore document exists, the user is fully logged in
              if (userDocSnapshot.hasData && userDocSnapshot.data!.exists) {
                final userData = userDocSnapshot.data!.data() as Map<String, dynamic>;
                // Show the HomeScreen with the fetched data
                return HomeScreen(
                  username: userData['firstName'] ?? 'User',
                  points: userData['points'] ?? 0,
                  profileImageUrl: userData['profileImageUrl'], // Can be null
                );
              }

              // If the Firestore data doesn't exist, something is wrong. Log them out.
              return const WelcomeScreen();
            },
          );
        }

        // If Firebase says no user is logged in, show the sign-in screen
        else {
          return const WelcomeScreen();
        }
      },
    );
  }
}