import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../home_screen.dart';

class AutoLoginCheck extends StatelessWidget {
  final String phone;
  final String nationalId;

  const AutoLoginCheck({required this.phone, required this.nationalId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .where('nationalId', isEqualTo: nationalId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const MaterialApp(home: Scaffold(body: Center(child: Text("Auto-login failed"))));
        }

        final userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

        return MaterialApp(
          home: HomeScreen(
            username: userData['firstName'],
            points: userData['points'],
          ),
        );
      },
    );
  }
}
