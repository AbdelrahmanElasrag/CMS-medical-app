import 'package:equatable/equatable.dart';

// 1. Change the class to extend Equatable
class FamilyMember extends Equatable {
  final String id;
  final String relationship;
  final String firstName;
  final String lastName;
  final String nationalId;
  final String phoneNumber;
  final DateTime? dateOfBirth;

  // 2. Make the constructor const (good practice with Equatable)
  const FamilyMember({
    required this.id,
    required this.relationship,
    required this.firstName,
    required this.lastName,
    required this.nationalId,
    required this.phoneNumber,
    this.dateOfBirth,
  });

  // Your toMap and fromMap methods remain the same
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'relationship': relationship,
      'firstName': firstName,
      'lastName': lastName,
      'nationalId': nationalId,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id'],
      relationship: map['relationship'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      nationalId: map['nationalId'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : null,
    );
  }

  // 3. This is the crucial part.
  // We tell Equatable that two FamilyMember objects are equal if their unique 'id' is the same.
  @override
  List<Object?> get props => [id];
}