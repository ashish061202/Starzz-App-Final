import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starz/models/phone_number_model.dart';

//import '../models/chat_model.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({Key? key, required this.contact}) : super(key: key);
  final Datum contact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: SingleChildScrollView(
        child: ListTile(
            leading: CircleAvatar(
              radius: 23,
              backgroundColor: Colors.grey,
              child: SvgPicture.asset(
                "assets/person.svg",
                color: Colors.white,
                width: 30,
                height: 30,
              ),
            ),
            title: Text(
              contact.verified_name, // Use ! to assert that contact is not null
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
                contact
                    .display_phone_number, // Use ! to assert that contact is not null
                style: const TextStyle(
                  fontSize: 13,
                ))
            // title: Text(contact.verified_name,
            //     style:
            //         const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            // subtitle: Text(contact.display_phone_number,
            //     style: const TextStyle(
            //       fontSize: 13,
            //     )),
            ),
      ),
    );
  }
}
