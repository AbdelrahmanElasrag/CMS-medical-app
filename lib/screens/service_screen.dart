import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'family_member.dart';
import 'family_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceScreen extends StatefulWidget {
  final String service;
  final String username;

  const ServiceScreen({Key? key, required this.service, required this.username}) : super(key: key);

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {

  IconData _getRelationshipIcon(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'mother': return Icons.female;
      case 'father': return Icons.male;
      case 'wife': return Icons.female;
      case 'husband': return Icons.male;
      case 'daughter': return Icons.girl;
      case 'son': return Icons.boy;
      default: return Icons.person;
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedGender;
  String? _selectedSpeciality;
  List<String> _availableChoices = ['Medical Transport', 'Doctor Booking', 'Follow-Up Care', 'Emergency and Accidents', 'Coordinator Service and Registration'];
  List<String> _selectedChoices = [];
  Map<String, DateTime?> _choiceDates = {};

  @override
  Widget build(BuildContext context) {
    final familyProvider = Provider.of<FamilyProvider>(context);
    final selectedMember = familyProvider.selectedMember;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF00C896)),
      ),
      body: SingleChildScrollView(  // Moved inside Scaffold
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header remains the same
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi ${widget.username},',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Let's continue your booking",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Family Member Selection
            Card(
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service For:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButton<FamilyMember>(
                      isExpanded: true,
                      value: familyProvider.selectedMemberExists ? familyProvider.selectedMember : null,
                      hint: Text('Select family member'),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Myself (${widget.username})'),
                        ),
                        ...familyProvider.familyMembers.map((member) => DropdownMenuItem(
                          value: member,
                          child: Row(
                            children: [
                              Icon(
                                _getRelationshipIcon(member.relationship),
                                color: Color(0xFF00C896),
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                '${member.relationship}: ${member.firstName} ${member.lastName}',
                                style: TextStyle(
                                  color: familyProvider.selectedMember?.id == member.id
                                      ? Color(0xFF00C896)
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                      onChanged: (member) {
                        if (member != null && !familyProvider.familyMembers.any((m) => m.id == member.id)) {
                          // Member was deleted elsewhere
                          familyProvider.selectMember(null);
                          setState(() {
                            _fullNameController.text = '';
                            _phoneController.text = '';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Selected member was removed'))
                          );
                          return;
                        }

                        familyProvider.selectMember(member);
                        if (member != null) {
                          setState(() {
                            _fullNameController.text = '${member.firstName} ${member.lastName}';
                            _phoneController.text = member.phoneNumber;
                          });
                        } else {
                          setState(() {
                            _fullNameController.text = '';
                            _phoneController.text = '';
                          });
                        }
                      },
                      dropdownColor: Colors.white,
                      icon: Icon(Icons.arrow_drop_down, color: Color(0xFF00C896)),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      underline: Container(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Form Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedSpeciality,
                        decoration: _inputDecoration(
                          'Medical Speciality',
                          Icons.medical_services_outlined,
                        ),
                        items:
                        [
                          "Cardiopulmonory Center",
                          "Critical Care and I.C.U",
                          "Dental",
                          "Dermatology",
                          "DermaSurge Center",
                          "Emergency Medicine",
                          "Endocrinology",
                          "ENT",
                          "Family Medicine",
                          "Gastroenterology",
                          "Gastrointestinal Surgery",
                          "General Surgery",
                          "Endoscopy",
                          "Internal Medicine",
                          "Medical Oncology",
                          "Nephrology",
                          "Neuroscience",
                          "Nuclear Medicine",
                          "Obstetrics and Gynecology​",
                          "Ophthalmology",
                          "Orthopedics and Sports Medicine",
                          "Spine Surgery",
                          "Pathology",
                          "Pediatric Surgery",
                          "Pediatrics and Neonatology",
                          "Physiotherapy & Rehabilitation",
                          "Pulmonology",
                          "Radiology& Dlognostic Imaging",
                          "Urology",
                          "Vascular Surgery",
                          "Hyperbaric Oxygen Therapy - HBOT",
                          "Dialysis Center",
                          "Breast Center",
                          "Cath Lab",
                          "Labaratory",
                          "Neonatal ICU",
                          "Operation Rooms",
                        ]
                            .map(
                              (speciality) => DropdownMenuItem(
                            value: speciality,
                            child: Text(speciality),
                          ),
                        )
                            .toList(),
                        onChanged:
                            (value) =>
                            setState(() => _selectedSpeciality = value),
                        validator:
                            (value) =>
                        value == null
                            ? 'Please select a speciality'
                            : null,
                      ),
                      SizedBox(height: 16),

                      // Full Name Field
                      TextFormField(
                        controller: _fullNameController,
                        decoration: _inputDecoration(
                          'Full Name',
                          Icons.person_outline,
                        ),
                        validator: (value) {
                          if (familyProvider.selectedMember == null &&
                              (value?.isEmpty ?? true)) {
                            return 'Please enter full name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Age Field
                      TextFormField(
                        controller: _ageController,
                        decoration: _inputDecoration(
                          'Age',
                          Icons.cake_outlined,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Please enter age';
                          if (int.tryParse(value!) == null)
                            return 'Please enter a valid number';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Gender Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: _inputDecoration(
                          'Gender',
                          Icons.transgender_outlined,
                        ),
                        items:
                        ['Male', 'Female', 'Other', 'Prefer not to say']
                            .map(
                              (gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ),
                        )
                            .toList(),
                        onChanged:
                            (value) =>
                            setState(() => _selectedGender = value),
                        validator:
                            (value) =>
                        value == null ? 'Please select gender' : null,
                      ),
                      SizedBox(height: 16),

                      // Phone Number Field
                      TextFormField(
                        controller: _phoneController,
                        decoration: _inputDecoration(
                          'Phone Number',
                          Icons.phone_outlined,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (familyProvider.selectedMember == null &&
                              (value?.isEmpty ?? true)) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Services Needed
                      InputDecorator(
                        decoration: _inputDecoration(
                          'Select Services Needed',
                          Icons.list_alt_outlined,
                        ),
                        child: Column(
                          children: [
                            Wrap(
                              spacing: 8.0,
                              children:
                              _availableChoices.map((choice) {
                                return FilterChip(
                                  label: Text(choice),
                                  selected: _selectedChoices.contains(
                                    choice,
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedChoices.add(choice);
                                        _choiceDates[choice] = null;
                                      } else {
                                        _selectedChoices.remove(choice);
                                        _choiceDates.remove(choice);
                                      }
                                    });
                                  },
                                  selectedColor: Color(
                                    0xFF00C896,
                                  ).withOpacity(0.2),
                                  checkmarkColor: Color(0xFF00C896),
                                );
                              }).toList(),
                            ),
                            if (_selectedChoices.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'No services selected',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Date Pickers for selected services
                      ..._selectedChoices.map((choice) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => _selectDate(choice),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date for $choice',
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                  ),
                                ),
                                child: Text(
                                  _choiceDates[choice] == null
                                      ? 'Select a date'
                                      : '${_choiceDates[choice]!.day}/${_choiceDates[choice]!.month}/${_choiceDates[choice]!.year}',
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        );
                      }).toList(),

                      if (_selectedChoices.contains('Medical Transport'))
                        TextFormField(
                          controller: _addressController,
                          decoration: _inputDecoration(
                            'Pickup Address',
                            Icons.location_on_outlined,
                          ),
                          validator:
                              (value) =>
                          _selectedChoices.contains(
                            'Medical Transport',
                          ) &&
                              (value == null || value.isEmpty)
                              ? 'Please enter the address'
                              : null,
                        ),

                      SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: _inputDecoration(
                          'Additional Notes',
                          Icons.note_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C896),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'CONFIRM BOOKING',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      labelStyle: TextStyle(color: Colors.grey[600]),
    );
  }

  Future<void> _selectDate(String choice) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF00C896),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() => _choiceDates[choice] = pickedDate);
    }
  }

  void _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      final familyProvider = Provider.of<FamilyProvider>(
        context,
        listen: false,
      );
      final selectedMember = familyProvider.selectedMember;

      // Validate service dates
      bool allDatesSelected = _selectedChoices.every(
            (choice) => _choiceDates[choice] != null,
      );
      if (!allDatesSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select dates for all chosen services'),
          ),
        );
        return;
      }

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please sign in to book services')),
        );
        return;
      }

      // Create booking data
      final bookingData = {
        'userId': user.uid,
        'fullName': _fullNameController.text,
        'age': _ageController.text,
        'gender': _selectedGender,
        'phone': _phoneController.text,
        'speciality': _selectedSpeciality,
        'services': _selectedChoices,
        'serviceDates': _choiceDates.map((key, value) => MapEntry(key, value?.toIso8601String())),
        'address': _selectedChoices.contains('Medical Transport') ? _addressController.text : null,
        'notes': _notesController.text,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        if (selectedMember != null) {
          // Save booking under family member
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('family')
              .doc(selectedMember.id)
              .collection('bookings')
              .add(bookingData);
        } else {
          // Save booking under main user
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('bookings')
              .add(bookingData);
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Booking Confirmed',
              style: TextStyle(color: Color(0xFF00C896)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thank you for your booking!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                if (selectedMember != null)
                  _buildConfirmationRow(
                    Icons.group,
                    'Booking for:',
                    '${selectedMember.relationship} (${selectedMember.firstName})',
                  ),
                _buildConfirmationRow(
                  Icons.person,
                  'Name:',
                  _fullNameController.text,
                ),
                _buildConfirmationRow(
                  Icons.phone,
                  'Phone:',
                  _phoneController.text,
                ),
                _buildConfirmationRow(
                  Icons.local_hospital_outlined,
                  'Speciality:',
                  _selectedSpeciality ?? 'Not selected',
                ),
                SizedBox(height: 8),
                ..._selectedChoices.map(
                      (choice) => _buildConfirmationRow(
                    Icons.calendar_today,
                    '$choice Date:',
                    '${_choiceDates[choice]!.day}/${_choiceDates[choice]!.month}/${_choiceDates[choice]!.year}',
                  ),
                ),
                if (_selectedChoices.contains('Medical Transport'))
                  _buildConfirmationRow(
                    Icons.location_on,
                    'Pickup Address:',
                    _addressController.text,
                  ),
                SizedBox(height: 12),
                Text(
                  'Our team will contact you shortly to confirm the details.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: Text(
                  'DONE',
                  style: TextStyle(color: Color(0xFF00C896)),
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving booking: $e')),
        );
      }
    }
  }

  Widget _buildConfirmationRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 4),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _specialityController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
