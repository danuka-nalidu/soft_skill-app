import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfViewPage extends StatefulWidget {
  final String pdfUrl;

  PdfViewPage({required this.pdfUrl});

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  String localPath = '';
  bool isLoading = true;
  int totalPages = 0;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    downloadPdf();
  }

  Future<void> downloadPdf() async {
    final bytes = await http.readBytes(Uri.parse(widget.pdfUrl));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/temp.pdf');
    await file.writeAsBytes(bytes, flush: true);
    setState(() {
      localPath = file.path;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Popular Books'),
        centerTitle: true,
        backgroundColor: Color(0xFF4c88d0), // Primary color
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                PDFView(
                  filePath: localPath,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  onRender: (pages) {
                    setState(() {
                      totalPages = pages!;
                    });
                  },
                  onViewCreated: (PDFViewController pdfViewController) {
                    pdfViewController.setPage(0);
                  },
                  onPageChanged: (page, total) {
                    setState(() {
                      currentPage = page!;
                    });
                  },
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    color: Color(0xFFcedbfd),
                    child: Text(
                      '${currentPage + 1}/$totalPages',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}