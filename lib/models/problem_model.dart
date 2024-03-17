import 'package:cloud_firestore/cloud_firestore.dart';

class Problem {
  final String id;
  final String description;
  final String userId;
  final String category;
  final double starRating;
  final Map<String, Reply> replies;

  Problem({
    required this.id,
    required this.description,
    required this.userId,
    required this.category,
    required this.starRating,
    required this.replies,
  });
}

class Reply {
  final String id;
  final String userId;
  final String text;
  double starRating;
  final Timestamp timestamp;

  Reply({
    required this.id,
    required this.userId,
    required this.text,
    required this.starRating,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'starRating': starRating,
      'timestamp': timestamp,
    };
  }
}
