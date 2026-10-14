import '../models/damage_report.dart';

/// Realistic sample reports so the admin dashboard is never empty on first run.
List<DamageReport> buildSampleReports() {
  final now = DateTime.now();
  final year = now.year;
  String id(int n) => 'DAS-$year-${n.toString().padLeft(4, '0')}';

  return [
    DamageReport(
      id: id(1),
      reporterName: 'Maria Santos',
      contactNumber: '09171234567',
      barangay: 'Poblacion',
      purok: '3',
      specificLocation: 'Near the public market entrance',
      damageType: DamageType.blockedRoad,
      urgency: Urgency.immediate,
      description:
          'A fallen concrete wall is blocking the main road beside the public market. Tricycles cannot pass and people are walking in the middle of the road.',
      dateSubmitted: now.subtract(const Duration(hours: 2)),
      status: ReportStatus.submitted,
    ),
    DamageReport(
      id: id(2),
      reporterName: 'Juan Dela Cruz',
      barangay: 'San Isidro',
      purok: '5',
      specificLocation: 'Along the barangay road going to the highland farms',
      damageType: DamageType.landslide,
      urgency: Urgency.immediate,
      description:
          'The landslide covered approximately half of the road. Vehicles can still pass but only through one side. More soil may fall if it rains again tonight.',
      dateSubmitted: now.subtract(const Duration(hours: 6)),
      status: ReportStatus.underReview,
    ),
    DamageReport(
      id: id(3),
      barangay: 'San Vicente',
      purok: '2',
      specificLocation: 'Beside the barangay hall',
      damageType: DamageType.fallenTree,
      urgency: Urgency.urgent,
      description:
          'A large acacia tree fell across the road after last night\'s strong wind. It is also touching a nearby electric wire.',
      dateSubmitted: now.subtract(const Duration(hours: 20)),
      status: ReportStatus.submitted,
    ),
    DamageReport(
      id: id(4),
      reporterName: 'Ana Reyes',
      contactNumber: '09281234567',
      barangay: 'San Jose',
      purok: '4',
      specificLocation: 'Main road in front of the elementary school',
      damageType: DamageType.flooding,
      urgency: Urgency.within24Hours,
      description:
          'Knee-deep flood water on the road in front of the school. Students have difficulty going to class.',
      dateSubmitted: now.subtract(const Duration(days: 1, hours: 4)),
      status: ReportStatus.accepted,
    ),
    DamageReport(
      id: id(5),
      reporterName: 'Pedro Lim',
      barangay: 'Santa Cruz',
      purok: '1',
      specificLocation: 'Small bridge connecting Purok 1 and Purok 2',
      damageType: DamageType.damagedBridge,
      urgency: Urgency.urgent,
      description:
          'The bridge railing has collapsed and there are cracks on the concrete deck. Heavy vehicles should not cross.',
      dateSubmitted: now.subtract(const Duration(days: 2, hours: 3)),
      status: ReportStatus.inProgress,
      assignedTeam: 'Municipal Engineering Team',
    ),
    DamageReport(
      id: id(6),
      reporterName: 'Liza Gomez',
      contactNumber: '09391234567',
      barangay: 'San Roque',
      purok: '6',
      specificLocation: 'Corner of the highway and the chapel road',
      damageType: DamageType.fallenPost,
      urgency: Urgency.immediate,
      description:
          'An electrical post leaned and fell on the roadside. Wires are hanging low. Please send a team immediately.',
      dateSubmitted: now.subtract(const Duration(days: 3, hours: 1)),
      status: ReportStatus.workerAssigned,
      assignedTeam: 'Emergency Clearing Team',
    ),
    DamageReport(
      id: id(7),
      barangay: 'Poblacion',
      purok: '1',
      specificLocation: 'Drainage canal behind the plaza',
      damageType: DamageType.drainage,
      urgency: Urgency.within3Days,
      description:
          'The drainage canal is clogged with mud and garbage. Water backs up to the street whenever it rains.',
      dateSubmitted: now.subtract(const Duration(days: 6)),
      status: ReportStatus.resolved,
      assignedTeam: 'Public Works Team',
    ),
    DamageReport(
      id: id(8),
      reporterName: 'Anonymous',
      barangay: 'Bagong Silang',
      purok: '7',
      specificLocation: 'In front of my house',
      damageType: DamageType.roadDamage,
      urgency: Urgency.canWait,
      description:
          'There is a giant hole that swallowed my slipper lol. Nothing is actually wrong with the road.',
      dateSubmitted: now.subtract(const Duration(days: 5, hours: 8)),
      status: ReportStatus.rejected,
    ),
  ];
}
