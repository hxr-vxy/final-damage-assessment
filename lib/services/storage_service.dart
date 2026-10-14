import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/damage_report.dart';

/// Thin wrapper around SharedPreferences (local storage).
/// Replace or extend this class when a real database / API is available.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _kReports = 'reports_v2';
  static const _kMyReports = 'my_report_ids_v2';
  static const _kAdminSession = 'admin_session_v1';
  static const _kThemeMode = 'theme_mode_v1';
  static const _kSequence = 'report_sequence_v2';

  static Future<StorageService> create() async =>
      StorageService(await SharedPreferences.getInstance());

  // ---- Reports -------------------------------------------------------------

  /// Returns null if nothing has been saved yet (first launch = no reports).
  List<DamageReport>? loadReports() {
    final raw = _prefs.getString(_kReports);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => DamageReport.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null; // corrupted data -> reseed
    }
  }

  /// Report details are saved WITHOUT the photo so that changing a status
  /// never rewrites large image data. Photos are stored under their own key.
  Future<void> saveReports(List<DamageReport> reports) => _prefs.setString(
        _kReports,
        jsonEncode(reports.map((r) => r.toJson(includePhoto: false)).toList()),
      );

  // ---- Photos (Base64 text, one key per report) --------------------------------

  String? loadPhoto(String reportId) => _prefs.getString('photo_v2_$reportId');

  Future<void> savePhoto(String reportId, String base64Data) =>
      _prefs.setString('photo_v2_$reportId', base64Data);

  Future<void> deletePhoto(String reportId) => _prefs.remove('photo_v2_$reportId');

  // ---- Reports submitted from this device ------------------------------------

  List<String> loadMyReportIds() => _prefs.getStringList(_kMyReports) ?? [];

  Future<void> saveMyReportIds(List<String> ids) =>
      _prefs.setStringList(_kMyReports, ids);

  // ---- Report ID sequence ----------------------------------------------------

  Future<int> nextSequence() async {
    final next = (_prefs.getInt(_kSequence) ?? 0) + 1;
    await _prefs.setInt(_kSequence, next);
    return next;
  }

  Future<void> resetSequence(int value) => _prefs.setInt(_kSequence, value);

  // ---- Admin session ---------------------------------------------------------

  bool get isAdminLoggedIn => _prefs.getBool(_kAdminSession) ?? false;

  Future<void> setAdminLoggedIn(bool value) =>
      _prefs.setBool(_kAdminSession, value);

  // ---- Settings --------------------------------------------------------------

  ThemeMode loadThemeMode() {
    final name = _prefs.getString(_kThemeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => ThemeMode.light,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_kThemeMode, mode.name);
}
