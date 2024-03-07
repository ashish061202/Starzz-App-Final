import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ProfilePhotoViewPage extends StatefulWidget {
  final File imageFile;
  final String? imageUrl;

  const ProfilePhotoViewPage(
      {super.key, required this.imageFile, required this.imageUrl});

  @override
  State<ProfilePhotoViewPage> createState() => _ProfilePhotoViewPageState();
}

class _ProfilePhotoViewPageState extends State<ProfilePhotoViewPage> {
  late List<ImageProvider> imageProviders;

  @override
  void initState() {
    super.initState();
    imageProviders = _getImageProviders();
  }

  List<ImageProvider> _getImageProviders() {
    List<ImageProvider> providers = [];
    if (widget.imageFile != null && widget.imageFile!.existsSync()) {
      // If it's a local file
      providers.add(FileImage(widget.imageFile!));
    }
    if (widget.imageUrl != null) {
      // If it's a remote URL
      providers.add(NetworkImage(widget.imageUrl!));
    }
    return providers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Photo',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this color to the desired color
        ),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          // Check if the user is swiping down
          if (details.primaryDelta! > 4.0) {
            Navigator.pop(context); // Pop the current route
          }
        },
        child: Hero(
          tag: 'profileImage', // Same tag used in the ProfileScreen
          createRectTween: (begin, end) {
            return RectTween(
              begin: begin,
              end: end,
            );
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: PhotoViewGallery.builder(
              itemCount: imageProviders.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: imageProviders[index],
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
              pageController: PageController(),
            ),
          ),
        ),
      ),
    );
  }
}
