import 'package:flutter/material.dart';

import '../../models/damage_report.dart';
import '../../widgets/report_photo.dart';

/// Full-screen photo viewer with pinch-to-zoom.
class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen({super.key, required this.report});

  final DamageReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(report.id),
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: ReportPhoto(
              report: report,
              height: null,
              fit: BoxFit.contain,
              borderRadius: 0,
              cacheWidth: 2000,
            ),
          ),
        ),
      ),
    );
  }
}
