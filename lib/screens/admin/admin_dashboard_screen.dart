import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/damage_report.dart';
import '../../models/report_filters.dart';
import '../../services/report_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/damage_report_card.dart';
import '../../widgets/empty_state.dart';
import 'report_details_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, required this.onOpenFilter});

  /// Switches to the Reports tab with a filter applied.
  final ValueChanged<ReportFilter> onOpenFilter;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ReportService>();
    final stats = service.stats;
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final priority = service.priorityQueue.take(3).toList();

    // Count reports per damage type for the small bar chart.
    final byType = <DamageType, int>{};
    for (final r in service.reports) {
      byType[r.damageType] = (byType[r.damageType] ?? 0) + 1;
    }
    final typeEntries = byType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = typeEntries.isEmpty ? 1 : typeEntries.first.value;

    return RefreshIndicator(
      onRefresh: service.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const LogoMark(size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Damage Assessment Dashboard',
                          style: text.titleMedium?.copyWith(color: Colors.white)),
                      Text(formatDate(DateTime.now()),
                          style: text.bodySmall?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(builder: (context, c) {
            final w = (c.maxWidth - 12) / 2;
            Widget card(String title, int value, IconData icon, Color color,
                    ReportFilter f) =>
                SizedBox(
                  width: w,
                  child: DashboardCard(
                    title: title,
                    value: value,
                    icon: icon,
                    color: color,
                    onTap: () => onOpenFilter(f),
                  ),
                );
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                card('Total Reports', stats.total, Icons.assignment,
                    AppColors.navyLight, ReportFilter.all),
                card('Pending', stats.pending, Icons.pending_actions,
                    AppColors.orangeDeep, ReportFilter.pending),
                card('Accepted', stats.accepted, Icons.check_circle,
                    AppColors.teal, ReportFilter.accepted),
                card('Urgent', stats.urgent, Icons.priority_high,
                    AppColors.red, ReportFilter.urgent),
                card('Under Action', stats.underAction, Icons.autorenew,
                    const Color(0xFF0277BD), ReportFilter.inProgress),
                card('Resolved', stats.resolved, Icons.task_alt,
                    AppColors.green, ReportFilter.resolved),
              ],
            );
          }),

          if (stats.total == 0) ...[
            const SizedBox(height: 24),
            const AppCard(
              child: EmptyState(
                icon: Icons.assignment,
                title: 'No Damage Reports Yet',
                message: 'Reports submitted by residents\nwill appear here for assessment.',
              ),
            ),
          ] else ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Text('Needs attention', style: text.titleMedium)),
              if (service.priorityQueue.length > 3)
                TextButton(
                  onPressed: () => onOpenFilter(ReportFilter.urgent),
                  child: const Text('View all urgent'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (priority.isEmpty)
            AppCard(
              child: Row(
                children: [
                  Icon(Icons.verified_outlined, color: tintFor(context, AppColors.green)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('No urgent reports right now.', style: text.bodyMedium),
                  ),
                ],
              ),
            )
          else
            for (final r in priority)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DamageReportCard(
                  report: r,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ReportDetailsScreen(reportId: r.id)),
                  ),
                ),
              ),

          const SizedBox(height: 12),
          Text('Reports by damage type', style: text.titleMedium),
          const SizedBox(height: 8),
          AppCard(
            child: typeEntries.isEmpty
                ? Text('No data yet.', style: text.bodyMedium)
                : Column(
                    children: [
                      for (final e in typeEntries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(e.key.icon, size: 18, color: cs.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 5,
                                child: Text(e.key.label,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodyMedium),
                              ),
                              Expanded(
                                flex: 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: e.value / maxCount,
                                    minHeight: 8,
                                    backgroundColor: cs.surfaceContainerHighest,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 28,
                                child: Text('${e.value}',
                                    textAlign: TextAlign.end, style: text.titleSmall),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
