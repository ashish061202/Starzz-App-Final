//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/src/widgets/framework.dart';
//import 'package:flutter/src/widgets/placeholder.dart';
import 'package:starz/screens/video_player/components/basic_overlay_widget.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayerWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return
        //controller != null &&
        controller.value.isInitialized
            ? Container(
                alignment: Alignment.topCenter,
                child: buildVideo(),
              )
            : Container(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
  }

  Widget buildVideo() => Stack(children: [
        buildVideoPlayer(),
        Positioned.fill(child: BasicOverlayWidget(controller: controller))
      ]);

  Widget buildVideoPlayer() => AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller));
}
