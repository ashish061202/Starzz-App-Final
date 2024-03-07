import 'package:get/get.dart';

class ChatController extends GetxController {
  RxInt newMessageCount = 0.obs;

  void incrementNewMessageCount() {
    newMessageCount++;
  }

  void resetNewMessageCount() {
    newMessageCount.value = 0;
  }
}