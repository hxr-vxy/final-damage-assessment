import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/damage_report_card.dart';
import '../../widgets/icon_badge.dart';
import '../admin/admin_login_screen.dart';
import '../admin/admin_shell.dart';
import 'report_damage_screen.dart';
import 'report_status_screen.dart';

/// Home screen for residents. No login needed.
class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  void _openAdmin(BuildContext context) {
    final loggedIn = context.read<AuthService>().isLoggedIn;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => loggedIn ? const AdminShell() : const AdminLoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final my = context.watch<ReportService>().myReports;
    final text = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ---- Header (logo on the brand navy panel) ---------------------
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(12, topPadding + 4, 12, 28),
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Toggle light / dark mode',
                          color: Colors.white,
                          icon: Icon(Theme.of(context).brightness == Brightness.dark
                              ? Icons.light_mode
                              : Icons.dark_mode),
                          onPressed: () => context
                              .read<ThemeService>()
                              .toggle(Theme.of(context).brightness),
                        ),
                        IconButton(
                          tooltip: 'Municipality staff login',
                          color: Colors.white,
                          icon: const Icon(Icons.admin_panel_settings),
                          onPressed: () => _openAdmin(context),
                        ),
                      ],
                    ),
                    const AppLogo(width: 230),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        appTagline,
                        textAlign: TextAlign.center,
                        style: text.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      label: 'Report a Damage',
                      icon: Icons.report_problem,
                      kind: ButtonKind.warning,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportDamageScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: my.isEmpty ? 'My Reports' : 'My Reports (${my.length})',
                      icon: Icons.assignment,
                      kind: ButtonKind.outline,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportStatusScreen()),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Safety note
                    AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.phone_in_talk, color: tintFor(context, AppColors.red)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'In a life-threatening emergency, call 911 or your local '
                              'disaster office first. Then submit a report here.',
                              style: text.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('How it works', style: text.titleMedium),
                    const SizedBox(height: 10),
                    const _HowItWorksStep(
                      number: 1,
                      icon: Icons.camera_alt,
                      title: 'Take a photo',
                      subtitle: 'Show the damaged or dangerous area.',
                    ),
                    const _HowItWorksStep(
                      number: 2,
                      icon: Icons.location_on,
                      title: 'Tell us where',
                      subtitle: 'Barangay, purok, and a short location hint.',
                    ),
                    const _HowItWorksStep(
                      number: 3,
                      icon: Icons.check_circle,
                      title: 'Submit and track',
                      subtitle: 'The municipality reviews it and updates the status.',
                    ),

                    if (my.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Your recent reports', style: text.titleMedium),
                      const SizedBox(height: 10),
                      for (final r in my.take(2))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DamageReportCard(
                            report: r,
                            compact: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ReportStatusScreen()),
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final int number;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, size: 36, circle: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$number. $title', style: text.titleSmall),
                Text(subtitle,
                    style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
