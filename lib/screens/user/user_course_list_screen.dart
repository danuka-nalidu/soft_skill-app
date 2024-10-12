import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/course_model.dart';
import '../../providers/course_provider.dart';
import 'user_course_detail_screen.dart';

class UserCourseListScreen extends StatefulWidget {
  @override
  _UserCourseListScreenState createState() => _UserCourseListScreenState();
}

class _UserCourseListScreenState extends State<UserCourseListScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchTerm = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 0),
          child: Text(
            'Courses',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Here',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future:
            Provider.of<CourseProvider>(context, listen: false).fetchCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading courses'));
          }

          return Consumer<CourseProvider>(
            builder: (context, courseProvider, child) {
              final courses = courseProvider.courses.where((course) {
                return course.title.toLowerCase().contains(_searchTerm);
              }).toList();

              if (courses.isEmpty) {
                return Center(child: Text('No courses available'));
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Display 2 cards per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 4, // Adjust the card aspect ratio
                ),
                padding: EdgeInsets.all(10),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  String? imageUrl =
                      course.media.isNotEmpty ? course.media[0] : null;

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Stack(
                      children: [
                        // Main content of the card
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        height: 120, // Increased image size
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height:
                                            120, // Increased placeholder size
                                        decoration: BoxDecoration(
                                          color: Colors.purple[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.image,
                                            size: 40,
                                            color: Colors.purple[700]),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  course.title,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.person,
                                        size: 18, color: Colors.green),
                                    SizedBox(width: 4),
                                    Text(
                                      '${course.tutor}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Positioned "View Course" button at the bottom right
                        Positioned(
                          bottom: 8,
                          right: 16,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserCourseDetailScreen(course: course),
                                ),
                              );
                            },
                            child: Text(
                              'View Course',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        // Positioned "Add" icon in the top right corner
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.add_circle,
                                color: Colors.blueAccent),
                            onPressed: () async {
                              await _addCourseToMyCourses(context, course);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addCourseToMyCourses(
      BuildContext context, CourseModel course) async {
    try {
      final myCoursesRef = FirebaseFirestore.instance.collection('myCourses');

      final existingCourse = await myCoursesRef.doc(course.id).get();
      if (existingCourse.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course already added to My Courses')),
        );
        return;
      }

      await myCoursesRef.doc(course.id).set({
        'id': course.id,
        'title': course.title,
        'tutor': course.tutor,
        'media': course.media,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${course.title} added to My Courses')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding course to My Courses')),
      );
      print('Error adding course to My Courses: $e');
    }
  }
}
