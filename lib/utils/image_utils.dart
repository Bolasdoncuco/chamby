import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery and returns it as a compressed Base64 string.
  static Future<String?> pickAndCompressImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final File file = File(image.path);
    final String targetPath = (await path_provider.getTemporaryDirectory()).path + 
        "/temp_${DateTime.now().millisecondsSinceEpoch}.jpg";

    // Compress image to ~300kb or less
    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );

    if (compressedFile == null) return null;

    final List<int> imageBytes = await compressedFile.readAsBytes();
    // Delete temp file
    try { await File(targetPath).delete(); } catch (_) {}
    
    return base64Encode(imageBytes);
  }

  /// Converts a Base64 string to a standard Image widget provider
  /// (Useful if the string doesn't have the data:image/prefix)
  static String ensureBase64Prefix(String base64) {
    if (base64.startsWith('data:image')) return base64;
    return 'data:image/jpeg;base64,$base64';
  }
}
