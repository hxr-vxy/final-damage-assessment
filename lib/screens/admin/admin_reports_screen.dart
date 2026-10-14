import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/damage_report.dart';
import '../../models/report_filters.dart';
import '../../services/report_service.dart';
import '../../widgets/damage_report_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/form_helpers.dart';
import 'report_details_screen.dart';

/// Searchable, filterable, sortable list of all reports.
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key, required this.filterNotifier});

  /// Lets the dashboard change the active filter.
  final ValueNotifier<ReportFilter> filterNotifier;

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  ReportSort _sort = ReportSort.newest;

  @override
  void initState() {
    super.initState();
    widget.filterNotifier.addListener(_onFilterChanged);
  }

  @override
  void dispose() {
    widget.filterNotifier.removeListener(_onFilterChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged() => setState(() {});

  bool _matchesSearch(DamageReport r) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return r.barangay.toLowerCase().contains(q) ||
        r.purok.toLowerCase().contains(q) ||
        r.purokLabel.toLowerCase().contains(q) ||
        r.damageTitle.toLowerCase().contains(q) ||
        r.specificLocation.toLowerCase().contains(q) ||
        r.id.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ReportService>();
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final filter = widget.filterNotifier.value;

    final visible = service.reports
        .where(filter.matches)
        .where(_matchesSearch)
        .toList()
      ..sort(_sort.compare);

    return Column(
      children: [
        // ---- Search ----------------------------------------------------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v.trim()),
            textInputAction: TextInputAction.search,
            decoration: appInputDecoration(
              context,
              label: 'Search',
              hint: 'Barangay, purok, damage type, location',
              icon: Icons.search,
            ).copyWith(
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
        ),

        // ---- Filter chips ----------------------------------------------------------------
        Row(children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(Icons.filter_list, color: cs.onSurfaceVariant),
          ),
          Expanded(
            child: SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: ReportFilter.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = ReportFilter.values[i];
              final count = service.reports.where(f.matches).length;
              return ChoiceChip(
                label: Text('${f.label} ($count)'),
                avatar: null,
                selected: f == filter,
                onSelected: (_) {
                  widget.filterNotifier.value = f;
                },
              );
            },
          ),
        ),
          ),
        ]),

        // ---- Count + sort ----------------------------------------------------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${visible.length} report${visible.length == 1 ? '' : 's'}',
                  style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              PopupMenuButton<ReportSort>(
                tooltip: 'Sort reports',
                initialValue: _sort,
                onSelected: (s) => setState(() => _sort = s),
                itemBuilder: (_) => [
                  for (final s in ReportSort.values)
                    PopupMenuItem(value: s, child: Text(s.label)),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort, size: 20, color: cs.primary),
                      const SizedBox(width: 6),
                      Text('Sort: ${_sort.label}',
                          style: text.labelLarge?.copyWith(color: cs.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ---- List -----------------------------------------------------------------------------
        Expanded(
          child: RefreshIndicator(
            onRefresh: service.refresh,
            child: visible.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 380,
                        child: service.reports.isEmpty
                            ? const EmptyState(
                                icon: Icons.assignment,
                                title: 'No Damage Reports Yet',
                                message: 'Reports submitted by residents\nwill appear here for assessment.',
                              )
                            : const EmptyState(
                                icon: Icons.search_off,
                                title: 'No matching reports',
                                message: 'Try a different search or filter.',
                              ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => DamageReportCard(
                      report: visible[i],
                      onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => ReportDetailsScreen(reportId: visible[i].id),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
