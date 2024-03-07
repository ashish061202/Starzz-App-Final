import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
//import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:STARZ/api/whatsapp_api.dart';
import 'package:STARZ/config.dart';

class ConctactsController extends GetxController {
  RxList<Contact> contacts = <Contact>[].obs;
  RxList<Contact> filteredContacts = <Contact>[].obs;
  TextEditingController searchQuery = TextEditingController();
  WhatsAppApi whatsapp = WhatsAppApi();
  final wabaidController = Get.find<WABAIDController>();
  late String phoneNumberId = wabaidController.phoneNumber;

  @override
  void onInit() {
    super.onInit();
    getInitialContacts();
    whatsapp.setup(
        accessToken: AppConfig.apiKey,
        fromNumberId: int.parse(phoneNumberId));
  }

  @override
  void dispose() {
    searchQuery.dispose();
    super.dispose();
  }

  int getIndexOfFirstContactWithLetter(String alphabet) {
    for (int i = 0; i < filteredContacts.length; i++) {
      if (filteredContacts[i].name.first.startsWith(alphabet)) {
        return i;
      }
    }
    return 0; // Default to the beginning if not found
  }

  Future<void> getInitialContacts() async {
    if (await FlutterContacts.requestPermission()) {
      contacts.value = await FlutterContacts.getContacts(withProperties: true);
      // ignore: invalid_use_of_protected_member
      filteredContacts.value = contacts.value;
      contacts.refresh();
      filteredContacts.refresh();
    }
  }

  void updateFilteredContacts() {
    if (contacts.value != null && contacts.isNotEmpty) {
      // Split the search query into words
      List<String> searchWords = searchQuery.text.toLowerCase().split(' ');

      // Filter contacts based on each word
      filteredContacts.value = contacts.value.where((contact) {
        for (String word in searchWords) {
          if (!(contact.name.first.toLowerCase().contains(word) ||
              contact.name.last.toLowerCase().contains(word) ||
              (contact.phones.isNotEmpty &&
                  contact.phones.first.number.toLowerCase().contains(word)))) {
            return false;
          }
        }
        return true;
      }).toList();
    } else {
      // Handle the case where contacts is null or empty
      filteredContacts.clear();
    }
  }
}
