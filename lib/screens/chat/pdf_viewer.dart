import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:http/http.dart' as http;
// import 'package:STARZ/widgets/reply_card.dart';
// import 'dart:typed_data';
import 'package:STARZ/screens/chat/pdf_viewer_widget.dart';

// Import your ProxyService class
//import 'package:STARZ/screens/chat/proxy_service.dart';

// class PDFViewerPage extends StatefulWidget {
//   static const id = '/pdfViewerPage';
//   final String link = Get.arguments?['link'] as String;
//   final headers = Get.arguments['headers'];

//   PDFViewerPage({super.key});

//   @override
//   State<PDFViewerPage> createState() => _PDFViewerPageState();
// }

// class _PDFViewerPageState extends State<PDFViewerPage> {
//   late PDFViewController controller;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PDF Viewer'),
//       ),
//       body: PdfViewerWidget(pdfLink: widget.link, headers: widget.headers),
//     );
//   }
// }

// class PdfViewerWidget extends StatelessWidget {
//   final String pdfLink;
//   final Map<String, String> headers;

//   const PdfViewerWidget(
//       {super.key, required this.pdfLink, required this.headers});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String>(
//       future: _getCachedPdfUrl(pdfLink, headers),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           print('Type of snapshot.data: ${snapshot.data.runtimeType}');

//           return Container(
//             alignment: Alignment.topCenter,
//             child: buildPdfView(snapshot.data!),
//           );
//         } else {
//           return Container(
//             height: 200,
//             child: const Center(child: CircularProgressIndicator()),
//           );
//         }
//       },
//     );
//   }

//   Future<String> _getCachedPdfUrl(
//     String pdfUrl,
//     Map<String, String> headers,
//   ) async {
//     // Use your ProxyService to fetch the PDF file
//     final proxyService = ProxyService();
//     final http.Response response =
//         await proxyService.proxyRequest(pdfUrl, headers);

//     // Download the PDF file manually
//     final Uint8List pdfBytes = Uint8List.fromList(response.bodyBytes);

//     // Save the PDF file using DefaultCacheManager without headers
//     final tempFile = await DefaultCacheManager().putFile(
//       pdfUrl,
//       pdfBytes,
//       fileExtension: 'pdf',
//     );

//     return tempFile.path;
//   }

//   Widget buildPdfView(String pdfPath) => PDFView(
//         filePath: pdfPath,
//         autoSpacing: true,
//         pageSnap: true,
//         swipeHorizontal: true,
//         onViewCreated: (PDFViewController pdfViewController) {
//           // Do something when PDF is rendered, if needed
//         },
//       );
// }

//Me
/*class PDFViewerPage extends StatefulWidget {
  static const id = '/pdfViewerPage';

  const PDFViewerPage({super.key});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late PDFViewController controller;

  @override
  Widget build(BuildContext context) {
    // Extract the 'link' and 'headers' arguments
    final Map<String, dynamic>? arguments =
        Get.arguments as Map<String, dynamic>?;

    final String pdfLink = arguments?['link']?.toString() ?? '';
    final Map<String, String> headers =
        arguments?['headers'] as Map<String, String>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: PdfViewerWidget(pdfLink: pdfLink, headers: headers),
    );
  }
}*/

//Me try2
/*class PDFViewerPage extends StatefulWidget {
  static const id = '/pdfViewerPage';

  const PDFViewerPage({super.key});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  @override
  Widget build(BuildContext context) {
    // Extract the 'link' and 'headers' arguments
    final Map<String, dynamic>? arguments =
        Get.arguments as Map<String, dynamic>?;

    final String pdfLink = arguments?['link']?.toString() ?? '';
    final Map<String, String> headers =
        arguments?['headers'] as Map<String, String>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body:
          PdfViewerWidget(key: UniqueKey(), pdfLink: pdfLink, headers: headers),
    );
  }
}*/

//Me try3
class PDFViewerPage extends StatelessWidget {
  static const id = '/pdfViewerPage';

  const PDFViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract the 'link' and 'headers' arguments
    final Map<String, dynamic>? arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final String pdfLink = arguments?['link']?.toString() ?? '';
    final Map<String, String> headers = arguments?['headers'] as Map<String, String>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: PdfViewerWidget(pdfLink: pdfLink, headers: headers),
    );
  }
}
