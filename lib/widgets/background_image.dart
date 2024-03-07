import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        //color: Colors.amberAccent,
        image: DecorationImage(
            image: AssetImage(
              Get.isDarkMode
                  ? "assets/whatsapp-dark-wallpaper.jpg"
                  : "assets/wallpaper.jpg",
            ),
            fit: BoxFit.cover,
            colorFilter: Get.isDarkMode
                ? const ColorFilter.mode(
                    Color.fromARGB(100, 0, 0, 0), BlendMode.darken)
                : const ColorFilter.mode(
                    Color.fromARGB(160, 0, 0, 0), BlendMode.darken)),
      ),
    );
  }
}
