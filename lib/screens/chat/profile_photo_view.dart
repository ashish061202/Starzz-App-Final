import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePhotoViewer extends StatelessWidget {
  const ProfilePhotoViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle, // This makes the container circular
          color: Colors.white, // Customize the color as needed
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add your content for the circular pop-up here
            // For example, display the profile photo in a circular container
            CircleAvatar(
              radius: 100.0, // Adjust the radius as needed
              backgroundColor: Colors.blueGrey,
              child: SvgPicture.asset(
                "assets/person.svg",
                color: Colors.white,
                height: 160,
                width: 160,
              ),
            ),
            // Add any additional content you need for the pop-up
          ],
        ),
      ),
    );
  }
}
