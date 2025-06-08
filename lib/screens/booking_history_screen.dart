import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'My Bookings'), Tab(text: 'Family Bookings')],
          indicatorColor: Color(0xFF00C896),
          labelColor: Color(0xFF00C896),
          unselectedLabelColor: Colors.black54,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by patient name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedService,
                  hint: const Text('Service'),
                  items:
                  ['Doctor Booking', 'Medical Transport']
                      .map(
                        (service) => DropdownMenuItem(
                      value: service,
                      child: Text(service),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedService = value;
                    });
                  },
                  underline: Container(),
                ),
                if (_selectedService != null)
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedService = null;
                      });
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _BookingsList(
                  isFamily: false,
                  searchQuery: _searchQuery,
                  selectedService: _selectedService,
                ),
                _BookingsList(
                  isFamily: true,
                  searchQuery: _searchQuery,
                  selectedService: _selectedService,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final bool isFamily;
  final String searchQuery;
  final String? selectedService;

  const _BookingsList({
    required this.isFamily,
    required this.searchQuery,
    required this.selectedService,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Not signed in'));
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchBookings(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No bookings found'));
        }
        // Filter by search and service
        final filtered =
        snapshot.data!.where((booking) {
          final patientName =
          (booking['fullName'] != null &&
              booking['fullName'].toString().trim().isNotEmpty)
              ? booking['fullName']
              : ((booking['firstName'] ?? '') +
              ' ' +
              (booking['lastName'] ?? ''))
              .trim();
          final name = patientName.toLowerCase();
          final matchesName =
              searchQuery.isEmpty || name.contains(searchQuery);
          final matchesService =
              selectedService == null ||
                  (booking['services'] != null &&
                      (booking['services'] as List).contains(selectedService));
          final status = (booking['status'] ?? '').toString().toLowerCase();
          final matchesStatus =
              status == 'pending' || status == 'confirmed';
          return matchesName && matchesService && matchesStatus;
        }).toList();
        filtered.sort((a, b) {
          final aDate =
          a['serviceDates']?['Doctor Booking'] != null
              ? DateTime.tryParse(a['serviceDates']['Doctor Booking'])
              : null;
          final bDate =
          b['serviceDates']?['Doctor Booking'] != null
              ? DateTime.tryParse(b['serviceDates']['Doctor Booking'])
              : null;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final booking = filtered[index];
            final patientName =
            (booking['fullName'] != null &&
                booking['fullName'].toString().trim().isNotEmpty)
                ? booking['fullName']
                : ((booking['firstName'] ?? '') +
                ' ' +
                (booking['lastName'] ?? ''))
                .trim();
            final displayName =
            patientName.isNotEmpty ? patientName : 'Unknown';
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: const Color(0xFFE6F3EF).withOpacity(0.9),
              child: ListTile(
                title: Text(displayName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (booking['serviceDates']?['Doctor Booking'] != null)
                      Text(
                        'Date: ${booking['serviceDates']['Doctor Booking'].toString().split("T")[0]}',
                      ),
                    if (booking['services'] != null &&
                        (booking['services'] as List).isNotEmpty)
                      Text(
                        'Service: ${(booking['services'] as List).join(", ")}',
                      ),
                    if (booking['speciality'] != null)
                      Text('Speciality: ${booking['speciality']}'),
                    if (booking['phone'] != null)
                      Text('Phone: ${booking['phone']}'),
                    if (booking['notes'] != null &&
                        booking['notes'].toString().trim().isNotEmpty)
                      Text('Notes: ${booking['notes']}'),
                    if (booking['status'] != null)
                      Text('Status: ${booking['status']}'),
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final patientName =
                      (booking['fullName'] != null &&
                          booking['fullName']
                              .toString()
                              .trim()
                              .isNotEmpty)
                          ? booking['fullName']
                          : ((booking['firstName'] ?? '') +
                          ' ' +
                          (booking['lastName'] ?? ''))
                          .trim();
                      final displayName =
                      patientName.isNotEmpty ? patientName : 'Unknown';
                      return AlertDialog(
                        title: Text('Booking Details'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Patient: $displayName'),
                              if (booking['serviceDates']?['Doctor Booking'] !=
                                  null)
                                Text(
                                  'Date: ${booking['serviceDates']['Doctor Booking']}',
                                ),
                              if (booking['services'] != null &&
                                  (booking['services'] as List).isNotEmpty)
                                Text(
                                  'Service: ${(booking['services'] as List).join(", ")}',
                                ),
                              if (booking['speciality'] != null)
                                Text('Speciality: ${booking['speciality']}'),
                              if (booking['phone'] != null)
                                Text('Phone: ${booking['phone']}'),
                              if (booking['notes'] != null &&
                                  booking['notes'].toString().trim().isNotEmpty)
                                Text('Notes: ${booking['notes']}'),
                              if (booking['status'] != null)
                                Text('Status: ${booking['status']}'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchBookings(String uid) async {
    final firestore = FirebaseFirestore.instance;
    if (!isFamily) {
      // My Bookings
      final snap =
      await firestore
          .collection('users')
          .doc(uid)
          .collection('bookings')
          .get();
      return snap.docs.map((doc) => doc.data()).toList();
    } else {
      // Family Bookings
      final familySnap =
      await firestore
          .collection('users')
          .doc(uid)
          .collection('family')
          .get();
      List<Map<String, dynamic>> allBookings = [];
      for (final famDoc in familySnap.docs) {
        final bookingsSnap =
        await firestore
            .collection('users')
            .doc(uid)
            .collection('family')
            .doc(famDoc.id)
            .collection('bookings')
            .get();
        allBookings.addAll(bookingsSnap.docs.map((doc) => doc.data()));
      }
      return allBookings;
    }
  }
}
