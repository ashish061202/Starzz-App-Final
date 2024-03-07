import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:just_audio/just_audio.dart';
import 'package:STARZ/api/whatsapp_api.dart';
import 'package:STARZ/config.dart';
import 'package:STARZ/models/message.dart';
import 'package:STARZ/screens/video_player/video_player_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/map_utils.dart';

// ignore: must_be_immutable
class ReplyMessageCardReply extends StatefulWidget {
  ReplyMessageCardReply({
    super.key,
    required this.message,
    required this.time,
    required this.phoneNumber,
    required this.myReply,
    required this.phoneNumberId,
    // required this.templateName,
    // required this.templateId,
  }) {
    whatsAppApi = WhatsAppApi()
      ..setup(
          accessToken: AppConfig.apiKey,
          fromNumberId: int.parse(phoneNumberId));
  }

  final Message message;
  final String time;
  late WhatsAppApi whatsAppApi;
  final String phoneNumber;
  final String phoneNumberId;
  final bool myReply;
  // final String templateName;
  // final String templateId;

  @override
  State<ReplyMessageCardReply> createState() => _ReplyMessageCardReplyState();
}

class _ReplyMessageCardReplyState extends State<ReplyMessageCardReply> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final wabaidController = Get.find<WABAIDController>();
  late String enteredWABAID = wabaidController.enteredWABAID;

  bool isPlaying = false;

  Future<void> play() async {
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      await audioPlayer.setFilePath(recordFilePath);
      await audioPlayer.play();
    } else {
      // Handle the case when recordFilePath is null
      print('Record file path is null or does not exist');
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

  Future pause() async {
    await audioPlayer.pause();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Map<String, String> mapFieldLabels = {
    'screen_1_source_0': 'Source',
    'screen_0_email_2': 'Email',
    'screen_0_firstName_0': 'First Name',
    'screen_0_lastName_1': 'Last Name',
    // Add more mappings as needed
  };

  String getFieldLabel(String rawFieldName) {
    // If a mapping exists, return the mapped label; otherwise, return the raw field name
    return mapFieldLabels[rawFieldName] ?? rawFieldName;
  }

  Map<String, dynamic>? parseResponseJson(String jsonString) {
    try {
      // Parse the JSON string
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      // Exclude the "flow_token" field if present
      jsonMap.remove('flow_token');

      // Extract all fields from response_json
      final List<String> fieldNames = jsonMap.keys.cast<String>().toList();

      // Construct a map with extracted values
      final Map<String, dynamic> extractedValues = {};
      for (String fieldName in fieldNames) {
        final String label = getFieldLabel(fieldName);
        extractedValues[label] = jsonMap[fieldName].toString();
      }

      return extractedValues;
    } catch (e) {
      print('Error parsing response_json: $e');
      return null;
    }
  }

  Widget buildInteractiveMessage(Map<String, dynamic> interactiveData) {
    final responseJson = interactiveData['nfm_reply'] != null
        ? interactiveData['nfm_reply']['response_json'].toString()
        : null;

    final parsedResponse = parseResponseJson(responseJson!);

    if (parsedResponse != null) {
      final List<InlineSpan> textSpans = [
        const TextSpan(
          text: 'Response Details\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ];

      // Build text spans dynamically based on response_json fields
      for (String label in parsedResponse.keys) {
        textSpans.add(
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
        textSpans.add(
          TextSpan(text: '${parsedResponse[label]}\n'),
        );
      }

      final formattedMessage = RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          children: textSpans,
        ),
      );

      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 16.0,
        ),
        child: formattedMessage,
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 16.0,
        ),
        child: Text(
          'Flow Message: Unknown format',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.myReply ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Stack(
            children: [
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                // color: Color(0xffdcf8c6),
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                color: widget.myReply
                    ? (Get.isDarkMode
                        ? const Color.fromARGB(255, 39, 83, 40)
                        : const Color(0xffdcf8c6))
                    : (Get.isDarkMode ? null : Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      // color: Color(0xffdcf8c6),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      color: widget.myReply
                          ? (Get.isDarkMode
                              ? const Color.fromARGB(255, 26, 54, 27)
                              : const Color(0xffbbdca3))
                          : (Get.isDarkMode
                              ? Colors.black45
                              : Colors.grey.shade200),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.message.context != null
                                  ? widget.message.context['from'] ??
                                      'Unknown Sender'
                                  : 'Unknown Sender',
                              style: TextStyle(
                                color: widget.myReply
                                    ? Colors.blue
                                    : Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection("accounts")
                                    .doc(enteredWABAID)
                                    .collection("discussion")
                                    .doc(widget.phoneNumber)
                                    .collection("messages")
                                    .where('id',
                                        isEqualTo: widget.message.context['id'])
                                    .get(),
                                builder:
                                    (context, AsyncSnapshot<dynamic> snapshot) {
                                  //print('snapshot data ===== $snapshot.data');

                                  // Check if the message type is 'button' and has a context
                                  if (widget.message.type == 'button' &&
                                      widget.message.context != null) {
                                    // Display custom text for button type with context
                                    return const Text(
                                      'Business Template',
                                      style: TextStyle(fontSize: 16),
                                    );
                                  } else if (widget.message.type ==
                                          'interactive' &&
                                      widget.message.context != null) {
                                    // Handle interactive type message with context
                                    final interactiveData =
                                        widget.message.context['interactive'];

                                    if (interactiveData != null) {
                                      final nfmReplyData =
                                          interactiveData['nfm_reply'];

                                      if (nfmReplyData != null) {
                                        final body =
                                            nfmReplyData['body'] as String?;
                                        final name =
                                            nfmReplyData['name'] as String?;
                                        final responseJson =
                                            nfmReplyData['response_json']
                                                as String?;

                                        // Display interactive type message information
                                        return Text(
                                          'Interactive Message: $body, $name, $responseJson',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        );
                                      }
                                    }

                                    // Default case if interactive data is not properly structured
                                    return const Text(
                                      'Flow Message',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    );
                                  }
                                  // if (widget.message.type == 'button' &&
                                  //     widget.message.context != null) {
                                  //   // Display custom text for button type with context
                                  //   return Text(
                                  //     'Business Template: ${widget.templateName} (${widget.templateId})',
                                  //     style: TextStyle(fontSize: 16),
                                  //   );
                                  // }
                                  else if (snapshot.hasData &&
                                      snapshot.data != null &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    Message messageRepliedTo = Message.fromMap(
                                      snapshot.data.docs[0].data(),
                                      snapshot.data.docs[0].id,
                                    );
                                    // Display the replied-to message
                                    return messageRepliedTo.type == 'text'
                                        ? Text(
                                            messageRepliedTo.value['body'],
                                            style:
                                                const TextStyle(fontSize: 16),
                                          )
                                        : messageRepliedTo.type == 'audio'
                                            ? const NonTextMessageRepliedTo(
                                                icon: Icons.audiotrack_rounded,
                                                type: 'audio')
                                            : messageRepliedTo.type == 'video'
                                                ? const NonTextMessageRepliedTo(
                                                    icon: Icons
                                                        .video_file_outlined,
                                                    type: 'video')
                                                : messageRepliedTo.type ==
                                                        'image'
                                                    ? const NonTextMessageRepliedTo(
                                                        icon: Icons
                                                            .image_outlined,
                                                        type: 'image')
                                                    : messageRepliedTo.type ==
                                                            'button'
                                                        ? Text(
                                                            messageRepliedTo
                                                                .value['text'],
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          )
                                                        : Text(
                                                            messageRepliedTo
                                                                .type,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          );
                                  }
                                  return const Text('Not supported');
                                }),
                          ],
                        ),
                      ),
                    ),
                    widget.message.type == 'audio'
                        ? FutureBuilder(
                            future: widget.whatsAppApi.getMediaUrl(
                              mediaId: widget.message.value['id'],
                            ),
                            builder:
                                ((context, AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: widget.myReply
                                          ? const Color(0xffa6c28f)
                                          : Colors.grey.shade200,
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
                                        // stopRecord();
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
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
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return const CircularProgressIndicator();
                              }
                            }),
                          )
                        : widget.message.type == 'text'
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 16.0),
                                child: Text(
                                  widget.message.value['body'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                            : widget.message.type == 'interactive'
                                ? buildInteractiveMessage(widget.message.value)
                                : widget.message.type ==
                                        'button' // Check for 'button' type
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 16.0,
                                        ),
                                        child: Text(
                                          widget.message.value[
                                              'text'], // Display the button text
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      )
                                    : Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 30,
                                              top: 5,
                                              bottom: 20,
                                            ),
                                            child: widget.message.type ==
                                                    'document'
                                                ? Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        widget.message
                                                            .value['filename'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        "file",
                                                        style: TextStyle(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5)),
                                                      )
                                                    ],
                                                  )
                                                : widget.message.type == "image"
                                                    ? FutureBuilder(
                                                        future: widget
                                                            .whatsAppApi
                                                            .getMediaUrl(
                                                                mediaId: widget
                                                                        .message
                                                                        .value[
                                                                    'id']),
                                                        builder: (context,
                                                            AsyncSnapshot<
                                                                    dynamic>
                                                                snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .done) {
                                                            return Stack(
                                                              children: [
                                                                Hero(
                                                                  tag:
                                                                      'image_hero_${widget.message.id}',
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    progressIndicatorBuilder: (context,
                                                                            url,
                                                                            downloadProgress) =>
                                                                        CircularProgressIndicator(
                                                                      value: downloadProgress
                                                                          .progress,
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        const Icon(
                                                                            Icons.error),
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
                                                                // Download button
                                                                Positioned(
                                                                  top: 5,
                                                                  right: 5,
                                                                  child:
                                                                      IconButton(
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .download,
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      // Call a function to handle download
                                                                      _downloadImage(
                                                                          snapshot
                                                                              .data?['url']);
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          } else if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            // Display circular progress indicator
                                                            return const CircularProgressIndicator();
                                                          } else {
                                                            return const Text(
                                                                'Failed to load media');
                                                          }
                                                        },
                                                      )
                                                    : widget.message.type ==
                                                            "video"
                                                        ? FutureBuilder(
                                                            future: widget
                                                                .whatsAppApi
                                                                .getMediaUrl(
                                                                    mediaId: widget.message.value[
                                                                        'id']),
                                                            builder: (context,
                                                                AsyncSnapshot<dynamic>
                                                                    snapshot) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .done) {
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    Get.toNamed(
                                                                        VideoPlayerScreen
                                                                            .id,
                                                                        arguments: {
                                                                          'link':
                                                                              snapshot.data['url'],
                                                                          'headers':
                                                                              const {
                                                                            "Authorization":
                                                                                "Bearer ${AppConfig.apiKey}"
                                                                          },
                                                                        });
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Click to view the video!',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                );
                                                              }

                                                              return const CircularProgressIndicator();
                                                            })
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
                                                                        child: Icon(
                                                                            Icons.phone)),
                                                                    const SizedBox(
                                                                      width:
                                                                          8.0,
                                                                    ),
                                                                    Text(widget
                                                                            .message
                                                                            .value[0]['name']
                                                                        [
                                                                        'first_name'])
                                                                  ],
                                                                ),
                                                              )
                                                            : widget.message.type ==
                                                                    'location'
                                                                ? GestureDetector(
                                                                    onTap: () {
                                                                      MapUtils.openMap(
                                                                          widget.message.value[
                                                                              'latitude'],
                                                                          widget
                                                                              .message
                                                                              .value['longitude']);
                                                                    },
                                                                    child: const Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .location_on,
                                                                          size:
                                                                              50.0,
                                                                        ),
                                                                        Text(
                                                                          'Click to open in maps',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        )
                                                                      ],
                                                                    ))
                                                                : Text(
                                                                    widget.message.type ==
                                                                            'text'
                                                                        ? widget
                                                                            .message
                                                                            .value['body']
                                                                        : 'Not supported',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                          ),
                                        ],
                                      ),
                    const SizedBox(
                      height: 20.0,
                    )
                  ],
                ),
              ),
              Positioned(
                bottom: 5,
                right: 20,
                child: Row(
                  children: [
                    Text(
                      widget.time,
                      style: TextStyle(
                        fontSize: 13,
                        color: Get.isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    if (widget.myReply)
                      Icon(
                        Icons.done_all,
                        size: 20,
                        color: Get.isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey[600],
                      ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}

class NonTextMessageRepliedTo extends StatelessWidget {
  const NonTextMessageRepliedTo(
      {super.key, required this.icon, required this.type});

  final IconData icon;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17.0,
          ),
          const SizedBox(
            width: 3.0,
          ),
          Text(
            type,
            style: const TextStyle(fontSize: 16),
          ),
        ]);
  }
}
