import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage({
    required String userId,
    required String imagePath,
  }) async {
    try {
      // Create reference to user's profile image
      final Reference ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('profile.jpg');

      // Upload file
      final UploadTask uploadTask = ref.putFile(File(imagePath));

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
