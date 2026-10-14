import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/worker.dart';
import '../../services/report_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import 'report_details_screen.dart';

/// Lists municipality teams and the reports assigned to each.
class WorkersScreen extends StatelessWidget {
  const WorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ReportService>();
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Municipality teams', style: text.titleLarge),
        Text('Teams available for assignment',
            style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 12),
        for (final w in Worker.all) ...[
          Builder(builder: (context) {
            final assigned =
                service.reports.where((r) => r.assignedTeam == w.name).toList();
            final active = assigned.where((r) => !r.status.isClosed).toList();
            final done = assigned.length - active.length;

            return AppCard(
              padding: EdgeInsets.zero,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(0.12),
                    child: Icon(w.icon, color: cs.primary),
                  ),
                  title: Text(w.name, style: text.titleSmall),
                  subtitle: Text('${active.length} active · $done completed'),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(w.description, style: text.bodyMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                                                Text(w.contact, style: text.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (assigned.isEmpty)
                      Text('No reports assigned yet.',
                          style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant))
                    else
                      for (final r in assigned)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text('${r.damageTitle} - ${r.barangay}'),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: StatusBadge(status: r.status),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportDetailsScreen(reportId: r.id),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
