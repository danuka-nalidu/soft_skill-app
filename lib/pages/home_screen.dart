import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uee_project/pages/app_main_screen.dart';
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
  final CollectionReference categoriesItems =
      FirebaseFirestore.instance.collection('Categories');

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
                    const SizedBox(
                      height: 10,
                    ),
                    headerParts(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: const Icon(
                            Iconsax.search_normal,
                            size: 25,
                          ),
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          hintText: "Search here...",
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
                    //for banner
                    const BannerToExplore(),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                      ),
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
                    //Start from here
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      child: Text(
                        "Populer Skills",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
        const Text(
          "Hello, John Doe",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const Spacer(),
        MyIconButton(
          icon: Iconsax.user,
          pressed: () {},
        )
      ],
    );
  }
}
