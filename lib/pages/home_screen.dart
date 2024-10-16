import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uee_project/pages/profile.dart';
import 'package:uee_project/pages/skill_detail_screen.dart';
import 'package:uee_project/services/authentication.dart'; // Import AuthServices
import 'package:uee_project/widget/banner.dart';
import 'package:uee_project/widget/my_icon_button.dart';

const kbackgroundColor = Color(0xffeff1f7);
const kprimaryColor = Colors.blue;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String category = 'All'; // The default selected category is "All"
  String searchQuery = ''; // Variable to store the search query

  final CollectionReference categoriesItems =
      FirebaseFirestore.instance.collection("Categories");
  final CollectionReference skillItems = FirebaseFirestore.instance
      .collection("SoftSkills"); // Collection for skills section

  String userName = ''; // Variable to store the user's name

  @override
  void initState() {
    super.initState();
    fetchUserName(); // Fetch the user's name when the screen initializes
  }

  void fetchUserName() async {
    String? uid =
        FirebaseAuth.instance.currentUser?.uid; // Get the current user's UID
    if (uid != null) {
      Map<String, dynamic>? userData = await AuthServices().getUserData(uid);
      if (mounted) {
        setState(() {
          userName = userData?['name'] ?? ''; // Set the user's name
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    headerParts(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      child: TextField(
                        onChanged: (value) {
                          // Update the search query whenever the user types in the search bar
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: const Icon(
                            Iconsax.search_normal,
                            size: 25,
                          ),
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          hintText: "Search skills...",
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    // for banner
                    const BannerToExplore(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // For categories
                    StreamBuilder(
                      stream: categoriesItems.snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                        // Check if the snapshot has data
                        if (streamSnapshot.hasData) {
                          var categories = streamSnapshot.data!.docs;

                          // Find and move the document with 'name' == 'All' to the first position
                          var allCategoryIndex = categories
                              .indexWhere((doc) => doc['name'] == 'All');
                          if (allCategoryIndex != -1) {
                            var allCategory =
                                categories.removeAt(allCategoryIndex);
                            categories.insert(0, allCategory);
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                categories.length,
                                (index) {
                                  var categoryName = categories[index]
                                      ["name"]; // Getting category name
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        category =
                                            categoryName; // Update selected category
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: category == categoryName
                                            ? kprimaryColor
                                            : Colors.white,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      margin: const EdgeInsets.only(right: 20),
                                      child: Text(
                                        categoryName,
                                        style: TextStyle(
                                          color: category == categoryName
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        // If snapshot doesn't have data, show progress indicator
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Popular Skills",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // For skills
                    StreamBuilder(
                      stream: category == 'All'
                          ? skillItems
                              .snapshots() // Load all skills if "All" is selected
                          : skillItems
                              .where('category', isEqualTo: category)
                              .snapshots(), // Filter based on selected category
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshotData) {
                        if (snapshotData.hasData) {
                          // Filter skills based on the search query
                          var filteredSkills = snapshotData.data!.docs.where(
                              (doc) => doc['name']
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchQuery));

                          return SizedBox(
                            height: 400, // Adjust the height as needed
                            child: GridView.builder(
                              itemCount: filteredSkills.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.79,
                              ),
                              itemBuilder: (context, index) {
                                final DocumentSnapshot documentSnapshot =
                                    filteredSkills.elementAt(index);
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SkillDetailScreen(
                                          documentSnapshot: documentSnapshot,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Material(
                                    elevation: 3,
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 160,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                documentSnapshot['imageurl'],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          documentSnapshot['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(
                                            height: 5), // Reduced space
                                        Row(
                                          children: [
                                            Text(
                                              "${documentSnapshot['coursecount']} courses", // Appending "courses" to coursecount
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors
                                                    .grey, // Light grey color for course count
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Small round button with white arrow and blue background
                                            Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: kprimaryColor,
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              child: const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row headerParts() {
    return Row(
      children: [
        Text(
          "Hello, $userName", // Use the fetched user name here
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const Spacer(),
        MyIconButton(
          icon: Iconsax.user,
          pressed: () {
            // Use Navigator.push to navigate to the ProfilePage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        )
      ],
    );
  }
}
