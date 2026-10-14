import 'damage_report.dart';

/// Filter chips shown on the admin reports screen.
enum ReportFilter {
  all('All'),
  pending('Pending'),
  accepted('Accepted'),
  urgent('Urgent'),
  inProgress('In Progress'),
  resolved('Resolved'),
  rejected('Rejected');

  const ReportFilter(this.label);
  final String label;

  bool matches(DamageReport r) {
    switch (this) {
      case ReportFilter.all:
        return true;
      case ReportFilter.pending:
        return r.status.isPending;
      case ReportFilter.accepted:
        return r.status == ReportStatus.accepted ||
            r.status == ReportStatus.actionRequired ||
            r.status == ReportStatus.workerAssigned;
      case ReportFilter.urgent:
        return r.isUrgentActive;
      case ReportFilter.inProgress:
        return r.status == ReportStatus.workerAssigned ||
            r.status == ReportStatus.inProgress;
      case ReportFilter.resolved:
        return r.status == ReportStatus.resolved;
      case ReportFilter.rejected:
        return r.status == ReportStatus.rejected;
    }
  }
}

enum ReportSort {
  newest('Newest'),
  oldest('Oldest'),
  mostUrgent('Most urgent'),
  status('Status');

  const ReportSort(this.label);
  final String label;

  int compare(DamageReport a, DamageReport b) {
    final newestFirst = b.dateSubmitted.compareTo(a.dateSubmitted);
    switch (this) {
      case ReportSort.newest:
        return newestFirst;
      case ReportSort.oldest:
        return a.dateSubmitted.compareTo(b.dateSubmitted);
      case ReportSort.mostUrgent:
        // Closed reports sink to the bottom.
        final ka = (a.status.isClosed ? 10 : 0) + a.urgency.rank;
        final kb = (b.status.isClosed ? 10 : 0) + b.urgency.rank;
        final c = ka.compareTo(kb);
        return c != 0 ? c : newestFirst;
      case ReportSort.status:
        final c = a.status.sortOrder.compareTo(b.status.sortOrder);
        return c != 0 ? c : newestFirst;
    }
  }
}
