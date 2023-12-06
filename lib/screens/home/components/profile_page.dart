import 'package:flutter/material.dart';
//import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:starz/screens/auth/login/login_page.dart';
import 'package:starz/screens/privacy&policy/privacy_and_policy.dart';

//He
class ProfileScreen extends StatelessWidget {
  static const id = "/profile_page";

  const ProfileScreen({super.key});
  //MediaQueryData mediaQueryData = MediaQuery.of(context);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Account",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26),
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
          child: Stack(
        children: [
          SizedBox(
            height: 20,
          ),
          Positioned(
              child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: ListView(children: [
              Row(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            const Color.fromARGB(255, 202, 181, 240),
                        child: CircleAvatar(
                          radius: 48,
                          child: SvgPicture.asset(
                            "assets/person.svg",
                            fit: BoxFit.contain,
                            color: const Color.fromARGB(255, 37, 30, 30),
                            height: 54,
                            width: 54,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "NAME:  .............",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                " WABAID:  .............",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ]),
          )),
          Positioned(
            top: 160,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Color.fromARGB(255, 61, 163, 247),
                          Color.fromARGB(255, 21, 94, 153),
                          Colors.purple
                        ]),
                    //color: Colors.deepPurple,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40))),
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: ListView(children:
                          // ListTile.divideTiles
                          // (context: context, tiles:
                          [
                    const ListTile(
                      leading: Icon(
                        Icons.shopping_cart,
                      ),
                      title: Text(
                        "My Orders",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const ListTile(
                      leading: Icon(Icons.notifications_active_rounded),
                      title: Text(
                        "Notifications",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const ListTile(
                      leading: Icon(Icons.settings),
                      title: Text(
                        "Settings",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ListTile(
                      onTap: () {
                        Get.toNamed(PrivacyAndPolicyPage.id);
                      },
                      leading: const Icon(
                        (Icons.info_outline),
                      ),
                      title: const Text(
                        "About us",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ListTile(
                      onTap: () {
                        Get.toNamed(LoginPage.id);
                      },
                      leading: const Icon(Icons.logout_outlined),
                      title: const Text(
                        "logout",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    )
                  ]
                      //).toList(),
                      ),
                )),
          ),
        ],
      )),
    );
  }
}

//Me
// class ProfileScreen extends StatefulWidget {
//   static const id = "/profile_page";
//   final String enteredWABAID;

//   const ProfileScreen({super.key, required this.enteredWABAID});

//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Center(
//           child: Text(
//             "Account",
//             style: TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: 26,
//             ),
//           ),
//         ),
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             const SizedBox(
//               height: 20,
//             ),
//             Positioned(
//               child: Padding(
//                 padding: const EdgeInsets.all(14.0),
//                 child: ListView(
//                   children: [
//                     Row(
//                       children: [
//                         Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 50,
//                               backgroundColor:
//                                   const Color.fromARGB(255, 202, 181, 240),
//                               child: CircleAvatar(
//                                 radius: 48,
//                                 child: SvgPicture.asset(
//                                   "assets/person.svg",
//                                   fit: BoxFit.contain,
//                                   color: const Color.fromARGB(255, 37, 30, 30),
//                                   height: 54,
//                                   width: 54,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 5,
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 Column(
//                                   children: [
//                                     const Text(
//                                       "NAME:  .............",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       " WABAID: ${widget.enteredWABAID}",
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 160,
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Colors.white,
//                         Color.fromARGB(255, 61, 163, 247),
//                         Color.fromARGB(255, 21, 94, 153),
//                         Colors.purple,
//                       ],
//                     ),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(40),
//                       topRight: Radius.circular(40),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 32),
//                     child: ListView(children: [
//                       const ListTile(
//                         leading: Icon(
//                           Icons.shopping_cart,
//                         ),
//                         title: Text(
//                           "My Orders",
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       const ListTile(
//                         leading: Icon(Icons.notifications_active_rounded),
//                         title: Text(
//                           "Notifications",
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       const ListTile(
//                         leading: Icon(Icons.settings),
//                         title: Text(
//                           "Settings",
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       ListTile(
//                         onTap: () {
//                           Get.toNamed(PrivacyAndPolicyPage.id);
//                         },
//                         leading: const Icon(
//                           (Icons.info_outline),
//                         ),
//                         title: const Text(
//                           "About us",
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       ListTile(
//                         onTap: () {
//                           Get.toNamed(LoginPage.id);
//                         },
//                         leading: const Icon(Icons.logout_outlined),
//                         title: const Text(
//                           "logout",
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                       )
//                     ]
//                         //).toList(),
//                         ),
//                   )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
