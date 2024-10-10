import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SkillDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const SkillDetailScreen({super.key, required this.documentSnapshot});

  @override
  _SkillDetailScreenState createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  late bool isFavourite;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.documentSnapshot['isfavourite'] ?? false;
  }

  // Function to toggle the favorite status
  Future<void> toggleFavorite() async {
    setState(() {
      isFavourite = !isFavourite;
    });

    // Update the Firestore document with the new favorite status
    await FirebaseFirestore.instance
        .collection('skills')
        .doc(widget.documentSnapshot.id)
        .update({'isfavourite': isFavourite});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //color of the body
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
                            color: Colors.black54,
                            size: 40), // Increased icon size
                        const SizedBox(height: 5),
                        Text(
                          '${widget.documentSnapshot['coursecount']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    // Vertical Divider
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.grey, // Vertical divider line
                    ),
                    // Progress Section
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
                        const Text(
                          "Progress",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    // Vertical Divider
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.grey, // Vertical divider line
                    ),
                    // Favorite Section
                    Column(
                      children: [
                        GestureDetector(
                          onTap: toggleFavorite,
                          child: Icon(
                            isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavourite ? Colors.red : Colors.grey,
                            size: 40, // Increased icon size
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Fav",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    // Vertical Divider
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.grey, // Vertical divider line
                    ),
                    // More options section
                    const Column(
                      children: [
                        Icon(Icons.more_vert,
                            color: Colors.black54,
                            size: 40), // Increased icon size
                        SizedBox(height: 5),
                        Text(
                          "More",
                          style: TextStyle(fontSize: 14),
                        ),
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
                    fontSize: 20,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                // Placeholder for courses
              ],
            ),
          )
        ],
      ),
    );
  }
}
