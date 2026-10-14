import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../models/damage_report.dart';
import '../models/report_filters.dart';
import 'storage_service.dart';

/// Summary numbers shown on the admin dashboard.
class ReportStats {
  const ReportStats({
    required this.total,
    required this.pending,
    required this.accepted,
    required this.urgent,
    required this.underAction,
    required this.resolved,
    required this.rejected,
  });

  final int total;
  final int pending;
  final int accepted;
  final int urgent;
  final int underAction;
  final int resolved;
  final int rejected;
}

/// Single source of truth for all damage reports.
///
/// Right now data is kept in memory and saved to local storage. To connect a
/// real backend, replace the calls to [_storage] in this class with API calls
/// - screens only talk to this service, so they won't need to change.
class ReportService extends ChangeNotifier {
  ReportService(this._storage);

  final StorageService _storage;

  List<DamageReport> _reports = [];
  List<String> _myIds = [];

  List<DamageReport> get reports => List.unmodifiable(_reports);

  /// Reports submitted from this device (used by the resident status screen).
  List<DamageReport> get myReports {
    final list = <DamageReport>[];
    for (final id in _myIds) {
      final r = byId(id);
      if (r != null) list.add(r);
    }
    list.sort((a, b) => b.dateSubmitted.compareTo(a.dateSubmitted));
    return list;
  }

  DamageReport? byId(String id) {
    for (final r in _reports) {
      if (r.id == id) return r;
    }
    return null;
  }

  ReportStats get stats {
    int count(ReportFilter f) => _reports.where(f.matches).length;
    return ReportStats(
      total: _reports.length,
      pending: count(ReportFilter.pending),
      accepted: count(ReportFilter.accepted),
      urgent: count(ReportFilter.urgent),
      underAction: count(ReportFilter.inProgress),
      resolved: count(ReportFilter.resolved),
      rejected: count(ReportFilter.rejected),
    );
  }

  /// Urgent reports that still need attention, pending ones first.
  List<DamageReport> get priorityQueue {
    final list = _reports.where((r) => r.isUrgentActive).toList();
    list.sort((a, b) {
      final p = (a.status.isPending ? 0 : 1).compareTo(b.status.isPending ? 0 : 1);
      if (p != 0) return p;
      final u = a.urgency.rank.compareTo(b.urgency.rank);
      if (u != 0) return u;
      return b.dateSubmitted.compareTo(a.dateSubmitted);
    });
    return list;
  }

  // ---- Loading ----------------------------------------------------------------

  Future<void> load() async {
    // First launch: the list is empty. Reports only come from the user form.
    final stored = _storage.loadReports() ?? [];
    _reports = stored.map((r) {
      final photo = _storage.loadPhoto(r.id);
      return photo == null ? r : r.copyWith(photoBase64: photo);
    }).toList();
    _myIds = _storage.loadMyReportIds();
    notifyListeners();
  }

  /// Used by pull-to-refresh. With a backend this would re-fetch from the API.
  Future<void> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await load();
  }

  // ---- Resident actions ---------------------------------------------------------

  Future<DamageReport> submitReport({
    required Uint8List photoBytes,
    required String barangay,
    required String purok,
    required String specificLocation,
    required DamageType damageType,
    String? otherDamageText,
    required Urgency urgency,
    required String description,
    String? reporterName,
    String? contactNumber,
  }) async {
    final seq = await _storage.nextSequence();
    final id = 'DAS-${DateTime.now().year}-${seq.toString().padLeft(4, '0')}';
    final photoBase64 = base64Encode(photoBytes);
    // Save the actual user image locally first.
    await _storage.savePhoto(id, photoBase64);
    final report = DamageReport(
      id: id,
      photoBase64: photoBase64,
      barangay: barangay,
      purok: purok,
      specificLocation: specificLocation,
      damageType: damageType,
      otherDamageText: otherDamageText,
      urgency: urgency,
      description: description,
      reporterName: _clean(reporterName),
      contactNumber: _clean(contactNumber),
      dateSubmitted: DateTime.now(),
      // Every new report starts as Submitted = Pending / Unverified.
      status: ReportStatus.submitted,
    );
    _reports.insert(0, report);
    _myIds.insert(0, report.id);
    await _persist();
    await _storage.saveMyReportIds(_myIds);
    notifyListeners();
    return report;
  }

  // ---- Admin actions ---------------------------------------------------------------

  Future<void> acceptReport(String id) => updateStatus(id, ReportStatus.accepted);

  Future<void> rejectReport(String id) => updateStatus(id, ReportStatus.rejected);

  Future<void> updateStatus(String id, ReportStatus status) async {
    _replace(id, (r) => r.copyWith(status: status));
    await _persist();
    notifyListeners();
  }

  /// Assigns a team. If the report was only accepted, it moves to
  /// "Worker Assigned" automatically.
  Future<void> assignTeam(String id, String teamName) async {
    _replace(id, (r) {
      final advance = r.status == ReportStatus.accepted ||
          r.status == ReportStatus.actionRequired;
      return r.copyWith(
        assignedTeam: teamName,
        status: advance ? ReportStatus.workerAssigned : r.status,
      );
    });
    await _persist();
    notifyListeners();
  }

  Future<void> deleteReport(String id) async {
    _reports.removeWhere((r) => r.id == id);
    _myIds.remove(id);
    await _storage.deletePhoto(id);
    DamageReport.evictPhoto(id);
    await _persist();
    await _storage.saveMyReportIds(_myIds);
    notifyListeners();
  }

  /// Removes every report (used from Settings).
  Future<void> clearAllReports() async {
    for (final r in _reports) {
      await _storage.deletePhoto(r.id);
      DamageReport.evictPhoto(r.id);
    }
    _reports = [];
    _myIds = [];
    await _storage.resetSequence(0);
    await _persist();
    await _storage.saveMyReportIds(_myIds);
    notifyListeners();
  }

  // ---- Helpers ----------------------------------------------------------------------

  void _replace(String id, DamageReport Function(DamageReport) update) {
    final i = _reports.indexWhere((r) => r.id == id);
    if (i != -1) _reports[i] = update(_reports[i]);
  }

  Future<void> _persist() => _storage.saveReports(_reports);

  String? _clean(String? v) {
    final t = v?.trim() ?? '';
    return t.isEmpty ? null : t;
  }
}
