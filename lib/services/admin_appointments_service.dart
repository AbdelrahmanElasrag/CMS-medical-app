import 'package:cms/services/api_service.dart';

class AdminAppointmentSpeciality {
  final String id;
  final String specialityId;
  final String specialityName;
  final String doctorId;
  final String doctorName;
  final DateTime? scheduledTime;
  final String status;

  const AdminAppointmentSpeciality({
    required this.id,
    required this.specialityId,
    required this.specialityName,
    required this.doctorId,
    required this.doctorName,
    required this.scheduledTime,
    required this.status,
  });

  factory AdminAppointmentSpeciality.fromJson(Map<String, dynamic> j) {
    final specialityMap = j['speciality'] is Map ? Map<String, dynamic>.from(j['speciality'] as Map) : const <String, dynamic>{};
    final doctorMap = j['doctor'] is Map ? Map<String, dynamic>.from(j['doctor'] as Map) : const <String, dynamic>{};
    final scheduledRaw = j['scheduledTime']?.toString();
    return AdminAppointmentSpeciality(
      id: j['id']?.toString() ?? '',
      specialityId: j['specialityId']?.toString() ?? specialityMap['id']?.toString() ?? '',
      specialityName: specialityMap['name']?.toString() ?? j['speciality']?.toString() ?? '—',
      doctorId: j['doctorId']?.toString() ?? doctorMap['id']?.toString() ?? '',
      doctorName: doctorMap['name']?.toString() ?? '—',
      scheduledTime: scheduledRaw == null ? null : DateTime.tryParse(scheduledRaw),
      status: j['status']?.toString() ?? 'scheduled',
    );
  }
}

class AdminAppointment {
  final String id;
  final String patientName;
  final String patientPhone;
  final String hospitalName;
  final DateTime? scheduledDate;
  final String status;
  final String notes;
  final bool isMobileBooking;
  final List<AdminAppointmentSpeciality> appointmentSpecialities;

  const AdminAppointment({
    required this.id,
    required this.patientName,
    required this.patientPhone,
    required this.hospitalName,
    required this.scheduledDate,
    required this.status,
    required this.notes,
    required this.isMobileBooking,
    required this.appointmentSpecialities,
  });

  factory AdminAppointment.fromJson(Map<String, dynamic> j) {
    final patient = j['patient'] is Map ? Map<String, dynamic>.from(j['patient'] as Map) : const <String, dynamic>{};
    final hospital = j['hospital'] is Map ? Map<String, dynamic>.from(j['hospital'] as Map) : const <String, dynamic>{};
    final specList = j['appointmentSpecialities'] as List<dynamic>? ?? const <dynamic>[];
    final scheduledRaw = j['scheduledDate']?.toString();

    return AdminAppointment(
      id: j['id']?.toString() ?? '',
      patientName: patient['nameEnglish']?.toString() ?? patient['name']?.toString() ?? 'Unknown patient',
      patientPhone: patient['phoneNumber']?.toString() ?? '',
      hospitalName: hospital['name']?.toString() ?? '—',
      scheduledDate: scheduledRaw == null ? null : DateTime.tryParse(scheduledRaw),
      status: j['status']?.toString() ?? 'scheduled',
      notes: j['notes']?.toString() ?? '',
      isMobileBooking: j['isMobileBooking'] == true,
      appointmentSpecialities: specList
          .whereType<Map>()
          .map((e) => AdminAppointmentSpeciality.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class AdminAppointmentsPage {
  final List<AdminAppointment> items;
  final int total;
  final int page;
  final int limit;

  const AdminAppointmentsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class AdminAppointmentsService {
  AdminAppointmentsService._();
  static final AdminAppointmentsService instance = AdminAppointmentsService._();

  Future<AdminAppointmentsPage> listAppointments({
    required String token,
    int page = 1,
    int limit = 50,
    String? startDate,
    String? endDate,
  }) async {
    final qp = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
      if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
    };
    final uri = Uri(path: '/appointment', queryParameters: qp).toString();
    final res = await ApiService.instance.getJsonWithBearer(uri, token);

    final rows = _extractList(res);
    final items = rows.map(AdminAppointment.fromJson).toList();
    final total = (res['total'] as num?)?.toInt() ?? items.length;
    final p = (res['page'] as num?)?.toInt() ?? page;
    final l = (res['limit'] as num?)?.toInt() ?? limit;
    return AdminAppointmentsPage(items: items, total: total, page: p, limit: l);
  }

  Future<void> updateAppointmentDate({
    required String token,
    required String appointmentId,
    required DateTime scheduledDateTime,
  }) async {
    await ApiService.instance.putJsonWithBearer(
      '/appointment',
      <String, dynamic>{
        'appointment': <String, dynamic>{
          'id': appointmentId,
          'scheduledDate': scheduledDateTime.toIso8601String(),
        },
      },
      token,
    );
  }

  Future<void> updateAppointmentSpecialityTime({
    required String token,
    required String appointmentId,
    required String appointmentSpecialityId,
    required String doctorId,
    required DateTime scheduledTime,
  }) async {
    await ApiService.instance.patchJsonWithBearer(
      '/appointment/$appointmentId/speciality/$appointmentSpecialityId',
      <String, dynamic>{
        'doctorId': doctorId,
        'scheduledTime': scheduledTime.toIso8601String(),
      },
      token,
    );
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> res) {
    final a = res['appointments'];
    if (a is List) {
      return a.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    final data = res['data'];
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['appointments'] is List) {
      return (data['appointments'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }
}
