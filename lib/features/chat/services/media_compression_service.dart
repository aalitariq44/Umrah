import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';

class MediaCompressionService {
  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.absolute.path}/${const Uuid().v4()}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 10, // Corresponds to 90% compression
    );

    if (result == null) {
      return null;
    }

    return File(result.path);
  }

  // Audio compression will be handled by configuring the codec in flutter_sound
  // when starting the recording. This is a placeholder for any future audio file-based compression.
  Future<File?> compressAudio(File file) async {
    // For now, we'll just return the original file as flutter_sound handles recording compression.
    // If you were to receive an uncompressed audio file, you would implement compression logic here.
    return file;
  }

  String? getMimeType(String path) {
    return lookupMimeType(path);
  }

  bool isValidFileSize(File file, {int maxSizeInMb = 25}) {
    final maxBytes = maxSizeInMb * 1024 * 1024;
    return file.lengthSync() <= maxBytes;
  }
}
