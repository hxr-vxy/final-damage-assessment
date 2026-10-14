import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/damage_report.dart';
import '../../services/photo_service.dart';
import '../../services/report_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_helpers.dart';
import '../../widgets/urgency_badge.dart';
import 'report_success_screen.dart';

/// The damage report form. Fields keep their values when validation fails.
class ReportDamageScreen extends StatefulWidget {
  const ReportDamageScreen({super.key});

  @override
  State<ReportDamageScreen> createState() => _ReportDamageScreenState();
}

class _ReportDamageScreenState extends State<ReportDamageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _photoKey = GlobalKey();
  final _photoService = PhotoService();

  final _barangay = TextEditingController();
  final _purok = TextEditingController();
  final _location = TextEditingController();
  final _other = TextEditingController();
  final _description = TextEditingController();
  final _name = TextEditingController();
  final _contact = TextEditingController();

  Uint8List? _photoBytes;
  bool _photoError = false;
  DamageType? _damageType;
  Urgency? _urgency;
  bool _submitting = false;

  @override
  void dispose() {
    for (final c in [_barangay, _purok, _location, _other, _description, _name, _contact]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---- Photo ---------------------------------------------------------------------

  Future<void> _pickPhoto(PhotoSource source) async {
    try {
      final bytes = await _photoService.pick(source);
      if (bytes != null && mounted) {
        setState(() {
          _photoBytes = bytes;
          _photoError = false;
        });
      }
    } on PhotoTooLargeException catch (e) {
      if (mounted) showFeedback(context, e.toString(), isError: true);
    } catch (e) {
      debugPrint('Photo pick failed: $e');
      if (mounted) {
        showFeedback(
          context,
          source == PhotoSource.camera
              ? 'Could not open the camera. Please check app permissions.'
              : 'Could not open the gallery. Please check app permissions.',
          isError: true,
        );
      }
    }
  }

  // ---- Validators --------------------------------------------------------------------

  String? _validateBarangay(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Please enter the barangay name.';
    if (t.length < 2) return 'Barangay name is too short.';
    return null;
  }

  String? _validatePurok(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Please enter the purok number.';
    if (!RegExp(r'^\d+$').hasMatch(t)) return 'Please enter numbers only.';
    if (int.parse(t) < 1) return 'Purok number must be 1 or higher.';
    return null;
  }

  String? _validateLocation(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Please describe the specific location.';
    if (t.length < 5) return 'Please add a little more detail about the location.';
    return null;
  }

  String? _validateDescription(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Please describe the damage.';
    if (t.length < 15) return 'Please write at least 15 characters.';
    return null;
  }

  /// Optional. Accepts Philippine mobile numbers (09171234567, +639171234567,
  /// 639171234567) and local landlines (e.g. 0362345678).
  String? _validateContact(String? v) {
    final t = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (t.isEmpty) return null;
    if (!RegExp(r'^(\+63|63|0)\d{9,10}$').hasMatch(t)) {
      return 'Please enter a valid contact number (e.g. 09171234567).';
    }
    return null;
  }

  String? _validateName(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    if (t.length < 2) return 'Please enter your full name.';
    return null;
  }

  // ---- Submit --------------------------------------------------------------------------

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();
    final hasPhoto = _photoBytes != null;
    if (!hasPhoto) {
      setState(() => _photoError = true);
      final ctx = _photoKey.currentContext;
      if (ctx != null) {
        await Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 300), alignment: 0.1);
      }
    }

    if (!formValid || !hasPhoto) {
      if (!mounted) return;
      showFeedback(
        context,
        !hasPhoto
            ? 'Please add a photo of the affected area.'
            : 'Please fix the highlighted fields.',
        isError: true,
        icon: Icons.warning,
      );
      return;
    }

    final service = context.read<ReportService>();
    final navigator = Navigator.of(context);
    setState(() => _submitting = true);

    try {
      final report = await service.submitReport(
        photoBytes: _photoBytes!,
        barangay: _barangay.text.trim(),
        purok: _purok.text.trim(),
        specificLocation: _location.text.trim(),
        damageType: _damageType!,
        otherDamageText: _damageType == DamageType.other ? _other.text.trim() : null,
        urgency: _urgency!,
        description: _description.text.trim(),
        reporterName: _name.text,
        contactNumber: _contact.text,
      );
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => ReportSuccessScreen(report: report)),
      );
    } catch (e, st) {
      debugPrint('Submit failed: $e\n$st');
      if (!mounted) return;
      setState(() => _submitting = false);
      showFeedback(context, 'Could not save the report. Please try again.', isError: true);
    }
  }

  // ---- UI --------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Report a Damage')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---- Photo
                SectionTitle(
                  key: _photoKey,
                  icon: Icons.photo_camera,
                  title: 'Photo of the affected area *',
                  subtitle: 'A clear photo helps the municipality assess the damage.',
                ),
                _buildPhotoArea(context),
                const SizedBox(height: 12),

                // ---- Location
                const SectionTitle(icon: Icons.location_on, title: 'Location'),
                TextFormField(
                  controller: _barangay,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: 50,
                  buildCounter: hideCounter,
                  decoration: appInputDecoration(context,
                      label: 'Barangay *',
                      hint: 'Enter exact barangay name',
                      icon: Icons.location_city),
                  validator: _validateBarangay,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _purok,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 3,
                  buildCounter: hideCounter,
                  decoration: appInputDecoration(context,
                      label: 'Purok No. *',
                      hint: 'e.g. 3',
                      prefixText: 'Purok ',
                      icon: Icons.home_work),
                  validator: _validatePurok,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _location,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  maxLength: 120,
                  buildCounter: hideCounter,
                  decoration: appInputDecoration(context,
                      label: 'Specific location *',
                      hint: 'e.g. Near the public market entrance',
                      icon: Icons.place),
                  validator: _validateLocation,
                ),
                const SizedBox(height: 16),

                // ---- Damage info
                const SectionTitle(icon: Icons.report_problem, title: 'Damage details'),
                DropdownButtonFormField<DamageType>(
                  value: _damageType,
                  isExpanded: true,
                  decoration: appInputDecoration(context,
                      label: 'Type of damage *', icon: Icons.report_problem),
                  items: [
                    for (final t in DamageType.values)
                      DropdownMenuItem(
                        value: t,
                        child: Text(t.label, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => _damageType = v),
                  validator: (v) => v == null ? 'Please select the type of damage.' : null,
                ),
                if (_damageType == DamageType.other) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _other,
                    maxLength: 60,
                    buildCounter: hideCounter,
                    decoration: appInputDecoration(context,
                        label: 'Please specify *', hint: 'What kind of damage is it?'),
                    validator: (v) => (v?.trim().isEmpty ?? true)
                        ? 'Please tell us what kind of damage it is.'
                        : null,
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<Urgency>(
                  value: _urgency,
                  isExpanded: true,
                  decoration: appInputDecoration(context,
                      label: 'How urgent is it? *', icon: Icons.priority_high),
                  items: [
                    for (final u in Urgency.values)
                      DropdownMenuItem(
                        value: u,
                        child: Text(u.label, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => _urgency = v),
                  validator: (v) => v == null ? 'Please select how urgent it is.' : null,
                ),
                if (_urgency != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: UrgencyBadge(urgency: _urgency!),
                  ),
                ],
                if (_urgency == Urgency.immediate) ...[
                  const SizedBox(height: 8),
                  Text(
                    'If someone is in danger, also call 911 or your local disaster office.',
                    style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: appInputDecoration(
                    context,
                    label: 'Description of the damage *',
                    hint: 'What happened? Is the road still passable? Any danger?',
                    icon: Icons.notes,
                  ),
                  validator: _validateDescription,
                ),
                const SizedBox(height: 12),

                // ---- Optional info
                const SectionTitle(
                  icon: Icons.person,
                  title: 'Your information (optional)',
                  subtitle: 'Helps the municipality contact you if needed.',
                ),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: 60,
                  buildCounter: hideCounter,
                  decoration: appInputDecoration(context, label: 'Name', icon: Icons.person),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contact,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]'))],
                  maxLength: 16,
                  buildCounter: hideCounter,
                  decoration: appInputDecoration(context,
                      label: 'Contact number',
                      hint: '09171234567',
                      icon: Icons.phone),
                  validator: _validateContact,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Submit Report',
                  icon: Icons.send,
                  loading: _submitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                Text(
                  'Reports are reviewed by the municipality before action is taken.',
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoArea(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Preview with Change / Remove.
    if (_photoBytes != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              _photoBytes!,
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
              cacheWidth: 900,
              gaplessPlayback: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSourceSheet(),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Change Photo'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tintFor(context, AppColors.red),
                  ),
                  onPressed: () => setState(() => _photoBytes = null),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    final errorColor = cs.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _photoError ? errorColor : cs.outlineVariant,
              width: _photoError ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.photo_camera,
                  size: 40, color: _photoError ? errorColor : cs.primary),
              const SizedBox(height: 8),
              Text('No photo selected', style: text.titleSmall),
              if (_photoError)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Please add a photo of the affected area.',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: errorColor),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _pickPhoto(PhotoSource.camera),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Take Photo'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickPhoto(PhotoSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Bottom sheet used by "Change Photo".
  Future<void> _showSourceSheet() async {
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(ctx, PhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, PhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickPhoto(source);
  }
}
