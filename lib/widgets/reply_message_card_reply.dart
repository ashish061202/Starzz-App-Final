import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

// ignore: must_be_immutable
class ReplyMessageCardReply extends StatefulWidget {
  ReplyMessageCardReply(
      {super.key,
      required this.message,
      required this.time,
      required this.phoneNumber,
      required this.myReply}) {
    whatsAppApi = WhatsAppApi()
      ..setup(
          accessToken: AppConfig.apiKey,
          fromNumberId: int.parse(AppConfig.phoneNoID));
  }

  final Message message;
  final String time;
  late WhatsAppApi whatsAppApi;
  final String phoneNumber;
  final bool myReply;

  @override
  State<ReplyMessageCardReply> createState() => _ReplyMessageCardReplyState();
}

class _ReplyMessageCardReplyState extends State<ReplyMessageCardReply> {
  final AudioPlayer audioPlayer = AudioPlayer();

  bool isPlaying = false;

  Future<void> play() async {
    if (recordFilePath !=
        //null &&
        File(recordFilePath).existsSync()) {
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
                color: widget.myReply ? const Color(0xffdcf8c6) : Colors.white,
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
                          ? const Color(0xffbbdca3)
                          : Colors.grey.shade200,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.message.context['from'],
                              style: TextStyle(
                                  color: widget.myReply
                                      ? Colors.blue
                                      : Colors.purple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                            FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection("accounts")
                                    .doc(AppConfig.WABAID)
                                    .collection("discussion")
                                    .doc(widget.phoneNumber)
                                    .collection("messages")
                                    .where('id',
                                        isEqualTo: widget.message.context['id'])
                                    .get(),
                                builder:
                                    (context, AsyncSnapshot<dynamic> snapshot) {
                                  //print(snapshot.data);
                                  if (snapshot.hasData &&
                                      snapshot.data != null &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    Message messageRepliedTo = Message.fromMap(
                                        snapshot.data.docs[0].data());
                                    return messageRepliedTo.type == 'text'
                                        ? Text(
                                            messageRepliedTo.value['body'],
                                            style: TextStyle(fontSize: 16),
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
                                                    : Text(
                                                        messageRepliedTo.type,
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      );
                                  }
                                  return Text('Not supported');
                                }),
                          ],
                        ),
                      ),
                    ),
                    widget.message.type == 'audio'
                        ? FutureBuilder(
                            future: widget.whatsAppApi.getMediaUrl(
                                mediaId: widget.message.value['id']),
                            builder:
                                ((context, AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8, bottom: 8, left: 10, right: 10),
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
                                              : _loadFile(
                                                  snapshot.data['url'], {
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
                                        )),
                                  ),
                                );
                              } else {
                                return const CircularProgressIndicator();
                              }
                            }))
                        : widget.message.type == 'text'
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 16.0),
                                child: Text(
                                  widget.message.value['body'],
                                  style: TextStyle(fontSize: 16),
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
                                    child: widget.message.type == 'document'
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                widget
                                                    .message.value['filename'],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                "file",
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.5)),
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
                                                future: widget.whatsAppApi
                                                    .getMediaUrl(
                                                        mediaId: widget.message
                                                            .value['id']),
                                                builder: (context,
                                                    AsyncSnapshot<dynamic>
                                                        snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.done) {
                                                    return CachedNetworkImage(
                                                      progressIndicatorBuilder: (context,
                                                              url,
                                                              downloadProgress) =>
                                                          CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons
                                                              .error_outline_rounded),
                                                      imageUrl:
                                                          snapshot.data!['url'],
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
                                                          ConnectionState
                                                              .done) {
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

                                                      return CircularProgressIndicator();
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
                                                                child: Icon(Icons
                                                                    .phone)),
                                                            const SizedBox(
                                                              width: 8.0,
                                                            ),
                                                            Text(widget.message
                                                                        .value[
                                                                    0]['name']
                                                                ['first_name'])
                                                          ],
                                                        ),
                                                      )
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
                                                                  Icons
                                                                      .location_on,
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
                                                        : Text(
                                                            widget.message
                                                                        .type ==
                                                                    'text'
                                                                ? widget.message
                                                                        .value[
                                                                    'body']
                                                                : 'Not supported',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                  ),
                                ],
                              ),
                    SizedBox(
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
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    if (widget.myReply)
                      const Icon(
                        Icons.done_all,
                        size: 20,
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
