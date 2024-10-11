import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../models/lib_book.dart';

class FirebaseService {
  final CollectionReference booksRef =
      FirebaseFirestore.instance.collection('books');

  Future<String> uploadPdf(File pdfFile) async {
    String fileName = path.basename(pdfFile.path);
    Reference storageRef = FirebaseStorage.instance.ref().child('books/$fileName');
    UploadTask uploadTask = storageRef.putFile(pdfFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<String> uploadImage(File imageFile) async {
    String fileName = path.basename(imageFile.path);
    Reference storageRef =
        FirebaseStorage.instance.ref().child('book_images/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> addBook(Book book) async {
    await booksRef.add(book.toDocument());
  }

  Future<void> updateBook(Book book) async {
    await booksRef.doc(book.id).update(book.toDocument());
  }

  Future<void> deleteBook(String bookId) async {
    await booksRef.doc(bookId).delete();
  }
}
