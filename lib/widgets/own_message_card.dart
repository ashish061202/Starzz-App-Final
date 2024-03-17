import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:STARZ/widgets/template_message_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:just_audio/just_audio.dart';
import 'package:STARZ/api/whatsapp_api.dart';
import 'package:STARZ/config.dart';
import 'package:STARZ/models/message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:STARZ/screens/video_player/video_player_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'package:STARZ/screens/chat/pdf_viewer.dart';

import '../services/map_utils.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';

class OwnMessageCard extends StatefulWidget {
  OwnMessageCard({
    super.key,
    required this.message,
    required this.time,
    required this.phoneNumberId,
  }) {
    whatsAppApi = WhatsAppApi()
      ..setup(
          accessToken: AppConfig.apiKey,
          fromNumberId: int.parse(phoneNumberId));
  }

  final Message message;
  final String time;
  late WhatsAppApi whatsAppApi;
  final String phoneNumberId;

  @override
  State<OwnMessageCard> createState() => _OwnMessageCardState();
}

class _OwnMessageCardState extends State<OwnMessageCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _animationController2;
  final AudioPlayer audioPlayer = AudioPlayer();
  // Add state variable
  bool isMediaLoading = false;
  late Animation<double> _buttonAnimation;
  late Animation<double> _colorAnimation;
  Color originalColor = const Color(0xffdcf8c6);
  List<String> emotionKeywords = [
    'sad',
    'sorry',
    'angry',
    'surprised',
    'calm',
    'shame',
    'happy',
    'happiest',
    'happily',
    'happiness',
    'fear',
    'fears',
    'feared'
  ];

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _colorAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController2,
        curve: Curves.linear,
      ),
    );

    // Add a listener to rebuild the widget when the animation value changes
    _colorAnimation.addListener(() {
      setState(() {});
    });

    _animationController.repeat(); // Repeat the animation
    if (widget.message.type == 'text') {
      _animationController2
          .repeat(); // Repeat the animation only for text messages
    }

    //mediaStreamController = StreamController<dynamic>.broadcast();
  }

  Shader? getGradientShader(Rect rect, String message) {
    final sadKeywords = ['sad'];
    final angryKeywords = ['angry'];
    final sorryKeywords = ['sorry'];
    final surpriseKeywords = ['surprised'];
    final calmKeywords = ['calm'];
    final shameKeywords = ['shame'];
    final happyKeywords = ['happy', 'happiest', 'happily', 'happiness'];
    final fearKeywords = ['fear', 'fears', 'feared'];

    // Check if the message type is text
    if (widget.message.type == 'text') {
      // Calculate the animated color based on the animation value
      final animatedColorSad = ColorTween(
        begin: Colors.blue[900], // Change the begin color
        end: Colors.white12, // Change the end color
      ).evaluate(_colorAnimation);

      final animatedColorAngry = ColorTween(
        begin: Colors.red[500], // Change the begin color
        end: Colors.white12, // Change the end color
      ).evaluate(_colorAnimation);

      final animatedColorSorry = ColorTween(
        begin: Colors.pink[500], // Change the begin color
        end: Colors.white12, // Change the end color
      ).evaluate(_colorAnimation);

      final animatedColorSurprise = ColorTween(
        begin: Colors.yellow[900], // Change the begin color
        end: Colors.white12, // Change the end color
      ).evaluate(_colorAnimation);

      final animatedColorCalm = ColorTween(
        begin: Colors.blue[900], // Change the begin color
        end: Colors.white12, // Change the end color
      ).evaluate(_colorAnimation);

      final animatedColorShame = ColorTween(
        begin: Colors.grey[900], // Change the begin color
        end: Colors.white12, // Change the end color
      ).evaluate(_colorAnimation);

      final animatedColorHappy = ColorTween(
        begin: Colors.green[900], // Change the begin color
        end: Colors.white12, // Change the end color
      ).evaluate(_colorAnimation);

      final animatedColorFear = ColorTween(
        begin: Colors.brown[900], // Change the begin color
        end: Colors.white12, // Change the end color
      ).evaluate(_colorAnimation);

      /////////////////////////////////////////////////////////////////////////////////

      if (sadKeywords
          .any((keyword) => message.toLowerCase().contains(keyword))) {
        return ui.Gradient.linear(
          const Offset(0, 0),
          Offset(rect.width, rect.height),
          [
            Colors.blue,
            animatedColorSad!,
          ],
        );
      } else if (sorryKeywords
          .any((keyword) => message.toLowerCase().contains(keyword))) {
        return ui.Gradient.linear(
          const Offset(0, 0),
          Offset(rect.width, rect.height),
          [
            Colors.pink,
            animatedColorSorry!,
          ],
        );
      } else if (angryKeywords
          .any((keyword) => message.toLowerCase().contains(keyword))) {
        return ui.Gradient.linear(
          const Offset(0, 0),
          Offset(rect.width, rect.height),
          [
            Colors.red,
            animatedColorAngry!,
          ],
        );
      } else if (surpriseKeywords
          .any((keyword) => message.toLowerCase().contains(keyword))) {
        return ui.Gradient.linear(
          const Offset(0, 0),
          Offset(rect.width, rect.height),
          [
            Colors.yellow.shade900,
            animatedColorSurprise!,
          ],
        );
      } else if (calmKeywords
          .any((keyword) => message.toLowerCase().contains(keyword))) {
        return ui.Gradient.linear(
          const Offset(0, 0),
          Offset(rect.width, rect.height),
          [
            Colors.blue,
            animatedColorCalm!,
          ],
        );
      } else if (shameKeywords
          .any((keyword) => message.toLowerCase().contains(keyword))) {
        return ui.Gradient.linear(
          const Offset(0, 0),
          Offset(rect.width, rect.height),
          [
            Colors.grey,
            animatedColorShame!,
          ],
        );
      } else if (happyKeywords
          .any((keyword) => message.toLowerCase().contains(keyword))) {
        return ui.Gradient.linear(
          const Offset(0, 0),
          Offset(rect.width, rect.height),
          [
            Colors.green.shade400,
            animatedColorHappy!,
          ],
        );
      } else if (fearKeywords
          .any((keyword) => message.toLowerCase().contains(keyword))) {
        return ui.Gradient.linear(
          const Offset(0, 0),
          Offset(rect.width, rect.height),
          [
            Colors.black,
            animatedColorFear!,
          ],
        );
      }
    }
    // Return null for other message types
    return null;
  }

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

  Future<void> play() async {
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      await audioPlayer.setFilePath(recordFilePath);
      await audioPlayer.play();
    }
  }

  late String recordFilePath;

  bool isPhoneNumber() {
    String pattern = r'(^(?:[+0])?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(widget.message.value['body']);
  }

  Future _loadFile(String url, headers) async {
    print('isplaying before $isPlaying');
    final bytes = await readBytes(Uri.parse(url), headers: headers);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.aac');

    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      setState(() {
        recordFilePath = file.path;
        isPlaying = true;
        print(isPlaying);
      });
      await play();
      setState(() {
        isPlaying = false;
        print(isPlaying);
      });
    }
    print('isplaying after $isPlaying');
  }

  Future pause() async {
    print('isplaying before pause $isPlaying');

    await audioPlayer.pause();
    isPlaying = false;

    print('isplaying after pause $isPlaying');
  }

  Future stop() async {
    await audioPlayer.stop();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController2.dispose();
    audioPlayer.dispose();
    //mediaStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
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
                                top: 8, bottom: 8, left: 64, right: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Get.isDarkMode
                                    ? const Color.fromARGB(255, 39, 83, 40)
                                    : const Color(0xffdcf8c6),
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
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.play_arrow),
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
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          return const Text('Failed to load media');
                        }
                      })),
                  Positioned(
                    bottom: 7,
                    right: 14,
                    child: Row(
                      children: [
                        Text(
                          widget.time,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.done_all,
                          size: 20,
                          color: widget.message.isSeen
                              ? Colors.grey[600] // Change color to blue if seen
                              : Colors.grey[
                                  600], // Keep the default color if not seen
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Get.isDarkMode
                    ? const Color.fromARGB(255, 39, 83, 40)
                    : const Color(0xffdcf8c6),
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 8,
                        bottom: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.message.type == 'document'
                              ? GestureDetector(
                                  onTap: () async {
                                    final mediaSnapshot =
                                        await widget.whatsAppApi.getMediaUrl(
                                      mediaId: widget.message.value['id'],
                                    );
                                    final pdfUrl =
                                        mediaSnapshot['url']?.toString() ?? '';
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
                                                Colors.grey.shade500.red) ~/
                                            2,
                                        (originalColor.green +
                                                Colors.grey.shade500.green) ~/
                                            2,
                                        (originalColor.blue +
                                                Colors.grey.shade500.blue) ~/
                                            2,
                                        originalColor.opacity,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.message.value['filename'],
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "file",
                                          style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.5),
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
                                      future: widget.whatsAppApi.getMediaUrl(
                                          mediaId: widget.message.value['id']),
                                      builder: (context,
                                          AsyncSnapshot<dynamic> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          String imageUrl = snapshot
                                                  .data?['url']
                                                  ?.toString() ??
                                              'default_image_url';
                                          Widget mediaWidget = Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Hero(
                                                tag:
                                                    'image_hero_${widget.message.id}',
                                                child: CachedNetworkImage(
                                                  progressIndicatorBuilder: (context,
                                                          url,
                                                          downloadProgress) =>
                                                      CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress,
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                  imageUrl: snapshot
                                                          .data?['url']
                                                          ?.toString() ??
                                                      'default_image_url',
                                                  httpHeaders: const {
                                                    "Authorization":
                                                        "Bearer ${AppConfig.apiKey}"
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                          return Stack(
                                            children: [
                                              mediaWidget,
                                              // Download button
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: isMediaLoading
                                                    ? AnimatedBuilder(
                                                        animation:
                                                            _animationController,
                                                        builder:
                                                            (context, child) {
                                                          return Transform
                                                              .rotate(
                                                            angle: _buttonAnimation
                                                                    .value *
                                                                6.3, // 2π radians
                                                            child:
                                                                const CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                      Color>(
                                                                Colors
                                                                    .blue, // Customize the color
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : IconButton(
                                                        icon: const Icon(
                                                          Icons.download,
                                                          color: Colors.green,
                                                        ),
                                                        onPressed: () {
                                                          // Call a function to handle download
                                                          _downloadImage(
                                                              snapshot.data?[
                                                                  'url']);
                                                        },
                                                      ),
                                              ),
                                            ],
                                          );
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          // Display circular progress indicator
                                          return const CircularProgressIndicator();
                                        } else {
                                          return const Text(
                                              'Failed to load media');
                                        }
                                      },
                                    )
                                  : widget.message.type == "video"
                                      ? FutureBuilder(
                                          future: widget.whatsAppApi
                                              .getMediaUrl(
                                                  mediaId: widget
                                                      .message.value['id']),
                                          builder: (context,
                                              AsyncSnapshot<dynamic> snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              return Hero(
                                                tag:
                                                    'video_hero_${widget.message.id}',
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Get.toNamed(
                                                        VideoPlayerScreen.id,
                                                        arguments: {
                                                          'link': snapshot
                                                              .data['url'],
                                                          'headers': const {
                                                            "Authorization":
                                                                "Bearer ${AppConfig.apiKey}"
                                                          },
                                                        });
                                                  },
                                                  child: const Text(
                                                    'Click to view the video!',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              );
                                            } else if (snapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              // Display circular progress indicator
                                              return const CircularProgressIndicator();
                                            } else {
                                              return const Text(
                                                  'Failed to load media');
                                            }
                                          },
                                        )
                                      : widget.message.type == 'location'
                                          ? GestureDetector(
                                              onTap: () {
                                                MapUtils.openMap(
                                                    widget.message
                                                        .value['latitude'],
                                                    widget.message
                                                        .value['longitude']);
                                              },
                                              child: const Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 50.0,
                                                  ),
                                                  Text(
                                                    'Click to open in maps',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ],
                                              ))
                                          : widget.message.type == 'contacts'
                                              ? GestureDetector(
                                                  onTap: () {
                                                    launch(
                                                        "tel://${widget.message.value[0]['phones'][0]['phone']}");
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const CircleAvatar(
                                                          child: Icon(
                                                              Icons.phone)),
                                                      const SizedBox(
                                                        width: 8.0,
                                                      ),
                                                      Text(widget.message
                                                              .value[0]['name']
                                                          ['first_name'])
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
                                                  child: RichText(
                                                    text: TextSpan(
                                                      text:
                                                          widget.message.type ==
                                                                  'text'
                                                              ? widget.message
                                                                  .value['body']
                                                              : 'Not supported',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: (widget
                                                                        .message
                                                                        .type ==
                                                                    'text' &&
                                                                emotionKeywords.any((keyword) => widget
                                                                    .message
                                                                    .value[
                                                                        'body']
                                                                    .toLowerCase()
                                                                    .contains(
                                                                        keyword)))
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        foreground: Paint()
                                                          ..shader =
                                                              getGradientShader(
                                                                    Rect.zero,
                                                                    widget.message
                                                                            .value[
                                                                        'body'],
                                                                  ) ??
                                                                  LinearGradient(
                                                                    colors: [
                                                                      Get.isDarkMode
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                      Get.isDarkMode
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                    ],
                                                                    stops: const [
                                                                      0.0,
                                                                      0.0
                                                                    ],
                                                                  ).createShader(
                                                                      Rect.zero),
                                                      ),
                                                    ),
                                                  ),
                                                )
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 5,
                      child: Row(
                        children: [
                          Text(
                            widget.time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Get.isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.done_all,
                            size: 17,
                            color: Get.isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey[
                                    600], // Keep the default color if not seen
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
}

Future<ui.Image> bytesToImage(Uint8List imgBytes) async {
  ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
  ui.FrameInfo frame = await codec.getNextFrame();
  return frame.image;
}
