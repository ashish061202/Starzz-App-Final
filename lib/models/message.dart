// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:collection';

import 'package:flutter/foundation.dart';

class Reaction {
  final String messageId;
  final String emoji;

  Reaction({
    required this.messageId,
    required this.emoji,
  });

  factory Reaction.fromMap(Map<String, dynamic> map) {
    return Reaction(
      messageId: map['message_id'] ?? '',
      emoji: map['emoji'] ?? '',
    );
  }
}

class Message {
  Map<String, dynamic> context;
  String from;
  final String id;
  String documentId;
  String contextMessageId; // New property for the Firestore document ID
  bool isSeen;
  String senderFCMToken; // FCM token of the sender
  String recipientFCMToken; // FCM token of the recipient

  Timestamp timestamp;
  final String type;
  dynamic value;
  List<Reaction> reactions; // List of reactions

  Message({
    required this.context,
    required this.from,
    required this.id,
    required this.timestamp,
    required this.type,
    required this.value,
    required this.reactions,
    required this.contextMessageId,
    required this.isSeen,
    required this.senderFCMToken,
    required this.recipientFCMToken,
  }) : documentId = ''; // Initialize documentId to empty string;

  // New method to set the Firestore document ID
  void setDocumentId(String docId) {
    documentId = docId;
  }

  // Named constructor for creating a default instance
  Message.empty()
      : context = {}, // Provide default values for all properties
        isSeen = false,
        from = '',
        id = '',
        documentId = '',
        contextMessageId = '',
        timestamp = Timestamp.now(),
        type = '',
        value = null,
        senderFCMToken = '',
        recipientFCMToken = '',
        reactions = [];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> baseMap = {
      'from': from,
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type,
      '$type': value,
      'contextMessageId': contextMessageId,
      'context': {
        'isSeen': isSeen,
      },
    };

    if (type == 'order') {
      // Include order-specific information in the map
      baseMap['order'] = value;
    }

    return baseMap;
  }

  factory Message.fromMap(Map<String, dynamic>? map, String documentId) {
    String contextMessageId = map?['context']?['id'] ?? '';
    return Message(
      isSeen: map?['context']?['isSeen'] ?? false,
      context: map!["context"] ?? {},
      from: map['from'] as String,
      id: map['id'] as String? ?? '',
      timestamp: map['timestamp'],
      type: map['type'] as String,
      value: map["${map['type']}"] ?? map['order'] ?? {},
      senderFCMToken: map!['senderFCMToken'] ?? '',
      recipientFCMToken: map['recipientFCMToken'] ?? '',
      reactions: (map['reactions'] as List<Map<String, dynamic>>?)
              ?.map((reaction) => Reaction.fromMap(reaction))
              .toList() ??
          [],
      contextMessageId: contextMessageId,
    )..documentId = documentId; // Set the documentId;
  }

  factory Message.fromMapContact(Map<String, dynamic>? map) {
    return Message(
      isSeen: map?['context']?['isSeen'] ?? false,
      context: map!["context"] ?? {},
      from: map['from'] as String,
      id: map['id'] as String,
      timestamp: map['timestamp'],
      type: map['type'] as String,
      value: [
        'haha',
      ],
      senderFCMToken: map!['senderFCMToken'] ?? '',
      recipientFCMToken: map['recipientFCMToken'] ?? '',
      reactions: [], contextMessageId: '',
      // ?? [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) {
    final Map<String, dynamic> map = json.decode(source);
    final String documentId =
        map['documentId'] as String; // Adjust the key as per your actual data
    return Message.fromMap(map, documentId);
  }

  @override
  String toString() {
    return 'Message(from: $from, id: $id,documentId: $documentId, timestamp: $timestamp, type: $type, text: $value, reactions: $reactions, isSeen: $isSeen)';
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;

    return other.from == from &&
        other.id == id &&
        other.documentId == documentId && // Include documentId in comparison
        other.timestamp == timestamp &&
        other.type == type &&
        other.value == value &&
        listEquals(other.reactions, reactions);
  }

  @override
  int get hashCode {
    return from.hashCode ^
        id.hashCode ^
        documentId.hashCode ^ // Include documentId in hashCode
        timestamp.hashCode ^
        type.hashCode ^
        value.hashCode ^
        reactions.hashCode;
  }
}
