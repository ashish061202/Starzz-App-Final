import 'package:flutter/material.dart';

class CustomHeroController extends HeroController {
  Duration get duration =>
      const Duration(milliseconds: 10000); // Adjust the duration as needed

  Duration get reverseDuration => const Duration(
      milliseconds: 10000); // Adjust the reverse duration as needed
}
