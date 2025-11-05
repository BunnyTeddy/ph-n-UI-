import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image file
  Future<String?> uploadImage(String path, File file) async {
    try {
      var ref = _storage.ref().child(path);
      var uploadTask = await ref.putFile(file);
      var downloadUrl = await uploadTask.ref.getDownloadURL();
      print('✅ Uploaded image to $path');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      rethrow;
    }
  }

  // Delete image
  Future<bool> deleteImage(String imageUrl) async {
    try {
      var ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('✅ Deleted image: $imageUrl');
      return true;
    } catch (e) {
      print('❌ Error deleting image: $e');
      rethrow;
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages(
    String basePath,
    List<File> files,
  ) async {
    List<String> urls = [];
    for (var file in files) {
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var url = await uploadImage('$basePath/$timestamp.jpg', file);
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }

  // Get download URL from path
  Future<String?> getDownloadUrl(String path) async {
    try {
      var ref = _storage.ref().child(path);
      var downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('❌ Error getting download URL: $e');
      rethrow;
    }
  }
}








