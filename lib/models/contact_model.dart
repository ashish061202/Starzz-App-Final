import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  final String roomId;
  final String user;
  final Timestamp lastMessageTimestamp;
  bool pinned;

  ContactModel({
    required this.roomId,
    required this.user,
    required this.lastMessageTimestamp,
    this.pinned = false,
  });
}
