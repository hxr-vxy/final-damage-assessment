import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_helpers.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  Future<void> _clearAll(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete all reports?',
      message: 'Every report saved on this device will be permanently removed.',
      confirmLabel: 'Delete all',
      icon: Icons.delete_outline,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    await context.read<ReportService>().clearAllReports();
    if (context.mounted) showFeedback(context, 'All reports deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeService>();
    final auth = context.watch<AuthService>();
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: cs.primary.withOpacity(0.12),
                child: Icon(Icons.person, color: cs.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Signed in as ${auth.username}', style: text.titleSmall),
                    Text('Municipal administrator',
                        style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Appearance', style: text.titleMedium),
        const SizedBox(height: 10),
        AppCard(
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                    label: Text('System')),
                ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Light')),
                ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Dark')),
              ],
              selected: {theme.mode},
              onSelectionChanged: (s) => theme.setMode(s.first),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Data', style: text.titleMedium),
        const SizedBox(height: 10),
        AppCard(
          onTap: () => _clearAll(context),
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: cs.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delete all reports', style: text.titleSmall),
                    Text('Remove every report saved on this device.',
                        style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('About', style: text.titleMedium),
        const SizedBox(height: 10),
        AppCard(
          child: Text(
            'Damage Assessment System v1.1.0\nReports are saved locally on this device.',
            style: text.bodyMedium,
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          label: 'Logout',
          icon: Icons.logout,
          kind: ButtonKind.dangerOutline,
          onPressed: onLogout,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
