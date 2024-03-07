import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ContactDetailsScreen extends StatelessWidget {
  final String phoneNumber;
  final String userName;

  const ContactDetailsScreen({
    super.key,
    required this.phoneNumber,
    required this.userName,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: phoneNumber));

    Fluttertoast.showToast(
      msg: 'Phone number copied',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'profileIcon',
              child: const CircleAvatar(
                radius: 70,
                backgroundColor: Colors.blueGrey,
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              flightShuttleBuilder: (
                BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,
              ) {
                return RotationTransition(
                  turns: animation,
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blueGrey,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              thickness: 2,
            ),
            const SizedBox(height: 15),
            ListTile(
              title: const Text(
                'Name',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              subtitle: Text(
                userName,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),
            ListTile(
              title: const Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              subtitle: GestureDetector(
                onLongPress: () => _copyToClipboard(context),
                child: Text(
                  phoneNumber,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            // Add more contact details as needed
          ],
        ),
      ),
    );
  }
}
