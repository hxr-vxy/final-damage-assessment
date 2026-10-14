import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Looks up an enum value by its name, falling back to [fallback].
T _byName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

/// Type of damage a resident can report.
enum DamageType {
  landslide('Landslide', Icons.terrain),
  flooding('Flooding', Icons.waves),
  fallenTree('Fallen Tree', Icons.park),
  roadDamage('Road Damage', Icons.construction),
  fallenPost('Fallen Electrical Post', Icons.bolt),
  damagedBridge('Damaged Bridge', Icons.architecture),
  blockedRoad('Blocked Road', Icons.block),
  buildingDamage('Building Damage', Icons.apartment),
  drainage('Drainage Problem', Icons.water_drop),
  other('Other', Icons.report_problem);

  const DamageType(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// How quickly the reporter thinks the area needs attention.
/// Each level has text + icon + color so it never relies on color alone.
enum Urgency {
  immediate('Immediate Action Required', Icons.error, Color(0xFFC62828)),
  urgent('Urgent', Icons.warning, Color(0xFFE8710A)),
  within24Hours('Within 24 Hours', Icons.access_time, Color(0xFF9A6700)),
  within3Days('Within 3 Days', Icons.calendar_today, Color(0xFF1565C0)),
  canWait('Can Wait / Non-Urgent', Icons.schedule, Color(0xFF546E7A));

  const Urgency(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;

  /// 0 = most urgent.
  int get rank => index;
}

/// Lifecycle of a report.
enum ReportStatus {
  submitted('Submitted', Icons.pending_actions, Color(0xFF607D8B), 0, 0),
  underReview('Under Review', Icons.visibility, Color(0xFF1565C0), 1, 1),
  accepted('Accepted', Icons.check_circle, Color(0xFF00796B), 2, 3),
  actionRequired('Action Required', Icons.warning, Color(0xFFEF6C00), 2, 2),
  workerAssigned('Worker Assigned', Icons.engineering, Color(0xFF5E35B1), 3, 4),
  inProgress('In Progress', Icons.autorenew, Color(0xFF0277BD), 4, 5),
  resolved('Resolved', Icons.task_alt, Color(0xFF2E7D32), 5, 6),
  rejected('Rejected', Icons.cancel, Color(0xFFC62828), -1, 7);

  const ReportStatus(this.label, this.icon, this.color, this.step, this.sortOrder);
  final String label;
  final IconData icon;
  final Color color;

  /// Position in the progress tracker (-1 = not part of the flow).
  final int step;
  final int sortOrder;

  /// Verified = an administrator has accepted the report.
  bool get isVerified =>
      this == accepted ||
      this == actionRequired ||
      this == workerAssigned ||
      this == inProgress ||
      this == resolved;

  /// Pending / unverified = waiting for an administrator decision.
  bool get isPending => this == submitted || this == underReview;

  bool get isClosed => this == resolved || this == rejected;
}

class DamageReport {
  DamageReport({
    required this.id,
    this.reporterName,
    this.contactNumber,
    this.photoBase64,
    required this.barangay,
    required this.purok,
    required this.specificLocation,
    required this.damageType,
    this.otherDamageText,
    required this.urgency,
    required this.description,
    required this.dateSubmitted,
    this.status = ReportStatus.submitted,
    this.assignedTeam,
  });

  final String id;
  final String? reporterName;
  final String? contactNumber;

  /// The photo the resident selected, stored as Base64 text so it works on
  /// every platform (Android, iOS, web) and needs no file permissions.
  final String? photoBase64;
  final String barangay;
  final String purok;
  final String specificLocation;
  final DamageType damageType;
  final String? otherDamageText;
  final Urgency urgency;
  final String description;
  final DateTime dateSubmitted;
  final ReportStatus status;
  final String? assignedTeam;

  static final Map<String, Uint8List> _photoCache = {};

  /// Decoded photo bytes (decoded once, then cached).
  Uint8List? get photoBytes {
    final b64 = photoBase64;
    if (b64 == null || b64.isEmpty) return null;
    return _photoCache.putIfAbsent(id, () => base64Decode(b64));
  }

  static void evictPhoto(String id) => _photoCache.remove(id);

  String get purokLabel => 'Purok $purok';

  String get damageTitle {
    final extra = otherDamageText?.trim() ?? '';
    if (damageType == DamageType.other && extra.isNotEmpty) {
      return 'Other: $extra';
    }
    return damageType.label;
  }

  /// Urgent (immediate / urgent) and still needs work.
  bool get isUrgentActive => urgency.rank <= 1 && !status.isClosed;

  bool get hasReporterInfo =>
      (reporterName?.trim().isNotEmpty ?? false) ||
      (contactNumber?.trim().isNotEmpty ?? false);

  DamageReport copyWith({
    ReportStatus? status,
    String? assignedTeam,
    String? photoBase64,
    bool clearAssignedTeam = false,
  }) {
    return DamageReport(
      id: id,
      reporterName: reporterName,
      contactNumber: contactNumber,
      photoBase64: photoBase64 ?? this.photoBase64,
      barangay: barangay,
      purok: purok,
      specificLocation: specificLocation,
      damageType: damageType,
      otherDamageText: otherDamageText,
      urgency: urgency,
      description: description,
      dateSubmitted: dateSubmitted,
      status: status ?? this.status,
      assignedTeam: clearAssignedTeam ? null : (assignedTeam ?? this.assignedTeam),
    );
  }

  Map<String, dynamic> toJson({bool includePhoto = true}) => {
        'id': id,
        'reporterName': reporterName,
        'contactNumber': contactNumber,
        if (includePhoto) 'photoBase64': photoBase64,
        'barangay': barangay,
        'purok': purok,
        'specificLocation': specificLocation,
        'damageType': damageType.name,
        'otherDamageText': otherDamageText,
        'urgency': urgency.name,
        'description': description,
        'dateSubmitted': dateSubmitted.toIso8601String(),
        'status': status.name,
        'assignedTeam': assignedTeam,
      };

  factory DamageReport.fromJson(Map<String, dynamic> j) => DamageReport(
        id: j['id'] as String,
        reporterName: j['reporterName'] as String?,
        contactNumber: j['contactNumber'] as String?,
        photoBase64: j['photoBase64'] as String?,
        barangay: j['barangay'] as String,
        purok: j['purok'] as String,
        specificLocation: j['specificLocation'] as String,
        damageType: _byName(DamageType.values, j['damageType'] as String?, DamageType.other),
        otherDamageText: j['otherDamageText'] as String?,
        urgency: _byName(Urgency.values, j['urgency'] as String?, Urgency.urgent),
        description: j['description'] as String,
        dateSubmitted: DateTime.parse(j['dateSubmitted'] as String),
        status: _byName(ReportStatus.values, j['status'] as String?, ReportStatus.submitted),
        assignedTeam: j['assignedTeam'] as String?,
      );
}
