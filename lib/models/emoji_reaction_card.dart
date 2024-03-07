import 'package:flutter/material.dart';

class EmojiReactionCard extends StatelessWidget {
  final String emoji;

  const EmojiReactionCard({super.key, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 4,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          emoji,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
