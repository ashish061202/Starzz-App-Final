// wabaid_controller.dart

import 'package:get/get.dart';

class WABAIDController extends GetxController {
  late String enteredWABAID;

  void setEnteredWABAID(String value) {
    enteredWABAID = value;
    update(); // Update the state
  }
}