import 'package:flutter/material.dart';

/// A municipality team that can be assigned to a report.
class Worker {
  const Worker({
    required this.name,
    required this.description,
    required this.icon,
    required this.contact,
  });

  final String name;
  final String description;
  final IconData icon;
  final String contact;

  /// Sample teams for the prototype. Replace with an API call later.
  static const List<Worker> all = [
    Worker(
      name: 'Road Maintenance Team',
      description: 'Road repairs, potholes, and pavement damage.',
      icon: Icons.construction,
      contact: '(036) 555-0101',
    ),
    Worker(
      name: 'Disaster Response Team',
      description: 'Floods, landslides, and other disaster incidents.',
      icon: Icons.health_and_safety,
      contact: '(036) 555-0102',
    ),
    Worker(
      name: 'Municipal Engineering Team',
      description: 'Bridges, buildings, and structural assessments.',
      icon: Icons.engineering,
      contact: '(036) 555-0103',
    ),
    Worker(
      name: 'Public Works Team',
      description: 'Drainage, public facilities, and general repairs.',
      icon: Icons.construction,
      contact: '(036) 555-0104',
    ),
    Worker(
      name: 'Emergency Clearing Team',
      description: 'Fallen trees, debris, and blocked roads.',
      icon: Icons.engineering,
      contact: '(036) 555-0105',
    ),
  ];
}
