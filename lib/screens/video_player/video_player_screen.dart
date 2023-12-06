//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/src/widgets/framework.dart';
//import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:starz/screens/video_player/components/video_player_widget.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({super.key});

  static const id = '/videoPlayerScreen';
  final String link = Get.arguments['link'];
  final headers = Get.arguments['headers'];

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print('widget.link ========== ${widget.link}');
    controller =
        VideoPlayerController.network(widget.link, httpHeaders: widget.headers)
          ..addListener(() => setState(() {}))
          ..setLooping(true)
          ..initialize().then((_) => controller.play());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isMuted = controller.value.volume == 0;

    return SafeArea(
      child: Material(
        child: Column(children: [
          VideoPlayerWidget(controller: controller),
          // const SizedBox(height: 32),
          // if (controller != null && controller.value.isInitialized)
          //   CircleAvatar(
          //     radius: 30,
          //     backgroundColor: Colors.red,
          //     child: IconButton(
          //       icon: Icon(
          //         isMuted ? Icons.volume_mute : Icons.volume_up,
          //         color: Colors.white,
          //       ),
          //       onPressed: () {
          //         controller.setVolume(isMuted ? 1 : 0);
          //       },
          //     ),
          //   )
        ]),
      ),
    );
  }
}
