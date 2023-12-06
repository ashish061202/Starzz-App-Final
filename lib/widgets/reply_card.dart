import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:just_audio/just_audio.dart';
import 'package:starz/api/whatsapp_api.dart';
import 'package:starz/config.dart';
import 'package:starz/models/message.dart';
import 'package:starz/screens/video_player/video_player_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/map_utils.dart';

class ReplyCard extends StatefulWidget {
  ReplyCard({Key? key, required this.message, required this.time})
      : super(key: key) {
    whatsAppApi = WhatsAppApi()
      ..setup(
          accessToken: AppConfig.apiKey,
          fromNumberId: int.parse(AppConfig.phoneNoID));
  }

  final Message message;
  final String time;
  late WhatsAppApi whatsAppApi;

  @override
  State<ReplyCard> createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  final AudioPlayer audioPlayer = AudioPlayer();

  bool isPlaying = false;

  Future<void> play() async {
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      await audioPlayer.setFilePath(recordFilePath);
      await audioPlayer.play();
    }
  }

  late String recordFilePath;

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
    String pattern = r'(^(?:[+0])?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(widget.message.value['body']);
  }

  Future pause() async {
    await audioPlayer.pause();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
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
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xffffffff),
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
            : Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                // color: Color(0xffdcf8c6),
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 50,
                        top: 5,
                        bottom: 10,
                      ),
                      child: widget.message.type == 'document'
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.message.value['filename'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "file",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.5)),
                                )
                                // IconButton(
                                //     icon: Icon(Icons.download_for_offline),
                                //     color: Colors.green,
                                //     onPressed: () {
                                //       WhatsAppApi()
                                //         ..setup(
                                //             accessToken: AppConfig.apiKey,
                                //             fromNumberId:
                                //                 int.parse(AppConfig.phoneNoID))
                                //         ..downloadPDF(message.value['id']);
                                //     })
                              ],
                            )
                          : widget.message.type == "image"
                              ? FutureBuilder(
                                  future: widget.whatsAppApi.getMediaUrl(
                                      mediaId: widget.message.value['id']),
                                  builder: (context,
                                      AsyncSnapshot<dynamic> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      print(
                                          'ImageLink ======== ${snapshot.data?['url']?.toString() ?? 'default_image_url'}');
                                      return CachedNetworkImage(
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                        imageUrl:
                                            snapshot.data?['url']?.toString() ??
                                                'default_image_url',
                                        httpHeaders: const {
                                          "Authorization":
                                              "Bearer ${AppConfig.apiKey}"
                                        },
                                      );
                                    }

                                    return CircularProgressIndicator();
                                  })
                              : widget.message.type == "video"
                                  ? FutureBuilder(
                                      future: widget.whatsAppApi.getMediaUrl(
                                          mediaId: widget.message.value['id']),
                                      builder: (context,
                                          AsyncSnapshot<dynamic> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          print(
                                              'videoLink ========= ${snapshot.data['url']}');
                                          return GestureDetector(
                                            onTap: () {
                                              Get.toNamed(VideoPlayerScreen.id,
                                                  arguments: {
                                                    'link':
                                                        snapshot.data['url'],
                                                    'headers': const {
                                                      "Authorization":
                                                          "Bearer ${AppConfig.apiKey}"
                                                    },
                                                  });
                                            },
                                            child: const Text(
                                              'Click to view the video!',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          );
                                        }

                                        return CircularProgressIndicator();
                                      })
                                  : widget.message.type == 'location'
                                      ? GestureDetector(
                                          onTap: () {
                                            MapUtils.openMap(
                                                widget
                                                    .message.value['latitude'],
                                                widget.message
                                                    .value['longitude']);
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
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
                                                      child: Icon(Icons.phone)),
                                                  const SizedBox(
                                                    width: 8.0,
                                                  ),
                                                  Text(widget.message.value[0]
                                                      ['name']['first_name'])
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
                                                widget.message.type == 'text'
                                                    ? widget
                                                        .message.value['body']
                                                    : 'Not supported',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: isPhoneNumber()
                                                      ? Colors.blue
                                                      : Colors.black54,
                                                ),
                                              ),
                                            ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 10,
                      child: Text(
                        widget.time,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
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
