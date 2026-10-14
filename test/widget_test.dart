import 'package:damage_assessment_system/models/damage_report.dart';
import 'package:damage_assessment_system/models/report_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final report = DamageReport(
    id: 'DAS-2026-0001',
    barangay: 'Poblacion',
    purok: '3',
    specificLocation: 'Near the public market',
    damageType: DamageType.blockedRoad,
    urgency: Urgency.immediate,
    description: 'Road is blocked by a fallen wall.',
    dateSubmitted: DateTime(2026, 10, 4),
  );

  test('report survives a JSON round trip', () {
    final copy = DamageReport.fromJson(report.toJson());
    expect(copy.id, report.id);
    expect(copy.damageType, DamageType.blockedRoad);
    expect(copy.status, ReportStatus.submitted);
  });

  test('photo survives a JSON round trip', () {
    final withPhoto = DamageReport(
      id: 'DAS-2026-0002',
      photoBase64: 'AQID',
      barangay: 'Test',
      purok: '1',
      specificLocation: 'Somewhere near',
      damageType: DamageType.landslide,
      urgency: Urgency.urgent,
      description: 'A landslide covered the road.',
      dateSubmitted: DateTime(2026, 10, 4),
    );
    final copy = DamageReport.fromJson(withPhoto.toJson());
    expect(copy.photoBytes, [1, 2, 3]);
  });

  test('new reports are pending and unverified', () {
    expect(report.status.isPending, isTrue);
    expect(report.status.isVerified, isFalse);
    expect(ReportFilter.urgent.matches(report), isTrue);
  });
}
