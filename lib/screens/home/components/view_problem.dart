import 'dart:convert';

import 'package:STARZ/models/problem_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ViewProblemPage extends StatefulWidget {
  final Problem problem;

  static const id = '/view_problem';
  final String enteredWABAID;

  const ViewProblemPage(
      {super.key, required this.problem, required this.enteredWABAID});

  @override
  State<ViewProblemPage> createState() => _ViewProblemPageState();
}

class _ViewProblemPageState extends State<ViewProblemPage> {
  TextEditingController replyController = TextEditingController();
  final RatingWidget myRatingWidget = Get.isDarkMode
      ? RatingWidget(
          full: const Icon(Icons.star, color: Colors.yellow),
          half: const Icon(Icons.star_half, color: Colors.yellow),
          empty: const Icon(Icons.star_border, color: Colors.grey),
        )
      : RatingWidget(
          full: Icon(Icons.star, color: Colors.yellow[800]),
          half: Icon(Icons.star_half, color: Colors.yellow[800]),
          empty: const Icon(Icons.star_border, color: Colors.grey),
        );

  FocusNode focusNode = FocusNode();

  Future<void> addReply() async {
    // Validate and add reply to the problem
    String replyText = replyController.text.trim();
    if (replyText.isNotEmpty) {
      try {
        // Generate a unique ID for the new reply
        String newReplyId =
            FirebaseFirestore.instance.collection('dummy').doc().id;

        // Get the current timestamp
        Timestamp timestamp = Timestamp.now();

        // Create a new reply object
        Reply newReply = Reply(
          id: newReplyId,
          userId: widget.enteredWABAID, // Replace with the actual user ID
          text: replyText,
          starRating: 0, // Set an initial star rating
          timestamp: timestamp,
        );

        // Add the reply to the Firestore collection
        await FirebaseFirestore.instance
            .collection('problems')
            .doc(widget.problem.id) // Use the problem's document ID
            .update({
          'replies.$newReplyId': newReply.toJson(),
        });

        // Update the local state to reflect the changes
        setState(() {
          widget.problem.replies[newReply.id] = newReply;
          replyController.clear();
        });
      } catch (e) {
        print('Error adding reply: $e');
      }
    }
  }

  Future<void> rateReply(Reply reply, double rating) async {
    try {
      // Update the star rating of the reply locally
      setState(() {
        reply.starRating = rating;
      });

      // Update the Firestore document with the new star rating
      await FirebaseFirestore.instance
          .collection('problems')
          .doc(widget.problem.id)
          .update({
        'replies.${reply.id}.starRating':
            rating, // Update only starRating field
      });

      // Update the local list with the new star rating
      setState(() {
        widget.problem.replies[reply.id]?.starRating = rating;
      });
    } catch (e) {
      print('Error updating star rating: $e');
    }
  }

  String getFormattedDateTag(DateTime date) {
    DateTime now = DateTime.now();

    if (now.year == date.year &&
        now.month == date.month &&
        now.day == date.day) {
      // Today
      return 'Today';
    } else if (now.year == date.year &&
        now.month == date.month &&
        now.day - date.day == 1) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Other dates
      return DateFormat.yMMMd().format(date);
    }
  }

  Future<String?> fetchBusinessName(String accessToken, String wabaId) async {
    var url =
        'https://graph.facebook.com/v19.0/$wabaId?fields=name&access_token=$accessToken';
    Uri uri = Uri.parse(url);

    final response = await http.get(uri);

    if (response.statusCode == 400) {
      print('Entered waba id: $wabaId');
      print('Bad Request 1: ${response.body}');
      // Handle the error or return an empty list
      return null;
    } else if (response.statusCode == 200) {
      print('Entered waba id: $wabaId');
      print('Good Request 2: ${response.body}');
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('name')) {
        print('Good Request 3: ${response.body}');
        return responseData['name'];
      } else {
        print('No business name found for the WABA ID: $wabaId');
        return '';
      }
    } else {
      print('Bad Request 2: ${response.body}');
      print(
          'Failed to fetch business name. Status code: ${response.statusCode}');
      throw Exception(
          'Failed to fetch business name. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Problem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            ),
            Text(
              widget.problem.description,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Category:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.problem.category),
            const SizedBox(height: 16),
            const Text(
              'Replies:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.problem.replies.length,
                itemBuilder: (context, index) {
                  Reply reply = widget.problem.replies.values.elementAt(index);
                  bool isCurrentUserReply =
                      reply.userId == widget.enteredWABAID;
                  DateTime formattedTime = DateTime.fromMillisecondsSinceEpoch(
                    widget.problem.replies.values
                        .elementAt(index)
                        .timestamp
                        .millisecondsSinceEpoch,
                  );
                  return Card(
                    elevation: 3,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
                    child: ListTile(
                      title: FutureBuilder<String?>(
                        future: fetchBusinessName(
                          "EAAMEyX45PoMBO18lFTrAnLeKbiDi2qJAL7Nec61OLZAayaIqcWYAczQn3jGlWuWGwWZBFOjFk1ZBTBNqhjZCZAvLpww7XlgJps4SCsKUlgDmgNZBx6hl82AQdzJCZAZB12nxyIuvKAKUNBrcNFgfbSfN6lMXxqxZBdF5carAwaQSZA2KJWZAzjAXoLBjbLJq9BkIWGa",
                          reply.userId,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // While data is loading, display a placeholder
                            return Text(
                              'Loading...',
                              style: GoogleFonts.nunito(fontSize: 15),
                            );
                          } else if (snapshot.hasError) {
                            // If there's an error, display an error message
                            return Text(
                              'Error loading business name',
                              style: GoogleFonts.nunito(fontSize: 15),
                            );
                          } else {
                            // If data is successfully fetched, display the business name
                            return Text(
                              'User: ${snapshot.data}',
                              style: GoogleFonts.nunito(fontSize: 15),
                            );
                          }
                        },
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                reply.text,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              RatingBar(
                                itemSize: 25,
                                ratingWidget: myRatingWidget,
                                initialRating: reply.starRating,
                                allowHalfRating: true,
                                onRatingUpdate: (rating) {
                                  rateReply(reply, rating);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Karma points: ${reply.starRating}',
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic),
                              ),
                              if (isCurrentUserReply) ...[
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // Edit reply logic
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            TextEditingController
                                                editController =
                                                TextEditingController(
                                                    text: reply.text);
                                            return AlertDialog(
                                              title: const Text(
                                                'Edit Reply',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              content: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                child: TextField(
                                                  controller: editController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Edit reply',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  maxLines:
                                                      5, // Adjust the number of lines as needed
                                                ),
                                              ),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  onPressed: () {
                                                    // Update the reply text in local state
                                                    setState(() {
                                                      widget.problem.replies[
                                                          reply.id] = Reply(
                                                        id: reply.id,
                                                        userId: reply.userId,
                                                        text:
                                                            editController.text,
                                                        starRating:
                                                            reply.starRating,
                                                        timestamp:
                                                            reply.timestamp,
                                                      );
                                                    });

                                                    // Update the reply in Firestore
                                                    FirebaseFirestore.instance
                                                        .collection('problems')
                                                        .doc(widget.problem.id)
                                                        .update({
                                                      'replies.${reply.id}.text':
                                                          editController.text,
                                                    });
                                                    // Update the local state to reflect the changes
                                                    Navigator.of(context).pop();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        Colors.blue,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Save',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(
                                        Icons.edit,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Confirm Delete'),
                                              content: const Text(
                                                  'Are you sure you want to delete this reply?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    // Delete reply logic
                                                    FirebaseFirestore.instance
                                                        .collection('problems')
                                                        .doc(widget.problem.id)
                                                        .update({
                                                      'replies.${reply.id}':
                                                          FieldValue.delete(),
                                                    });
                                                    setState(() {
                                                      // Remove the reply from local state
                                                      widget.problem.replies
                                                          .remove(reply.id);
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Yes'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('No'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 120,
                        child: Text(
                          getFormattedDateTag(formattedTime)
                              .replaceAll('AM', 'am')
                              .replaceAll('PM', 'pm'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: replyController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.question_answer_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: "Enter solution",
                      hintStyle: GoogleFonts.nunito(
                        color: const Color.fromARGB(255, 118, 114, 114),
                        fontStyle: FontStyle.italic,
                      ),
                      labelText: 'Solution',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                    right: 5,
                    left: 2,
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xff128c7e),
                    radius: 20,
                    child: GestureDetector(
                      onTap: addReply,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
            //const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
