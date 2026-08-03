import 'package:flutter/material.dart';

import 'package:cms/screens/admin_dashboard_screen.dart';
import 'package:cms/screens/coordinator_dashboard_screen.dart';
import 'package:cms/screens/staff_login_screen.dart';
import 'package:cms/services/employee_auth_service.dart';

/// Entry gate for the staff app.
///
/// On launch it restores any saved employee session. If a token exists it
/// routes directly to the correct screen based on the stored role:
///   - admin        → [AdminDashboardScreen]
///   - coordinator / team_leader → [CoordinatorDashboardScreen]
///
/// If no token is found the user is taken to [StaffLoginScreen].
class StaffAuthGate extends StatefulWidget {
  const StaffAuthGate({super.key});

  @override
  State<StaffAuthGate> createState() => _StaffAuthGateState();
}

class _StaffAuthGateState extends State<StaffAuthGate> {
  bool _ready = false;
  Widget? _dest;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final token = await EmployeeAuthService.instance.getToken();
    Widget dest;
    if (token != null) {
      final role = await EmployeeAuthService.instance.getRole();
      dest = role == 'admin'
          ? const AdminDashboardScreen()
          : const CoordinatorDashboardScreen();
    } else {
      dest = const StaffLoginScreen();
    }
    if (mounted) setState(() { _dest = dest; _ready = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _dest!;
  }
}
