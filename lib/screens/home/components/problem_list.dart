import 'package:STARZ/models/problem_model.dart';
import 'package:STARZ/screens/home/components/add_problem.dart';
import 'package:STARZ/screens/home/components/view_problem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProblemsListPage extends StatefulWidget {
  const ProblemsListPage({super.key, required this.enteredWABAID});

  static const id = '/problem_list';
  final String enteredWABAID;

  @override
  State<ProblemsListPage> createState() => _ProblemsListPageState();
}

class _ProblemsListPageState extends State<ProblemsListPage> {
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
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference problemsCollection = firestore.collection('problems');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Problems List'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddProblemPage(
                  enteredWABAID: widget.enteredWABAID,
                ),
              ),
            );
          },
          backgroundColor: Get.isDarkMode
              ? Colors.purple.shade300
              : const Color.fromARGB(255, 107, 74, 207),
          child: Icon(
            Icons.add,
            color: Get.isDarkMode ? Colors.white : Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: problemsCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          List<Problem> problems = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            Map<String, Reply> replies = {};
            if (data['replies'] is Map<String, dynamic>) {
              replies = (data['replies'] as Map<String, dynamic>).map(
                (key, replyData) => MapEntry(
                  key,
                  Reply(
                    id: replyData['id'],
                    userId: replyData['userId'],
                    text: replyData['text'],
                    starRating: (replyData['starRating'] as num).toDouble(),
                    timestamp: replyData['timestamp'],
                  ),
                ),
              );
            }

            return Problem(
              id: doc.id,
              description: data['description'],
              userId: data['userId'],
              category: data['category'],
              starRating: data['starRating'],
              replies: replies,
            );
          }).toList();

          return ListView.builder(
            itemCount: problems.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () {
                    // Navigate to a page for viewing and responding to the problem
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewProblemPage(
                          problem: problems[index],
                          enteredWABAID: widget.enteredWABAID,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          problems[index].description,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Category: ${problems[index].category}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            FutureBuilder<String?>(
                              future: fetchBusinessName(
                                "EAAMEyX45PoMBO18lFTrAnLeKbiDi2qJAL7Nec61OLZAayaIqcWYAczQn3jGlWuWGwWZBFOjFk1ZBTBNqhjZCZAvLpww7XlgJps4SCsKUlgDmgNZBx6hl82AQdzJCZAZB12nxyIuvKAKUNBrcNFgfbSfN6lMXxqxZBdF5carAwaQSZA2KJWZAzjAXoLBjbLJq9BkIWGa",
                                problems[index].userId,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // While data is loading, display a placeholder
                                  return const Text(
                                    'Loading...',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  // If there's an error, display an error message
                                  return const Text(
                                    'Error loading business name',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  );
                                } else {
                                  // If data is successfully fetched, display the business name
                                  return Text(
                                    'Submitted by: ${snapshot.data}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
