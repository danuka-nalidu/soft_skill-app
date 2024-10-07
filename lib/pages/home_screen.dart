import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uee_project/widget/banner.dart';
import 'package:uee_project/widget/my_icon_button.dart';

const kbackgroundColor = Color(0xffeff1f7);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                    )
                    //For categories
                    // StreamBuilder(stream: , builder: builder)
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
