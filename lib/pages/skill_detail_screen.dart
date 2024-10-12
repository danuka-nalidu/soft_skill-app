import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/user/user_course_detail_screen.dart';
import '../models/course_model.dart'; // Import the CourseModel class

class SkillDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const SkillDetailScreen({super.key, required this.documentSnapshot});

  @override
  _SkillDetailScreenState createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  late bool isFavourite;
  late String skillName;
  late Stream<QuerySnapshot> courseStream;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.documentSnapshot['isfavourite'] ?? false;
    skillName = widget.documentSnapshot['name']; // Get the skill name
    fetchCourses(); // Fetch related courses
  }

  // Function to toggle the favorite status
  Future<void> toggleFavorite() async {
    setState(() {
      isFavourite = !isFavourite;
    });

    // Update the Firestore document with the new favorite status
    await FirebaseFirestore.instance
        .collection('SoftSkills')
        .doc(widget.documentSnapshot.id)
        .update({'isfavourite': isFavourite});
  }

  // Fetch courses based on the skill name (which acts as category in courses)
  void fetchCourses() {
    courseStream = FirebaseFirestore.instance
        .collection('courses')
        .where('category',
            isEqualTo: skillName) // Compare category with skill name
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Stack(
            children: [
              Image.network(
                widget.documentSnapshot['imageurl'],
                height: 400,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
              const BackButton(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skill name
                Text(
                  widget.documentSnapshot['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 20),

                // Row with icons and text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Participants section
                    Column(
                      children: [
                        const Icon(Icons.people,
                            color: Colors.black54, size: 40),
                        const SizedBox(height: 5),
                        Text(
                          '${widget.documentSnapshot['coursecount']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey), // Vertical Divider
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: 0.8,
                              backgroundColor: Colors.grey[300],
                              color: Colors.green,
                              strokeWidth: 6,
                            ),
                            const Text(
                              '80%',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text("Progress", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey), // Vertical Divider
                    Column(
                      children: [
                        GestureDetector(
                          onTap: toggleFavorite,
                          child: Icon(
                            isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavourite ? Colors.red : Colors.grey,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text("Fav", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Skill description
                Text(
                  widget.documentSnapshot['description'],
                  maxLines: 7,
                  style: const TextStyle(
                      fontSize: 20, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(height: 20),

                // Static "Courses" section title
                const Text(
                  "Courses",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),

                // Fetch and display related courses
                StreamBuilder<QuerySnapshot>(
                  stream: courseStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.isEmpty) {
                        return const Text(
                          "No courses found for this skill.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        );
                      }

                      return Column(
                        children: snapshot.data!.docs.map((courseDoc) {
                          // Create a CourseModel object from Firestore data
                          final course = CourseModel(
                            id: courseDoc.id,
                            title: courseDoc['title'],
                            description: courseDoc['description'],
                            duration: courseDoc['duration'],
                            media: List<String>.from(courseDoc['media']),
                            tutor: courseDoc['tutor'], category: '',
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8.0),
                              tileColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              leading: course.media.isNotEmpty
                                  ? Image.network(
                                      course.media[0],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.book),
                              title: Text(
                                course.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Text(
                                'Duration: ${course.duration}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.blue),
                              onTap: () {
                                // Navigate to UserCourseDetailScreen with the CourseModel instance
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserCourseDetailScreen(course: course),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
                    } else if (snapshot.hasError) {
                      return const Text("Error fetching courses");
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
