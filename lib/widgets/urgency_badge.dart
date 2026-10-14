import 'package:flutter/material.dart';

import '../models/damage_report.dart';
import 'pill.dart';

/// Shows how urgent a report is (icon + text + color).
class UrgencyBadge extends StatelessWidget {
  const UrgencyBadge({super.key, required this.urgency});

  final Urgency urgency;

  @override
  Widget build(BuildContext context) =>
      Pill(label: urgency.label, icon: urgency.icon, color: urgency.color);
}
