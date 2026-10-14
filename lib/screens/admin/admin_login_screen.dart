import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_helpers.dart';
import 'admin_shell.dart';

/// Login screen for municipality staff.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthService>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);

    final ok = await auth.login(_username.text, _password.text);
    if (!mounted) return;

    if (ok) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          backgroundColor: Color(0xFF1B5E20),
          content: Text('Login successful', style: TextStyle(color: Colors.white)),
        ));
      navigator.pushReplacement(MaterialPageRoute(builder: (_) => const AdminShell()));
    } else {
      setState(() {
        _loading = false;
        _error = 'Invalid username or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            // ---- Branded header -------------------------------------------------
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12, topPadding + 4, 12, 28),
              decoration: const BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: 'Back to resident app',
                    color: Colors.white,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Center(child: AppLogo(width: 210)),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock, size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text('Authorized personnel only',
                            style: text.bodyMedium?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---- Form -------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Administrator Login', style: text.headlineSmall),
                    const SizedBox(height: 4),
                    Text('Review reports and coordinate response teams.',
                        style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 20),
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.error.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: cs.error),
                            const SizedBox(width: 10),
                            Expanded(child: Text(_error!, style: text.bodyMedium)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _username,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: appInputDecoration(context,
                          label: 'Username', icon: Icons.person),
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'Enter your username' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: appInputDecoration(context,
                              label: 'Password', icon: Icons.lock)
                          .copyWith(
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Enter your password' : null,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: 'Login',
                      icon: Icons.login,
                      loading: _loading,
                      onPressed: _login,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
