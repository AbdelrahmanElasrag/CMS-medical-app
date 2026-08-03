import 'package:flutter/material.dart';
import 'family_member.dart';

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

  /// Load family members. No backend API yet - keeps local list only.
  Future<void> loadFamilyMembers() async {
    _familyMembers = [];
    notifyListeners();
  }

  Future<void> saveFamilyMembers() async {
    // No backend persistence for family members yet
  }
}
