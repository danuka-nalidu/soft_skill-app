import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  // Upload a list of files to Firebase Storage and return the download URLs
  Future<List<String>> uploadFiles(List<File> files, String folderName) async {
    List<String> downloadUrls = [];
    for (var file in files) {
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref().child('$folderName/$fileName');
        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading file: $e');
      }
    }
    return downloadUrls;
  }
}
