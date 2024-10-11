import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lib_book.dart';
import 'lib_user_book_detail_page.dart'; // Updated for user detail page

class LibUserHomePage extends StatefulWidget {
  @override
  _LibUserHomePageState createState() => _LibUserHomePageState();
}

class _LibUserHomePageState extends State<LibUserHomePage> {
  final CollectionReference booksRef =
      FirebaseFirestore.instance.collection('books');

  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User: Browse Books'),
        centerTitle: true,
        backgroundColor: Color(0xFF4c88d0), // Primary Color
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar for users
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Books...',
                    filled: true,
                    fillColor: Color(0xFFcedbfd), // TextField color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.black45),
                  ),
                ),
                SizedBox(height: 16.0),
                // Tabs for filtering books by category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryTab('All'),
                    _buildCategoryTab('Fiction'),
                    _buildCategoryTab('Non-Fiction'),
                    _buildCategoryTab('Science'),
                    _buildCategoryTab('History'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: booksRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                List<Book> books = snapshot.data!.docs
                    .map((doc) => Book.fromDocument(doc))
                    .where((book) => selectedCategory == 'All' ||
                        book.category == selectedCategory)
                    .toList();

                return ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    Book book = books[index];
                    return BookCard(book: book); // Reuse the BookCard widget
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Text(
        category,
        style: TextStyle(
          fontWeight: selectedCategory == category
              ? FontWeight.bold
              : FontWeight.normal,
          color: selectedCategory == category
              ? Color(0xFF4c88d0)
              : Colors.black,
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
  BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: book.imageUrl != null
                  ? Image.network(
                      book.imageUrl!,
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 100,
                      height: 150,
                      color: Color(0xFFcedbfd), // Placeholder color
                      child: Icon(
                        Icons.book,
                        size: 80,
                        color: Colors.white70,
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Title
                    Text(
                      book.title,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.0),
                    // Book Author
                    Text(
                      book.authorName,
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8.0),
                    // Star Rating
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 16.0,
                          color: index < 4
                              ? Colors.amber
                              : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    // View Book Link for users
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserBookDetailPage(book: book), // User book detail page
                            ),
                          );
                        },
                        child: Text(
                          'View Book',
                          style: TextStyle(
                            color: Color(0xFF4c88d0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
