// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  Map<String, dynamic> context;
  String from;
  String id;
  Timestamp timestamp;
  String type;
  dynamic value;
  Message({
    required this.context,
    required this.from,
    required this.id,
    required this.timestamp,
    required this.type,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'from': from,
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type,
      '$type': value,
    };
  }

  factory Message.fromMap(Map<String, dynamic>? map) {
    return Message(
      context: map!["context"] ?? {},
      from: map['from'] as String,
      id: map['id'] as String,
      timestamp: map['timestamp'],
      type: map['type'] as String,
      value: map["${map['type']}"] ?? {},
    );
  }

  factory Message.fromMapContact(Map<String, dynamic>? map) {
    return Message(
        context: map!["context"] ?? {},
        from: map['from'] as String,
        id: map['id'] as String,
        timestamp: map['timestamp'],
        type: map['type'] as String,
        value: [
          'haha',
        ]
        // ?? [],
        );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(from: $from, id: $id, timestamp: $timestamp, type: $type, text: $value)';
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;

    return other.from == from &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.type == type &&
        other.value == value;
  }

  @override
  int get hashCode {
    return from.hashCode ^
        id.hashCode ^
        timestamp.hashCode ^
        type.hashCode ^
        value.hashCode;
  }
}
