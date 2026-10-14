import 'package:flutter/material.dart';

import '../models/damage_report.dart';

/// Shows the photo the resident submitted (stored locally as bytes).
/// Pass [height] = null for natural sizing (used by the full-screen viewer).
class ReportPhoto extends StatelessWidget {
  const ReportPhoto({
    super.key,
    required this.report,
    this.height = 220,
    this.fit = BoxFit.cover,
    this.borderRadius = 16,
    this.cacheWidth = 900,
  });

  final DamageReport report;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  /// Decode width in pixels. Smaller = faster. Use null for full quality.
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final bytes = report.photoBytes;
    final Widget content = bytes == null
        ? _placeholder(context)
        : Image.memory(
            bytes,
            fit: fit,
            width: double.infinity,
            height: height,
            cacheWidth: cacheWidth,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _placeholder(context),
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: content,
    );
  }

  Widget _placeholder(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final box = Container(
      width: double.infinity,
      color: cs.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 40, color: cs.onSurfaceVariant),
          const SizedBox(height: 8),
          Text('Photo not available',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
    return height == null
        ? AspectRatio(aspectRatio: 4 / 3, child: box)
        : SizedBox(height: height, child: box);
  }
}

/// Small square preview used on report cards.
class ReportThumbnail extends StatelessWidget {
  const ReportThumbnail({super.key, required this.report, this.size = 64});

  final DamageReport report;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bytes = report.photoBytes;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: bytes == null
            ? Container(
                color: cs.surfaceContainerHighest,
                child: Icon(Icons.image_not_supported, color: cs.onSurfaceVariant),
              )
            : Image.memory(
                bytes,
                fit: BoxFit.cover,
                cacheWidth: 200,
                gaplessPlayback: true,
              ),
      ),
    );
  }
}
