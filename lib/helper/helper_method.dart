import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
}