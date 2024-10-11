import 'package:flutter/material.dart';
import '../models/lib_book.dart';
import 'lib_pdf_view_page.dart'; // User can view the PDF

class UserBookDetailPage extends StatelessWidget {
  final Book book;

  UserBookDetailPage({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
        centerTitle: true,
        backgroundColor: Color(0xFF4c88d0),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Book Cover Image
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: book.imageUrl != null
                  ? Image.network(
                      book.imageUrl!,
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 300,
                      color: Color(0xFFcedbfd),
                      child: Center(
                        child: Icon(
                          Icons.book,
                          size: 100,
                          color: Colors.white70,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'By ${book.authorName}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Star Rating
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 20.0,
                        color: index < 4
                            ? Colors.amber
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            book.pages,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Page',
                            style: TextStyle(fontSize: 14.0, color: Colors.grey),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            book.language,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Language',
                            style: TextStyle(fontSize: 14.0, color: Colors.grey),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            book.releaseDate,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Release',
                            style: TextStyle(fontSize: 14.0, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    book.description,
                    style: TextStyle(fontSize: 16.0, height: 1.5),
                  ),
                  SizedBox(height: 24.0),
                  // Read Now Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to PDF view page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewPage(pdfUrl: book.pdfUrl),
                          ),
                        );
                      },
                      child: Text('READ NOW'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Color(0xFF07274d),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
