import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

enum PhotoSource { camera, gallery }

class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException();

  @override
  String toString() => 'This image is too large. Please choose a smaller photo.';
}

/// Lets the user take a photo or choose one from the gallery.
///
/// The image is returned as bytes (not a file path), so it can be stored in
/// local storage and shown again later on any platform.
class PhotoService {
  PhotoService();

  final ImagePicker _picker = ImagePicker();

  static const int _maxBytes = 3 * 1024 * 1024;

  Future<Uint8List?> pick(PhotoSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      // Shrinking keeps local storage small and the app fast.
      imageQuality: 65,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file == null) return null; // user cancelled

    final bytes = await file.readAsBytes();
    if (bytes.length > _maxBytes) throw const PhotoTooLargeException();
    return bytes;
  }
}
