import 'dart:io';
import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:STARZ/config.dart';
import 'package:STARZ/api/whatsapp_api.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:STARZ/models/message.dart';
import 'package:STARZ/screens/chat/chat_page.dart';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  final CameraController? controller;
  final String roomId;
  final String phoneNumber;

  CameraScreen(
      {super.key,
      this.controller,
      required this.roomId,
      required this.phoneNumber}) {
    whatsApp = WhatsAppApi();
    whatsApp.setup(
        accessToken: AppConfig.apiKey,
        fromNumberId: int.tryParse(phoneNumberId));
  }

  late WhatsAppApi whatsApp;
  static const id = "/cameraScreen";
  final wabaidController = Get.find<WABAIDController>();
  late String phoneNumberId = wabaidController.phoneNumber;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _imageFile;
  XFile? _videoFile;
  late VideoPlayerController? _videoPlayerController;
  bool _isRecording = false;
  bool _isImageMode = true;
  bool _isSending = false;
  Message? swipedMessage;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ??
        CameraController(
          const CameraDescription(
            name: "0",
            lensDirection: CameraLensDirection.front,
            sensorOrientation: 0,
          ),
          ResolutionPreset.high,
        );

    _initializeControllerFuture = _controller.initialize();
    _videoPlayerController = VideoPlayerController.network('');
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopVideoRecording();
    } else {
      await _startVideoRecording();
    }
  }

  // Add this method to record a video
  Future<void> _startVideoRecording() async {
    try {
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    try {
      XFile videoFile = await _controller.stopVideoRecording();
      setState(() {
        _videoFile = videoFile;
        _isRecording = false;
      });
      _videoPlayerController = VideoPlayerController.file(File(videoFile.path))
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController!.play();
        });
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  // Add this method to capture an image
  Future<void> _captureImage() async {
    try {
      final XFile imageFile = await _controller.takePicture();
      setState(() {
        _imageFile = imageFile;
      });

      // Do something with the captured image (e.g., display it, save it, etc.)
      print('Image captured: ${imageFile.path}');
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<void> _sendImage() async {
    // Check if _imageFile is not null before using it
    if (_imageFile != null) {
      try {
        print('Image file path: ${_imageFile?.path}');
        // Upload the captured image to WhatsApp
        String fileExtension = getFileExtension(_imageFile!.path);
        print('File extension: ${getFileExtension(_imageFile!.path)}');

        // Upload the captured image to WhatsApp using similar logic as from the gallery
        Map<String, dynamic>? uploadResponse =
            await widget.whatsApp.uploadMedia(
          mediaType: MediaType.parse("image/jpeg"),
          mediaFile: File(_imageFile!.path),
          mediaName: _imageFile!.path.split('/').last,
        );

        // Log the upload response for debugging
        print('Upload Response: $uploadResponse');

        // Check if the upload was successful and contains the 'id' key
        if (uploadResponse != null && uploadResponse.containsKey('id')) {
          var id = uploadResponse['id'];

          // Send the image message to WhatsApp
          var mesgRes;
          if (swipedMessage == null) {
            mesgRes = await widget.whatsApp.messagesMedia(
              mediaId: id,
              mediaType: "image",
              to: widget.phoneNumber,
            );
          } else {
            mesgRes = await widget.whatsApp.messagesReplyMedia(
              mediaId: id,
              messageId: swipedMessage!.id,
              mediaType: "image",
              to: widget.phoneNumber,
            );
          }

          // Get the media URL
          var link = await widget.whatsApp.getMediaUrl(mediaId: id);

          // Create a message object
          var messageObject;
          if (swipedMessage == null) {
            messageObject = {
              "image": {
                "mime_type": "image/jpeg",
                "sha256": link['sha256'],
                "id": id,
              },
              "type": "image",
              "from": AppConfig.phoneNoID,
              "id": mesgRes['messages'][0]['id'],
              "timestamp": DateTime.now(),
            };
          } else {
            messageObject = {
              "image": {
                "mime_type": "image/$fileExtension",
                "sha256": link['sha256'],
                "id": id,
              },
              "type": "image",
              "from": AppConfig.phoneNoID,
              "id": mesgRes['messages'][0]['id'],
              "timestamp": DateTime.now(),
              "context": {'from': swipedMessage!.from, 'id': swipedMessage!.id},
            };
          }

          // Add the message to Firestore
          var res = await FirebaseFirestore.instance
              .collection("accounts")
              .doc(AppConfig.WABAID)
              .collection("discussion")
              .doc(widget.phoneNumber)
              .collection("messages")
              .add(messageObject);

          print('+++ MESSAGE RES $res');

          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        } else {
          print('Error uploading media: Response does not contain "id"');
        }
      } catch (e) {
        print('Error sending image: $e');
      } finally {
        // Always set _isSending to false after the sending process
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _sendVideo() async {
    // Check if _videoFile is not null before using it
    if (_videoFile != null) {
      try {
        print('Video file path: ${_videoFile?.path}');
        // Upload the captured video to WhatsApp
        String fileExtension = getFileExtension(_videoFile!.path);
        print('File extension: ${getFileExtension(_videoFile!.path)}');

        // Upload the captured video to WhatsApp using similar logic as from the gallery
        Map<String, dynamic>? uploadResponse =
            await widget.whatsApp.uploadMedia(
          mediaType: MediaType.parse("video/mp4"),
          mediaFile: File(_videoFile!.path),
          mediaName: _videoFile!.path.split('/').last,
        );

        // Log the upload response for debugging
        print('Upload Response: $uploadResponse');

        // Check if the upload was successful and contains the 'id' key
        if (uploadResponse != null && uploadResponse.containsKey('id')) {
          var id = uploadResponse['id'];

          // Send the video message to WhatsApp
          var mesgRes;
          if (swipedMessage == null) {
            mesgRes = await widget.whatsApp.messagesMedia(
              mediaId: id,
              mediaType: "video",
              to: widget.phoneNumber,
            );
          } else {
            mesgRes = await widget.whatsApp.messagesReplyMedia(
              mediaId: id,
              messageId: swipedMessage!.id,
              mediaType: "video",
              to: widget.phoneNumber,
            );
          }

          // Get the media URL
          var link = await widget.whatsApp.getMediaUrl(mediaId: id);

          // Create a message object
          var messageObject;
          if (swipedMessage == null) {
            messageObject = {
              "video": {
                "mime_type": "video/mp4",
                "sha256": link['sha256'],
                "id": id,
              },
              "type": "video",
              "from": AppConfig.phoneNoID,
              "id": mesgRes['messages'][0]['id'],
              "timestamp": DateTime.now(),
            };
          } else {
            messageObject = {
              "video": {
                "mime_type": "video/$fileExtension",
                "sha256": link['sha256'],
                "id": id,
              },
              "type": "video",
              "from": AppConfig.phoneNoID,
              "id": mesgRes['messages'][0]['id'],
              "timestamp": DateTime.now(),
              "context": {'from': swipedMessage!.from, 'id': swipedMessage!.id},
            };
          }

          // Add the message to Firestore
          var res = await FirebaseFirestore.instance
              .collection("accounts")
              .doc(AppConfig.WABAID)
              .collection("discussion")
              .doc(widget.phoneNumber)
              .collection("messages")
              .add(messageObject);

          print('+++ MESSAGE RES $res');

          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        } else {
          print('Error uploading media: Response does not contain "id"');
        }
      } catch (e) {
        print('Error sending video: $e');
      } finally {
        // Always set _isSending to false after the sending process
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // Helper method to get file extension
  String getFileExtension(String path) {
    return path.split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview
            return Column(
              children: [
                Expanded(
                  child: _isImageMode
                      ? (_imageFile != null
                          ? Image.file(File(_imageFile!.path))
                          : CameraPreview(_controller))
                      : (_videoFile != null
                          ? _videoPlayerController!.value.isInitialized
                              ? VideoPlayer(_videoPlayerController!)
                              : const CircularProgressIndicator()
                          : CameraPreview(_controller)),
                ),
                if (_imageFile == null && _videoFile == null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (!_isRecording)
                        ElevatedButton(
                          onPressed: () {
                            _toggleRecording();
                            setState(() {
                              _isRecording = true;
                              _isImageMode = false;
                            });
                          },
                          child: const Icon(Icons.videocam),
                        ),
                      if (!_isRecording)
                        ElevatedButton(
                          onPressed: _captureImage,
                          child: const Icon(Icons.camera),
                        ),
                      if (_isRecording)
                        ElevatedButton(
                          onPressed: () {
                            _stopVideoRecording();
                            setState(() {
                              _isRecording = false;
                            });
                          },
                          child: const Text('Stop Recording'),
                        ),
                    ],
                  )
                else if (_imageFile == null)
                  ElevatedButton(
                    onPressed: () {
                      _sendVideoWithLoading();
                    },
                    child: const Text('Send Video'),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _sendImageWithLoading();
                        },
                        child: const Text('Send Image'),
                      ),
                    ],
                  ),
                if (_isSending)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> _sendImageWithLoading() async {
    setState(() {
      _isSending = true;
    });

    await _sendImage();

    setState(() {
      _isSending = false;
    });
  }

  Future<void> _sendVideoWithLoading() async {
    setState(() {
      _isSending = true;
    });

    await _sendVideo();

    setState(() {
      _isSending = false;
    });
  }
}
