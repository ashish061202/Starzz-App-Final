import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RainAnimation extends StatelessWidget {
  const RainAnimation({Key? key});

  static const id = "/Rain_animation";

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF171D28),
      body: Stack(
        children: [
          for (int index = 0; index < 300; index++)
            _StarDrop(
              screenHeight: screenSize.height,
              screenWidth: screenSize.width,
            ),
        ],
      ),
    );
  }
}

class _StarDrop extends StatefulWidget {
  final double screenHeight, screenWidth;

  const _StarDrop({
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  State<_StarDrop> createState() => _StarDropState();
}

class _StarDropState extends State<_StarDrop>
    with SingleTickerProviderStateMixin {
  late double dx, dy, size, opacity, vy;

  Random random = Random();
  double get screenHeight => widget.screenHeight;

  double get screenWidth => widget.screenWidth;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    randomizeValues();
    _ticker = createTicker((elapsed) {
      dy += vy;
      if (dy >= screenHeight + 100) {
        randomizeValues();
      }
      setState(() {});
    });
    _ticker.start();
  }

  randomizeValues() {
    dx = random.nextDouble() * screenWidth;
    dy = -500 - (random.nextDouble() * -500);
    size = random.nextDouble() * 10; // Size between 1 and 5
    opacity = random.nextDouble() * 0.5 + 0.3; // Opacity between 0.3 and 0.7
    vy = random.nextDouble() * 1 + 1; // Velocity between 5 and 10
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Opacity(
        opacity: opacity,
        child: Icon(
          Icons.star,
          size: size,
          color: Colors.white,
        ),
      ),
    );
  }
}
