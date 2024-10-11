import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/course_model.dart';

class CourseService {
  final CollectionReference coursesCollection =
      FirebaseFirestore.instance.collection('courses');

  // Fetch courses from Firestore
  Future<List<CourseModel>> fetchCourses() async {
    try {
      QuerySnapshot snapshot = await coursesCollection.get();

      // Map Firestore documents to CourseModel instances
      return snapshot.docs.map((doc) {
        return CourseModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error fetching courses: $e');
      throw e;
    }
  }

  // Update a course in Firestore
  Future<void> updateCourse(CourseModel course) async {
    await coursesCollection.doc(course.id).update({
      'title': course.title,
      'description': course.description,
      'category': course.category,
      'duration': course.duration,
      'tutor': course.tutor,
      'media': course.media,
      'files': course.files,
    });
  }

  // Delete a course from Firestore
  Future<void> deleteCourse(CourseModel course) async {
    await coursesCollection.doc(course.id).delete();
  }
}
