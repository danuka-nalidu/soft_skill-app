import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/api/course_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CourseProvider with ChangeNotifier {
  List<CourseModel> _courses = [];
  final CourseService _courseService = CourseService();

  List<CourseModel> get courses => _courses;

  // Fetch courses from Firestore
  Future<void> fetchCourses() async {
    _courses = await _courseService.fetchCourses();
    notifyListeners();
  }

  // Update a course in the course list
  Future<void> updateCourse(CourseModel course, int index) async {
    await _courseService.updateCourse(course);
    _courses[index] = course;
    notifyListeners();
  }

  // Delete a course in the course list
  Future<void> deleteCourse(int index) async {
    final course = _courses[index];

    try {
      // 1. Delete associated media files from Firebase Storage
      for (String mediaUrl in course.media) {
        await FirebaseStorage.instance.refFromURL(mediaUrl).delete();
      }

      // 2. Delete associated document files from Firebase Storage
      for (String fileUrl in course.files) {
        await FirebaseStorage.instance.refFromURL(fileUrl).delete();
      }

      // 3. Delete the course document from Firestore
      await FirebaseFirestore.instance.collection('courses').doc(course.id).delete();

      // 4. Remove the course from the local list
      _courses.removeAt(index);
      notifyListeners();  // Notify listeners to update the UI
    } catch (e) {
      print('Error deleting course: $e');
    }
  }
}
