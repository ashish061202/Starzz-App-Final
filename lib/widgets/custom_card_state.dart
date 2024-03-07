import 'package:flutter/material.dart';

class CustomCardStateNotifier extends ChangeNotifier {
  final Map<String, String> savedContactNames = {};

  void updateSavedContactName({
    required String toPhoneNumber,
    required String newName,
  }) {
    savedContactNames[toPhoneNumber] = newName;
    notifyListeners();
  }
}

