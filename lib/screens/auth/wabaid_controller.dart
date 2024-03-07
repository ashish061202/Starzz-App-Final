// wabaid_controller.dart

import 'package:get/get.dart';

class WABAIDController extends GetxController {
  late String enteredWABAID;
  late String phoneNumber; // Add this line

  void setEnteredWABAID(String value) {
    enteredWABAID = value;
    update(); // Update the state
  }

  void setPhoneNumber(String value) {
    phoneNumber = value;
    update();
  }
}