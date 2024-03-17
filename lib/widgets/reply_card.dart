import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:just_audio/just_audio.dart';
import 'package:STARZ/api/whatsapp_api.dart';
import 'package:STARZ/config.dart';
import 'package:STARZ/models/emoji_reaction_card.dart';
import 'package:STARZ/models/message.dart';
import 'package:STARZ/screens/chat/pdf_viewer.dart';
import 'package:STARZ/screens/video_player/video_player_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/map_utils.dart';
import '../models/message_service.dart';

//Me try 2
class ReplyCard extends StatefulWidget {
  ReplyCard(
      {super.key,
      required this.message,
      required this.time,
      required this.phoneNumberId}) {
    whatsAppApi = WhatsAppApi()
      ..setup(
          accessToken: AppConfig.apiKey,
          fromNumberId: int.parse(phoneNumberId));
  }

  final Message message;
  final String time;
  late WhatsAppApi whatsAppApi;
  late String phoneNumber;
  final String phoneNumberId;

  @override
  State<ReplyCard> createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Color originalColor = Colors.white;
  late Future<dynamic> mediaUrlFuture;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    // Load media URL once when the widget is created
    mediaUrlFuture =
        widget.whatsAppApi.getMediaUrl(mediaId: widget.message.value['id']);
  }

  bool isPlaying = false;

  Future<void> play() async {
    if (File(recordFilePath).existsSync()) {
      await audioPlayer.setFilePath(recordFilePath);
      await audioPlayer.play();
    }
  }

  late String recordFilePath;

  // Function to handle image download
  Future<void> _downloadImage(String? imageUrl) async {
    print("Download button is pressed!!");
    if (imageUrl == null) {
      print('Image URL is null');
      return;
    }

    try {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/downloaded_image.png';

      // Show "Downloading..." toast
      Fluttertoast.showToast(
        msg: "Downloading...",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1000,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      final completer = Completer<void>();

      CachedNetworkImageProvider(imageUrl)
          .resolve(const ImageConfiguration())
          .addListener(
            ImageStreamListener(
              (info, synchronousCall) async {
                if (info != null && info.image != null) {
                  await File(filePath)
                      .writeAsBytes((await info.image!.toByteData(
                    format: ImageByteFormat.png,
                  ))!
                          .buffer
                          .asUint8List());
                  print(
                      'Image downloaded successfully. File saved at: $filePath');
                  // Save the image to the gallery
                  final result = await ImageGallerySaver.saveFile(filePath);
                  print('Image saved to gallery. Result: $result');

                  // Show a toast message
                  Fluttertoast.showToast(
                    msg: "Image downloaded successfully!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );

                  completer.complete();
                } else {
                  print('Failed to download image. Image data is null.');
                  completer.completeError('Image data is null.');
                }
              },
              onError: (dynamic error, StackTrace? stackTrace) {
                print('Error downloading image: $error');
                completer.completeError(error);
              },
            ),
          );

      await completer.future;
    } catch (error) {
      print('Error downloading image: $error');
      // Show an error toast message
      Fluttertoast.showToast(
        msg: "Failed to download image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future _loadFile(String url, headers) async {
    print('isplaying before $isPlaying');
    final bytes = await readBytes(Uri.parse(url), headers: headers);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.aac');

    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      recordFilePath = file.path;
      setState(() {
        print('audioPlayer.playing == ${audioPlayer.playing}');
      });

      await play();

      setState(() {
        print('audioPlayer.playing == ${audioPlayer.playing}');
      });
    }
  }

  bool isPhoneNumber() {
    if (widget.message.value.containsKey('body') &&
        widget.message.value['body'] != null) {
      String pattern = r'(^(?:[+0])?[0-9]{10,12}$)';
      RegExp regExp = RegExp(pattern);
      return regExp.hasMatch(widget.message.value['body']);
    }
    return false;
  }

  Future pause() async {
    await audioPlayer.pause();
  }

  Future stop() async {
    await audioPlayer.stop();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Widget _reactionCard() {
    final String emoji = widget.message.value['emoji'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200], // Adjust the background color as needed
        ),
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> orderData) {
    // Display a summary for multiple product items with a button for more details
    return GestureDetector(
      onTap: () {
        // Show a bottom sheet with detailed information about each product item
        _showCartDetailsBottomSheet(orderData['product_items']);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Get.isDarkMode
                  ? Colors.black45
                  : const ui.Color.fromARGB(255, 211, 208, 208),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Catalog ID: ${orderData['catalog_id']}',
                  style: const TextStyle(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: Get.isDarkMode ? Colors.white : Colors.black,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_calculateTotalQuantity(orderData['product_items'])} items',
                          style: const TextStyle(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${_calculateTotalPrice(orderData['product_items'])} (estimated total)',
                  style: const TextStyle(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(), // Add a divider
          InkWell(
            onTap: () {
              _showCartDetailsBottomSheet(orderData['product_items']);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'View order',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          // Add more Text widgets to display other order details like timestamp, etc.
        ],
      ),
    );
  }

  int _calculateTotalQuantity(List<dynamic> productItems) {
    return productItems
        .map<int>((item) => (item['quantity'] as int?) ?? 0)
        .fold<int>(0, (total, itemQuantity) => total + itemQuantity);
  }

  String _calculateTotalPrice(List<dynamic> productItems) {
    num totalPrice = productItems
        .map<num>((item) =>
            ((item['item_price'] as num?) ?? 0) *
            ((item['quantity'] as num?) ?? 0))
        .fold<num>(0, (total, itemPrice) => total + itemPrice);

    return totalPrice
        .toStringAsFixed(2); // Format total price to display two decimal places
  }

  void _showCartDetailsBottomSheet(List<dynamic> productItems) {
    // Show a bottom sheet with detailed information about each product item
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        int totalQuantity = productItems
            .map<int>((item) => (item['quantity'] as int?) ?? 0)
            .fold<int>(0, (total, itemQuantity) => total + itemQuantity);

        num totalPrice = productItems
            .map<num>((item) =>
                ((item['item_price'] as num?) ?? 0) *
                ((item['quantity'] as num?) ?? 0))
            .fold<num>(0, (total, itemPrice) => total + itemPrice);

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), // Adjust the radius as needed
                  topRight: Radius.circular(25), // Adjust the radius as needed
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Get.isDarkMode
                      ? Colors.grey[850] // Dark mode color
                      : Colors.white,
                  child: Column(
                    children: [
                      Container(
                        width: 30,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const Text(
                            'Order details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              width:
                                  56), // Adjust the width based on your needs
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 90, // Adjust the top margin based on your needs
              left: 10,
              right: 10,
              bottom: 0,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      '$totalQuantity items',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (var productItem in productItems)
                      Container(
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? Colors.grey[500]
                              : Colors.white70,
                          // gradient: LinearGradient(
                          //   colors: [
                          //     Colors.purple[200]!,
                          //     Colors.blue[200]!,
                          //   ], // Adjust the gradient colors
                          //   begin: Alignment.topLeft,
                          //   end: Alignment.bottomRight,
                          // ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Retailer: ${productItem['product_retailer_id']}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${productItem['item_price']}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Quantity ${productItem['quantity']}',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Divider(
                      thickness: 1,
                      color: Colors.grey[350],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₹$totalPrice',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildImageWidget() {
    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'image_hero_${widget.message.id}',
                child: CachedNetworkImage(
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                    value: downloadProgress.progress,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  imageUrl: imageUrl!,
                  httpHeaders: const {
                    "Authorization": "Bearer ${AppConfig.apiKey}",
                  },
                ),
              ),
              // Display caption if available
              if (widget.message.value.containsKey('caption'))
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    widget.message.value['caption'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Download button
        Positioned(
          bottom: 8.0,
          right: 8.0,
          child: IconButton(
            icon: const Icon(
              Icons.download,
              color: Colors.green,
            ),
            onPressed: () {
              // Call a function to handle download
              _downloadImage(imageUrl!);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45, minWidth: 110),
        child: widget.message.type == 'audio'
            ? Stack(
                children: [
                  FutureBuilder(
                      future: widget.whatsAppApi
                          .getMediaUrl(mediaId: widget.message.value['id']),
                      builder: ((context, AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 8, right: 64, left: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Get.isDarkMode
                                    ? const Color(0xff1E1E1E) // Dark mode color
                                    : const Color(0xffffffff),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: GestureDetector(
                                  onTap: () {
                                    isPlaying
                                        ? pause()
                                        : _loadFile(snapshot.data['url'], {
                                            "Authorization":
                                                "Bearer ${AppConfig.apiKey}"
                                          });
                                  },
                                  onSecondaryTap: () {
                                    stop();
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          isPlaying
                                              ? const Icon(Icons.pause)
                                              : const Icon(Icons.play_arrow),
                                          // Text(
                                          //   'Audio-${doc['timestamp']}',
                                          //   maxLines: 10,
                                          // ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      })),
                  Positioned(
                    bottom: 10,
                    right: 70,
                    child: Row(
                      children: [
                        Text(
                          widget.time,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : widget.message.type == 'reaction'
                ? null
                : Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    // color: Color(0xffdcf8c6),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 8,
                            bottom: 15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.message.type == 'order'
                                  ? _buildOrderDetails(widget.message.value)
                                  : widget.message.type == 'document'
                                      ? GestureDetector(
                                          onTap: () async {
                                            final mediaSnapshot = await widget
                                                .whatsAppApi
                                                .getMediaUrl(
                                              mediaId:
                                                  widget.message.value['id'],
                                            );
                                            final pdfUrl = mediaSnapshot['url']
                                                    ?.toString() ??
                                                '';
                                            final headers = {
                                              "Authorization":
                                                  "Bearer ${AppConfig.apiKey}",
                                            };
                                            await Get.toNamed(
                                              PDFViewerPage.id,
                                              arguments: {
                                                'link': pdfUrl,
                                                'headers': headers,
                                              },
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                (originalColor.red +
                                                        Colors.grey.shade500
                                                            .red) ~/
                                                    2,
                                                (originalColor.green +
                                                        Colors.grey.shade500
                                                            .green) ~/
                                                    2,
                                                (originalColor.blue +
                                                        Colors.grey.shade500
                                                            .blue) ~/
                                                    2,
                                                originalColor.opacity,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.message
                                                      .value['filename'],
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "file",
                                                  style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                  ),
                                                ),
                                                Text(
                                                  'Document',
                                                  style: TextStyle(
                                                    color: Colors.red.shade500,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : widget.message.type == "image"
                                          ? FutureBuilder(
                                              future: mediaUrlFuture,
                                              builder: (context,
                                                  AsyncSnapshot<dynamic>
                                                      snapshot) {
                                                if (snapshot.connectionState ==
                                                        ConnectionState.done &&
                                                    imageUrl == null) {
                                                  imageUrl = snapshot
                                                          .data?['url']
                                                          ?.toString() ??
                                                      'default_image_url';
                                                }

                                                return imageUrl != null
                                                    ? buildImageWidget()
                                                    : const CircularProgressIndicator();
                                              },
                                            )
                                          : widget.message.type == "video"
                                              ? FutureBuilder(
                                                  future: widget.whatsAppApi
                                                      .getMediaUrl(
                                                          mediaId: widget
                                                              .message
                                                              .value['id']),
                                                  builder: (context,
                                                      AsyncSnapshot<dynamic>
                                                          snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      Text(
                                                          'videoLink ========= ${snapshot.data['url']}');
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Get.toNamed(
                                                              VideoPlayerScreen
                                                                  .id,
                                                              arguments: {
                                                                'link': snapshot
                                                                        .data[
                                                                    'url'],
                                                                'headers':
                                                                    const {
                                                                  "Authorization":
                                                                      "Bearer ${AppConfig.apiKey}"
                                                                },
                                                              });
                                                        },
                                                        child: const Text(
                                                          'Click to view the video!',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      );
                                                    }

                                                    return const CircularProgressIndicator();
                                                  })
                                              : widget.message.type ==
                                                      'location'
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        MapUtils.openMap(
                                                            widget.message
                                                                    .value[
                                                                'latitude'],
                                                            widget.message
                                                                    .value[
                                                                'longitude']);
                                                      },
                                                      child: const Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons.location_on,
                                                            size: 50.0,
                                                          ),
                                                          Text(
                                                            'Click to open in maps',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ],
                                                      ))
                                                  : widget.message.type ==
                                                          'contacts'
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            launch(
                                                                "tel://${widget.message.value[0]['phones'][0]['phone']}");
                                                          },
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const CircleAvatar(
                                                                  child: Icon(Icons
                                                                      .phone)),
                                                              const SizedBox(
                                                                width: 8.0,
                                                              ),
                                                              Text(widget.message
                                                                          .value[
                                                                      0]['name']
                                                                  [
                                                                  'first_name'])
                                                            ],
                                                          ),
                                                        )
                                                      : GestureDetector(
                                                          onTap: () {
                                                            if (isPhoneNumber()) {
                                                              launch(
                                                                  "tel://${widget.message.value['body']}");
                                                            }
                                                          },
                                                          child: Text(
                                                            widget.message
                                                                        .type ==
                                                                    'text'
                                                                ? widget.message
                                                                        .value[
                                                                    'body']
                                                                : 'Not supported',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: isPhoneNumber()
                                                                  ? Colors.blue
                                                                  : (Get.isDarkMode
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black),
                                                            ),
                                                          ),
                                                        ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 5,
                          child: Text(
                            widget.time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Get.isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

Future<ui.Image> bytesToImage(Uint8List imgBytes) async {
  ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
  ui.FrameInfo frame = await codec.getNextFrame();
  return frame.image;
}
