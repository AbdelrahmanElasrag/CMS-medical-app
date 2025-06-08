import 'package:flutter/material.dart';
import 'family_member.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyProvider with ChangeNotifier {
  List<FamilyMember> _familyMembers = [];
  FamilyMember? _selectedMember;

  List<FamilyMember> get familyMembers => _familyMembers;
  FamilyMember? get selectedMember => _selectedMember;

  bool get selectedMemberExists {
    return _selectedMember != null &&
        _familyMembers.any((m) => m.id == _selectedMember!.id);
  }

  void addFamilyMember(FamilyMember member) {
    _familyMembers.add(member);
    notifyListeners();
  }

  void removeFamilyMember(String id) {
    if (_selectedMember?.id == id) {
      _selectedMember = null;
    }
    _familyMembers.removeWhere((member) => member.id == id);
    notifyListeners();
  }

  void selectMember(FamilyMember? member) {
    _selectedMember = member;
    notifyListeners();
  }

  Future<void> loadFamilyMembers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final familyCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('family');
    final snapshot = await familyCollection.get();
    _familyMembers = snapshot.docs.map((doc) {
      final data = doc.data();
      return FamilyMember(
        id: doc.id,
        relationship: data['relationship'] ?? '',
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        nationalId: data['nationalId'] ?? '',
        phoneNumber: data['phoneNumber'] ?? '',
        dateOfBirth: data['dateOfBirth'] != null ? DateTime.tryParse(data['dateOfBirth']) : null,
      );
    }).toList();
    notifyListeners();
  }

  Future<void> saveFamilyMembers() async {
    // Implement your saving logic
  }
}