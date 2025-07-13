import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile(String path, File file) async {
    try {
      final ref = _storage.ref(path).child(const Uuid().v4());
      // Pass empty metadata to fix the NullPointerException on Android
      await ref.putFile(file, SettableMetadata());
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
