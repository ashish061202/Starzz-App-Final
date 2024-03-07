import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http_parser/http_parser.dart';

/*class PdfViewerWidget extends StatefulWidget {
  final String pdfLink;
  final Map<String, String> headers;

  const PdfViewerWidget({
    Key? key,
    required this.pdfLink,
    required this.headers,
  }) : super(key: key);

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  late Future<PDFDocument> _pdfDocument;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _pdfDocument = _loadPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.download),
        //     onPressed: () {
        //       _downloadPdf();
        //     },
        //   ),
        // ],
      ),
      body: _buildPdfViewer(),
    );
  }

  Widget _buildPdfViewer() {
    return FutureBuilder<PDFDocument>(
      future: _pdfDocument,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading PDF: ${snapshot.error}'),
            );
          }
          return PDFViewer(document: snapshot.data!);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<PDFDocument> _loadPdf() async {
    try {
      final response = await http.get(
        Uri.parse(widget.pdfLink),
        headers: widget.headers,
      );

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/${widget.pdfLink.hashCode}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return PDFDocument.fromFile(file);
      } else {
        throw Exception(
            'Failed to load PDF. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading PDF: $e');
    }
  }
}*/

//Me try 2
class PdfViewerWidget extends StatefulWidget {
  final String pdfLink;
  final Map<String, String> headers;

  const PdfViewerWidget({
    Key? key,
    required this.pdfLink,
    required this.headers,
  }) : super(key: key);

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  late Future<PDFDocument> _pdfDocument;
  // late bool _isLoading;
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // _isLoading = true;
    _pdfDocument = _loadPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''), // Set an empty text to remove the title
        automaticallyImplyLeading: false, // Disable back arrow
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: _buildPdfViewer(),
    );
  }

  Widget _buildPdfViewer() {
    return FutureBuilder<PDFDocument>(
      future: _pdfDocument,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading PDF: ${snapshot.error}'),
            );
          }
          return PDFViewer(document: snapshot.data!);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<PDFDocument> _loadPdf() async {
    try {
      final response = await http.get(
        Uri.parse(widget.pdfLink),
        headers: widget.headers,
      );

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/${widget.pdfLink.hashCode}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return PDFDocument.fromFile(file);
      } else {
        throw Exception(
            'Failed to load PDF. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading PDF: $e');
    }
  }

  Future<void> _downloadPdf() async {
    try {
      var dir = await getApplicationDocumentsDirectory();

      final filename = '${widget.pdfLink.hashCode}.pdf';

      final filePath = '${dir.path}/$filename';
      final file = File(filePath);

      final response = await http.get(
        Uri.parse(widget.pdfLink),
        headers: widget.headers,
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print('PDF downloaded successfully at: $filePath');
      } else {
        print('Failed to download PDF. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
    }
  }
}
