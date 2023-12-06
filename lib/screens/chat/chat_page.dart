//import 'dart:convert';
import 'dart:io';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
//import 'package:geolocator/geolocator.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/place_picker.dart';
import 'package:starz/api/whatsapp_api.dart';
import 'package:starz/models/message.dart';
import 'package:starz/services/location.dart';
import 'package:starz/widgets/reply_message_card_reply.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../widgets/own_message_card.dart';
import '../../widgets/reply_card.dart';
import '../../config.dart';
import '../phone_contacts/phone_contacts_page.dart';

// ignore: must_be_immutable
class ChatPage extends StatefulWidget {
  ChatPage({
    super.key,
  }) {
    roomId = Get.arguments['roomId'];
    phoneNumber = Get.arguments['to'];
    whatsApp = WhatsAppApi();
    whatsApp.setup(
        accessToken: AppConfig.apiKey,
        fromNumberId: int.tryParse(AppConfig.phoneNoID));
  }

  late WhatsAppApi whatsApp;
  static const id = "/chatPage";
  late String phoneNumber;
  late String roomId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool show = false;
  FocusNode focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool sendButton = false;
  final audioRecorder = FlutterSoundRecorder();
  bool isAudioRecordedReady = false;
  bool isRecording = false;
  Message? swipedMessage;

  @override
  void initState() {
    super.initState();
    // connect();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          show = false;
        });
      }
    });

    initRecord();
  }

  Future initRecord() async {
    final granted = await checkPermission();
    if (!granted) {
      throw 'Microphone permission not granted';
    }

    await audioRecorder.openRecorder();
    isAudioRecordedReady = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    audioRecorder.closeRecorder();
    super.dispose();
  }

  // void connect() {
  //   socket = IO.io("http://127.0.0.1:5001", <String, dynamic>{
  //     "transports": ["websocket"],
  //     "autoconnect": false,
  //   });
  //   socket.connect();
  //   socket.emit("signin", widget.sourceChat.id);

  //   socket.onConnect((data) {
  //     //print("connected");
  //     socket.on('message', (msg) {
  //       //print(msg);
  //       setMessage("destination", msg["message"]);
  //       _scrollController.animateTo(_scrollController.position.maxScrollExtent,
  //           duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  //     });
  //   });
  //   ///print(socket.connected);
  // }

  void sendMessage(String message, String recipientPhoneNumber) {
    setMessage('source', message);
    // setMessage("source", message);
    // socket.emit("message", {
    //   "message": message,
    //   "sourceId": sorceId,
    //   "targetId": targetId,
    // });
  }

  void setMessage(String type, String message) {
    widget.whatsApp
        .messagesText(
            message: _controller.text, to: int.parse(widget.phoneNumber))
        .then((value) async {
      print('+++ RESPONSE NORMAL $value');
      await FirebaseFirestore.instance
          .collection("accounts")
          .doc(AppConfig.WABAID)
          .collection("discussion")
          .doc(widget.phoneNumber)
          .collection("messages")
          .add({
        "from": AppConfig.phoneNoID,
        "id": value['messages'][0]['id'],
        "text": {"body": message},
        "type": "text",
        "timestamp": DateTime.now()
      });
    });
  }

  void sendTextReply(String message) async {
    var response = await widget.whatsApp.messagesReply(
        to: int.parse(widget.phoneNumber),
        messageId: swipedMessage!.id,
        message: message);
    await FirebaseFirestore.instance
        .collection("accounts")
        .doc(AppConfig.WABAID)
        .collection("discussion")
        .doc(widget.phoneNumber)
        .collection("messages")
        .add({
      "from": AppConfig.phoneNoID,
      "id": response['messages'][0]['id'],
      "text": {"body": message},
      "type": "text",
      "timestamp": DateTime.now(),
      "context": {'from': swipedMessage!.from, 'id': swipedMessage!.id}
    });
    setState(() {
      swipedMessage = null;
    });
  }

  void sendLocationMessage(latitude, longitude) async {
    var response;

    if (swipedMessage == null) {
      response = await widget.whatsApp.messagesLocation(
          to: int.parse(widget.phoneNumber),
          longitude: longitude,
          latitude: latitude,
          name: '',
          address: '');
    } else {
      response = await widget.whatsApp.messagesLocationReply(
          to: int.parse(widget.phoneNumber),
          longitude: longitude,
          latitude: latitude,
          name: '',
          address: '',
          messageId: swipedMessage!.id);
    }
    if (swipedMessage == null) {
      await FirebaseFirestore.instance
          .collection("accounts")
          .doc(AppConfig.WABAID)
          .collection("discussion")
          .doc(widget.phoneNumber)
          .collection("messages")
          .add({
        "from": AppConfig.phoneNoID,
        "id": response['messages'][0]['id'],
        "location": {"longitude": longitude, 'latitude': latitude},
        "type": "location",
        "timestamp": DateTime.now(),
      });
      setState(() {
        swipedMessage = null;
      });
    } else {
      await FirebaseFirestore.instance
          .collection("accounts")
          .doc(AppConfig.WABAID)
          .collection("discussion")
          .doc(widget.phoneNumber)
          .collection("messages")
          .add({
        "from": AppConfig.phoneNoID,
        "id": response['messages'][0]['id'],
        "context": {'from': widget.phoneNumber, 'id': swipedMessage!.id},
        "location": {"longitude": longitude, 'latitude': latitude},
        "type": "location",
        "timestamp": DateTime.now(),
      });
      setState(() {
        swipedMessage = null;
      });
    }
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future checkLocationPermission() async {
    var currentStatus = await Permission.location.status;
    if (currentStatus.isGranted) {
      print('LOCATION GRANTED');
      Location location = Location();
      await location.getCurrentLocation();
      sendLocationMessage(location.latitude, location.longitude);
      // showPlacePicker();
    } else if (currentStatus.isDenied) {
      print('LOCATION DENIED');
      Map<Permission, PermissionStatus> status = await [
        Permission.location,
      ].request();
      if (await Permission.location.isPermanentlyDenied) {
        openAppSettings();
      }
      print('LOCATION $status');
    }
  }

  void showPlacePicker() async {
    try {
      LocationResult? result = await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  PlacePicker("AIzaSyDbNh4C7T3AQLBr9GGJgS0MvJ6DNw52KMg")));
      print('THIS IS THE RESULT $result');
    } catch (error) {
      print('THIS IS THE RESULT ERROR $error');
    }

    // Handle the result in your way
  }

  Future record() async {
    if (!isAudioRecordedReady) return;
    setState(() {
      isRecording = true;
    });
    await audioRecorder.startRecorder(toFile: 'audio.aac');
  }

  Future stopRecording() async {
    if (!isAudioRecordedReady) return;

    setState(() {
      isRecording = false;
    });
    final path = await audioRecorder.stopRecorder();
    final audioFile = File(path!);

    print('Recorded audio: $audioFile');

    var id = (await widget.whatsApp.uploadMedia(
        mediaType: MediaType.parse("audio/aac"),
        mediaFile: audioFile,
        mediaName: audioFile.path.split('/').last))['id'];

    var link = await widget.whatsApp.getMediaUrl(mediaId: id);
    print(link);

    var mesgRes;
    if (swipedMessage == null) {
      mesgRes = await widget.whatsApp.messagesMedia(
          mediaId: id,
          // {AUDIO, CONTACTS, DOCUMENT, IMAGE, INTERACTIVE, LOCATION, REACTION, STICKER, TEMPLATE, TEXT, VIDEO}.toLowerCase()
          mediaType: "audio",
          to: widget.phoneNumber);
    } else {
      mesgRes = await widget.whatsApp.messagesReplyMedia(
          mediaId: id,
          // {AUDIO, CONTACTS, DOCUMENT, IMAGE, INTERACTIVE, LOCATION, REACTION, STICKER, TEMPLATE, TEXT, VIDEO}.toLowerCase()
          mediaType: "audio",
          messageId: swipedMessage!.id,
          to: widget.phoneNumber);
    }

    var messageObject;
    if (swipedMessage == null) {
      messageObject = {
        "audio": {"mime_type": "audio/aac", "sha256": link['sha256'], "id": id},
        "type": "audio",
        "from": AppConfig.phoneNoID,
        "id": mesgRes['messages'][0]['id'],
        "timestamp": DateTime.now()
      };
    } else {
      messageObject = {
        "audio": {"mime_type": "audio/aac", "sha256": link['sha256'], "id": id},
        "type": "audio",
        "from": AppConfig.phoneNoID,
        "id": mesgRes['messages'][0]['id'],
        "timestamp": DateTime.now(),
        "context": {'from': swipedMessage!.from, 'id': swipedMessage!.id}
      };
    }

    await FirebaseFirestore.instance
        .collection("accounts")
        .doc(AppConfig.WABAID)
        .collection("discussion")
        .doc(widget.phoneNumber)
        .collection("messages")
        .add(messageObject);
    setState(() {
      swipedMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.blueGrey,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              elevation: 0,
              leadingWidth: 70,
              titleSpacing: 0,
              leading: InkWell(
                onTap: () => Navigator.pop(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios,
                      size: 24,
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() {
                    //       swipedMessage = null;
                    //     });
                    //   },)
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blueGrey,
                      child: swipedMessage != null
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  swipedMessage = null;
                                });
                              },
                              icon: Icon(Icons.cancel))
                          // ? Icon(Icons.cancel)
                          : SvgPicture.asset(
                              "assets/person.svg",
                              color: const Color.fromARGB(255, 37, 30, 30),
                              height: 36,
                              width: 36,
                            ),
                    ),
                  ],
                ),
              ),
              title: InkWell(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        swipedMessage != null
                            ? 'Replying to ${swipedMessage!.type == 'text' ? swipedMessage!.value['body'] : swipedMessage!.type}'
                            : "+" + widget.phoneNumber,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: WillPopScope(
                onWillPop: () {
                  if (show) {
                    setState(() {
                      show = false;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                  return Future.value(false);
                },
                child: Column(children: [
                  Expanded(
                    // height: MediaQuery.of(context).size.height - 140,
                    child: StreamBuilder<dynamic>(
                        stream: FirebaseFirestore.instance
                            .collection("accounts")
                            .doc(AppConfig.WABAID)
                            .collection("discussion")
                            .doc(widget.phoneNumber)
                            .collection("messages")
                            .orderBy("timestamp")
                            .snapshots(),
                        builder: (context, snapshot) {
                          List<Message> messages = [];
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            if (snapshot.hasData && snapshot.data != null) {
                              for (int i = 0; i < snapshot.data!.size; i++) {
                                print(
                                    'data ========== ${snapshot.data!.docs[i].data()['contacts']}');
                                messages.add(Message.fromMap(
                                    snapshot.data!.docs[i].data()));
                              }
                            }
                          }

                          return ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemCount: messages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == messages.length) {
                                return Container(
                                  height: 70,
                                );
                              }
                              print(
                                  'MESSAGE ++++++++++++++++ ${messages[index]}');
                              if (messages[index].from == AppConfig.phoneNoID) {
                                if (messages[index].context.isNotEmpty) {
                                  return SwipeTo(
                                    onLeftSwipe: (DragUpdateDetails details) {
                                      replyToMessage(messages[index]);
                                      focusNode.requestFocus();
                                    },
                                    child: ReplyMessageCardReply(
                                      message: messages[index],
                                      time: DateFormat("HH:mm").format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              messages[index]
                                                  .timestamp
                                                  .millisecondsSinceEpoch)),
                                      phoneNumber: widget.phoneNumber,
                                      myReply: true,
                                    ),
                                  );
                                } else {
                                  print('+++ 2');
                                  return SwipeTo(
                                    onLeftSwipe: (DragUpdateDetails details) {
                                      replyToMessage(messages[index]);
                                      focusNode.requestFocus();
                                    },
                                    child: OwnMessageCard(
                                        message: messages[index],
                                        time: DateFormat("HH:mm").format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                messages[index]
                                                    .timestamp
                                                    .millisecondsSinceEpoch))),
                                  );
                                }
                              } else {
                                print('+++ 3');
                                if (messages[index].context.isNotEmpty) {
                                  return SwipeTo(
                                    onRightSwipe: (DragUpdateDetails details) {
                                      focusNode.requestFocus();
                                      replyToMessage(messages[index]);
                                    },
                                    child: ReplyMessageCardReply(
                                      message: messages[index],
                                      time: DateFormat("HH:mm").format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              messages[index]
                                                  .timestamp
                                                  .millisecondsSinceEpoch)),
                                      phoneNumber: widget.phoneNumber,
                                      myReply: false,
                                    ),
                                  );
                                } else {
                                  print('+++ 4');
                                  return SwipeTo(
                                    onRightSwipe: (DragUpdateDetails details) {
                                      focusNode.requestFocus();
                                      replyToMessage(messages[index]);
                                    },
                                    child: ReplyCard(
                                        message: messages[index],
                                        time: DateFormat("HH:mm").format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                messages[index]
                                                    .timestamp
                                                    .millisecondsSinceEpoch))),
                                  );
                                }
                              }
                            },
                          );
                        }),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 70,
                                    child: Card(
                                      margin: const EdgeInsets.only(
                                          left: 2, right: 2, bottom: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      child: Column(
                                        children: [
                                          if (swipedMessage != null)
                                            buildReply(),
                                          TextFormField(
                                            controller: _controller,
                                            focusNode: focusNode,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: 5,
                                            minLines: 1,
                                            onChanged: (val) {
                                              if (val.isNotEmpty) {
                                                setState(() {
                                                  sendButton = true;
                                                });
                                              } else {
                                                setState(() {
                                                  sendButton = false;
                                                });
                                              }
                                            },
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: "Type a message",
                                                prefixIcon: IconButton(
                                                    onPressed: () {
                                                      focusNode.unfocus();
                                                      focusNode
                                                              .canRequestFocus =
                                                          false;
                                                      setState(() {
                                                        show = !show;
                                                      });
                                                    },
                                                    icon: const Icon(
                                                        Icons.emoji_emotions)),
                                                suffixIcon: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                        onPressed: () {
                                                          showModalBottomSheet(
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              context: context,
                                                              builder:
                                                                  (builder) {
                                                                return bottomSheet();
                                                              });
                                                        },
                                                        icon: const Icon(
                                                            Icons.attach_file)),
                                                    IconButton(
                                                        onPressed: () {},
                                                        icon: const Icon(
                                                            Icons.camera_alt))
                                                  ],
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.all(5)),
                                          ),
                                        ],
                                      ),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 8,
                                    right: 5,
                                    left: 2,
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: isRecording
                                        ? Color.fromARGB(255, 140, 18, 18)
                                        : const Color(0xff128c7e),
                                    radius: 20,
                                    child: GestureDetector(
                                        onTap: () {
                                          if (sendButton) {
                                            _scrollController.animateTo(
                                                _scrollController
                                                    .position.maxScrollExtent,
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.easeOut);
                                            if (swipedMessage != null) {
                                              sendTextReply(_controller.text);
                                            } else {
                                              sendMessage(
                                                _controller.text,
                                                widget.phoneNumber,
                                              );
                                            }

                                            _controller.clear();
                                            setState(() {
                                              sendButton = false;
                                            });
                                          } else {
                                            isRecording
                                                ? stopRecording()
                                                : record();
                                          }
                                        },
                                        child: Icon(
                                          sendButton ? Icons.send : Icons.mic,
                                          color: Colors.white,
                                        )),
                                  ),
                                )
                              ],
                            ),
                            show ? emojiSelect() : Container(),
                          ],
                        ),
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomSheet() {
    return SizedBox(
      height: 270,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.insert_drive_file, Colors.indigo, "Document",
                      onTap: () async {
                    FilePickerResult? res = await FilePicker.platform.pickFiles(
                        allowMultiple: false,
                        type: FileType.custom,
                        allowedExtensions: [
                          'pdf',
                        ]);

                    if (res == null) {
                      return;
                    }

                    if (res.count > 0) {
                      print(res.names);
                      String filePath = res.files.first.path!;
                      File doc = File(filePath);
                      print('filePath ==================== $filePath');

                      // var payload = await http.MultipartFile.fromPath(
                      //     "file", filePath,
                      //     contentType: MediaType.parse(
                      //         "application/${res.files[0].extension}"));

                      var id = (await widget.whatsApp.uploadMedia(
                          mediaType: MediaType.parse(
                              "application/${res.files[0].extension}"),
                          mediaFile: doc,
                          mediaName: res.files[0].name))['id'];

                      var link = await widget.whatsApp.getMediaUrl(mediaId: id);

                      var mesgRes = await widget.whatsApp.messagesMedia(
                          mediaId: id,
                          // {AUDIO, CONTACTS, DOCUMENT, IMAGE, INTERACTIVE, LOCATION, REACTION, STICKER, TEMPLATE, TEXT, VIDEO}.toLowerCase()
                          mediaType: "document",
                          to: widget.phoneNumber);
                      print('mesgRes = $mesgRes');
                      print('mesgRes id = $id');
                      print('mesgRes link = $link');
                      var messageObject = {
                        "document": {
                          "filename": res.files[0].name,
                          "mime_type": "application/${res.files[0].extension}",
                          "sha256": link['sha256'],
                          "id": id
                        },
                        "type": "document",
                        "from": AppConfig.phoneNoID,
                        "id": mesgRes['messages'][0]['id'],
                        "timestamp": DateTime.now()
                      };

                      await FirebaseFirestore.instance
                          .collection("accounts")
                          .doc(AppConfig.WABAID)
                          .collection("discussion")
                          .doc(widget.phoneNumber)
                          .collection("messages")
                          .add(messageObject);
                    }
                  }),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(
                    Icons.insert_photo,
                    Colors.purple,
                    "Gallery",
                    onTap: () async {
                      // ignore: invalid_use_of_visible_for_testing_member
                      PickedFile? file = await ImagePicker.platform
                          .pickImage(source: ImageSource.gallery);

                      if (file == null) return;

                      File doc = File(file.path);

                      String ext = file.path.split('.').last;

                      var id = (await widget.whatsApp.uploadMedia(
                          mediaType: MediaType.parse(
                              "image/${ext == 'jpg' ? 'jpeg' : ext}"),
                          mediaFile: doc,
                          mediaName: file.path.split('/').last))['id'];
                      var mesgRes;
                      if (swipedMessage == null) {
                        mesgRes = await widget.whatsApp.messagesMedia(
                            mediaId: id,
                            // {AUDIO, CONTACTS, DOCUMENT, IMAGE, INTERACTIVE, LOCATION, REACTION, STICKER, TEMPLATE, TEXT, VIDEO}.toLowerCase()
                            mediaType: "image",
                            to: widget.phoneNumber);
                      } else {
                        mesgRes = await widget.whatsApp.messagesReplyMedia(
                            mediaId: id,
                            messageId: swipedMessage!.id,
                            mediaType: "image",
                            to: widget.phoneNumber);
                      }

                      var link = await widget.whatsApp.getMediaUrl(mediaId: id);

                      print('+++ MESSAGE RES $mesgRes');

                      var messageObject;
                      if (swipedMessage == null) {
                        messageObject = {
                          "image": {
                            "mime_type": "image/${ext == 'jpg' ? 'jpeg' : ext}",
                            "sha256": link['sha256'],
                            "id": id
                          },
                          "type": "image",
                          "from": AppConfig.phoneNoID,
                          "id": mesgRes['messages'][0]['id'],
                          "timestamp": DateTime.now(),
                        };
                      } else {
                        messageObject = {
                          "image": {
                            "mime_type": "image/${ext == 'jpg' ? 'jpeg' : ext}",
                            "sha256": link['sha256'],
                            "id": id
                          },
                          "type": "image",
                          "from": AppConfig.phoneNoID,
                          "id": mesgRes['messages'][0]['id'],
                          "timestamp": DateTime.now(),
                          "context": {
                            'from': swipedMessage!.from,
                            'id': swipedMessage!.id
                          }
                        };
                      }

                      // ignore: unused_local_variable
                      var res = await FirebaseFirestore.instance
                          .collection("accounts")
                          .doc(AppConfig.WABAID)
                          .collection("discussion")
                          .doc(widget.phoneNumber)
                          .collection("messages")
                          .add(messageObject);
                    },
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(
                    Icons.video_file,
                    Colors.purple,
                    "Gallery",
                    onTap: () async {
                      // ignore: invalid_use_of_visible_for_testing_member
                      PickedFile? file = await ImagePicker.platform
                          .pickVideo(source: ImageSource.gallery);

                      if (file == null) return;

                      File doc = File(file.path);

                      String ext = file.path.split('.').last;

                      var id = (await widget.whatsApp.uploadMedia(
                          mediaType: MediaType.parse("video/$ext"),
                          mediaFile: doc,
                          mediaName: file.path.split('/').last))['id'];

                      var mesgRes;
                      if (swipedMessage == null) {
                        mesgRes = await widget.whatsApp.messagesMedia(
                            mediaId: id,
                            // {AUDIO, CONTACTS, DOCUMENT, IMAGE, INTERACTIVE, LOCATION, REACTION, STICKER, TEMPLATE, TEXT, VIDEO}.toLowerCase()
                            mediaType: "video",
                            to: widget.phoneNumber);
                      } else {
                        mesgRes = await widget.whatsApp.messagesReplyMedia(
                            mediaId: id,
                            messageId: swipedMessage!.id,
                            mediaType: "video",
                            to: widget.phoneNumber);
                      }

                      var link = await widget.whatsApp.getMediaUrl(mediaId: id);
                      var messageObject;
                      if (swipedMessage == null) {
                        messageObject = {
                          "video": {
                            "mime_type": "video/$ext",
                            "sha256": link['sha256'],
                            "id": id
                          },
                          "type": "video",
                          "from": AppConfig.phoneNoID,
                          "id": mesgRes['messages'][0]['id'],
                          "timestamp": DateTime.now()
                        };
                      } else {
                        messageObject = {
                          "video": {
                            "mime_type": "video/$ext",
                            "sha256": link['sha256'],
                            "id": id
                          },
                          "type": "video",
                          "from": AppConfig.phoneNoID,
                          "id": mesgRes['messages'][0]['id'],
                          "timestamp": DateTime.now(),
                          "context": {
                            'from': swipedMessage!.from,
                            'id': swipedMessage!.id
                          }
                        };
                      }

                      await FirebaseFirestore.instance
                          .collection("accounts")
                          .doc(AppConfig.WABAID)
                          .collection("discussion")
                          .doc(widget.phoneNumber)
                          .collection("messages")
                          .add(messageObject);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.headset, Colors.orange, "Audio"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(
                    Icons.location_pin,
                    Colors.teal,
                    "Location",
                    onTap: () {
                      checkLocationPermission();
                    },
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.person, Colors.blue, "Contact", onTap: () {
                    if (swipedMessage == null) {
                      Get.toNamed(PhoneContactsPage.id, arguments: {
                        "fromChat": true,
                        'to': int.parse(widget.phoneNumber),
                        'whatsAppApi': widget.whatsApp,
                        'swipedMessageId': null
                      });
                    } else {
                      Get.toNamed(PhoneContactsPage.id, arguments: {
                        "fromChat": true,
                        'to': int.parse(widget.phoneNumber),
                        'whatsAppApi': widget.whatsApp,
                        'swipedMessageId': swipedMessage!.id
                      });
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icon, Color color, String text,
      {void Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icon,
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(text, style: const TextStyle(fontSize: 13, color: Colors.black)),
        ],
      ),
    );
  }

  void replyToMessage(Message message) {
    setState(() {
      swipedMessage = message;
    });
  }

  void cancelReply() {
    setState(() {
      swipedMessage = null;
    });
  }

  Widget buildReply() {
    return Container();
  }

  Widget emojiSelect() {
    return SizedBox(
      height: 300,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          print(emoji);
          setState(() {
            _controller.text += emoji.emoji;
          });
        },
        onBackspacePressed: () {
          // Backspace-Button tapped logic
          // Remove this line to also remove the button in the UI
        },
        config: Config(
          columns: 8,
          emojiSizeMax: 28 * (Platform.isIOS ? 1.30 : 1.0),
          // Issue: https://github.com/flutter/flutter/issues/28894
          verticalSpacing: 0,
          horizontalSpacing: 0,
          initCategory: Category.RECENT,
          bgColor: Colors.white,
          indicatorColor: const Color(0xff128c7e),
          iconColor: Colors.grey,
          iconColorSelected: const Color(0xff128c7e),
          //progressIndicatorColor: const Color(0xff128c7e),
          backspaceColor: const Color(0xff128c7e),
          skinToneDialogBgColor: Colors.white,
          skinToneIndicatorColor: Colors.grey,
          enableSkinTones: true,
          //showRecentsTab: true,
          recentsLimit: 28,
          //noRecentsText: "No Recents",
          //noRecentsStyle: const TextStyle(fontSize: 20, color: Colors.black26),
          tabIndicatorAnimDuration: kTabScrollDuration,
          categoryIcons: const CategoryIcons(),
          buttonMode: ButtonMode.CUPERTINO,
        ),
      ),
    );
  }
}
