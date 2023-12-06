import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        //color: Colors.amberAccent,
        image: DecorationImage(
            image: AssetImage(
              "assets/wallpaper.jpg",
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Color.fromARGB(160, 0, 0, 0), BlendMode.darken)),
      ),
    );
  }
}
