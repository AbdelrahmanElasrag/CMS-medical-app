import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AdminScreen extends StatefulWidget {
  final String adminId;
  const AdminScreen({required this.adminId, Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String? scannedId;
  String? parentUserId;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? memberData;
  int scanCount = 0;
  List<String> scanHistory = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadScanHistory();
  }

  Future<void> _loadScanHistory() async {
    final scans = await FirebaseFirestore.instance
        .collection('admin')
        .doc(widget.adminId)
        .collection('scans')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      scanCount = scans.docs.length;
      scanHistory = scans.docs.map((doc) => doc['scannedId'] as String).toList();
    });
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => MobileScannerView()),
    );
    if (result != null && result.isNotEmpty) {
      await _handleScan(result);
    }
  }

  Future<void> _handleScan(String id) async {
    setState(() {
      loading = true;
      scannedId = id;
      userData = null;
      memberData = null;
      parentUserId = null;
    });
    // Try to find as a userId
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(id).get();
    if (userDoc.exists) {
      setState(() {
        userData = userDoc.data();
        parentUserId = id;
        memberData = null;
      });
      await _logScan(id, null);
    } else {
      // Try to find as a family memberId under any user
      final users = await FirebaseFirestore.instance.collection('users').get();
      for (final user in users.docs) {
        final family = await user.reference.collection('family').doc(id).get();
        if (family.exists) {
          setState(() {
            memberData = family.data();
            parentUserId = user.id;
            userData = user.data();
          });
          await _logScan(id, user.id);
          break;
        }
      }
    }
    await _loadScanHistory();
    setState(() {
      loading = false;
    });
  }

  Future<void> _logScan(String scannedId, String? parentUserId) async {
    await FirebaseFirestore.instance
        .collection('admin')
        .doc(widget.adminId)
        .collection('scans')
        .add({
      'scannedId': scannedId,
      'parentUserId': parentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _addSpecialtyOrVisit({required bool isSpecialty}) async {
    if (parentUserId == null) return;
    String targetId = memberData != null ? scannedId! : parentUserId!;
    DocumentReference docRef;
    if (memberData != null) {
      docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(parentUserId)
          .collection('family')
          .doc(targetId);
    } else {
      docRef = FirebaseFirestore.instance.collection('users').doc(targetId);
    }
    final doc = await docRef.get();
    int points = (doc['points'] ?? 0) + 100;
    await docRef.update({'points': points});
    setState(() {
      if (memberData != null) {
        memberData!['points'] = points;
      } else if (userData != null) {
        userData!['points'] = points;
      }
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Color(0xFF00C896),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _scanQRCode,
                icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                label: Text('Scan QR Code', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C896),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            if (loading) Center(child: CircularProgressIndicator()),
            if (!loading && (userData != null || memberData != null)) ...[
              Center(
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Scanned Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF00C896))),
                        SizedBox(height: 12),
                        if (userData != null) ...[
                          Text('User: ${userData!['firstName']} ${userData!['lastName']}', style: TextStyle(fontSize: 16)),
                          Text('Phone: ${userData!['phone']}', style: TextStyle(fontSize: 16)),
                          Text('Points: ${userData!['points'] ?? 0}', style: TextStyle(fontSize: 16)),
                        ],
                        if (memberData != null) ...[
                          Text('Family Member: ${memberData!['firstName']} ${memberData!['lastName']}', style: TextStyle(fontSize: 16)),
                          Text('Relationship: ${memberData!['relationship']}', style: TextStyle(fontSize: 16)),
                          Text('Phone: ${memberData!['phoneNumber']}', style: TextStyle(fontSize: 16)),
                          Text('Points: ${memberData!['points'] ?? 0}', style: TextStyle(fontSize: 16)),
                        ],
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => _addSpecialtyOrVisit(isSpecialty: true),
                              child: Text('Add Specialty (+100)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF00C896),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () => _addSpecialtyOrVisit(isSpecialty: false),
                              child: Text('Confirm Visit (+100)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF00C896),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: 24),
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Scan History (Total: $scanCount):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C896))),
                    SizedBox(height: 8),
                    if (scanHistory.isEmpty)
                      Text('No scans yet.', style: TextStyle(color: Colors.grey)),
                    if (scanHistory.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: scanHistory.length,
                        itemBuilder: (context, i) => ListTile(
                          leading: Icon(Icons.qr_code, color: Color(0xFF00C896)),
                          title: Text(scanHistory[i]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text('Log Out', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C896),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class MobileScannerView extends StatefulWidget {
  @override
  State<MobileScannerView> createState() => _MobileScannerViewState();
}

class _MobileScannerViewState extends State<MobileScannerView> {
  bool scanned = false;
  MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        backgroundColor: Color(0xFF00C896),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: controller,
              onDetect: (barcode) {
                if (!scanned && barcode.barcodes.isNotEmpty && barcode.barcodes.first.rawValue != null) {
                  scanned = true;
                  controller.stop();
                  Navigator.pop(context, barcode.barcodes.first.rawValue);
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Point the camera at a QR code'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}