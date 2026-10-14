import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/report_filters.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/confirm_dialog.dart';
import 'admin_dashboard_screen.dart';
import 'admin_login_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_settings_screen.dart';
import 'workers_screen.dart';

/// Admin area with a bottom navigation bar:
/// Dashboard | Reports | Workers | Settings (+ Logout in the app bar).
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;
  final ValueNotifier<ReportFilter> _filter = ValueNotifier(ReportFilter.all);

  static const _titles = ['Dashboard', 'Reports', 'Workers', 'Settings'];

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  void _openReports(ReportFilter filter) {
    _filter.value = filter;
    setState(() => _index = 1);
  }

  Future<void> _logout() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmLabel: 'Logout',
      icon: Icons.logout,
    );
    if (!confirmed || !mounted) return;

    final auth = context.read<AuthService>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await auth.logout(); // clears the saved admin session
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      (route) => route.isFirst,
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('You have been logged out.')));
  }

  @override
  Widget build(BuildContext context) {
    final pending = context.select<ReportService, int>((s) => s.stats.pending);

    return Scaffold(
      appBar: AppBar(
        // Logout lives only in Settings, so there is one logout action.
        title: Row(
          children: [
            const LogoMark(size: 34),
            const SizedBox(width: 10),
            Text(_titles[_index]),
          ],
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          AdminDashboardScreen(onOpenFilter: _openReports),
          AdminReportsScreen(filterNotifier: _filter),
          const WorkersScreen(),
          AdminSettingsScreen(onLogout: _logout),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.assignment_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.assignment),
            ),
            label: 'Reports',
          ),
          const NavigationDestination(
            icon: Icon(Icons.engineering_outlined),
            selectedIcon: Icon(Icons.engineering),
            label: 'Workers',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
