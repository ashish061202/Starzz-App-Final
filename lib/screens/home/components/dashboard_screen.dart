import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:starz/screens/auth/wabaid_controller.dart';

//He
/*class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
          const SizedBox(
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
                      const SizedBox(
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
                  padding: const EdgeInsets.only(top: 45, left: 10, right: 10),
                  child: GridView(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 28),
                    children: [
                      Card(
                        shadowColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 6,
                        child: GridTile(
                          header: Container(
                            color: Colors.blue,
                            child: const Center(
                                child: Text(
                              "Todays Order",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          footer: Container(
                              color: const Color.fromARGB(255, 15, 76, 126),
                              child: const Center(
                                  child: Text("6",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)))),
                          child: const Icon(Icons.shopping_basket_outlined),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        shadowColor: Colors.blue,
                        elevation: 6,
                        child: GridTile(
                          header: Container(
                            color: Colors.blue,
                            child: const Center(
                                child: Text("Todays Profite",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ),
                          footer: Container(
                            color: const Color.fromARGB(255, 18, 83, 137),
                            child: const Center(
                                child: Text("15,000",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ),
                          child: const Icon(Icons.shopping_basket_outlined),
                        ),
                      ),
                      Card(
                        color: Colors.white.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        shadowColor: Colors.purple,
                        elevation: 6,
                        child: GridTile(
                          header: Container(
                            decoration: const BoxDecoration(),
                            //color: const Color.fromARGB(255, 19, 85, 138),
                            child: const Center(
                                child: Text("Total Order Completed",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ),
                          footer: Container(
                            color: Colors.purple,
                            child: const Center(
                                child: Text("75",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ),
                          child:
                              // Padding(
                              //   padding: const EdgeInsets.all(30.0),
                              //   child: CircularProgressIndicator(
                              //     value: 0.8, // Sets the progress value (0.0 to 1.0)
                              //     strokeWidth: 15.0, // Sets the width of the indicator
                              //     backgroundColor: Colors.grey, // Sets the background color
                              //     valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Sets the color of the indicator
                              //   ),
                              // ),

                          const Icon(Icons.shopping_basket_outlined),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        shadowColor: Colors.purple,
                        elevation: 6,
                        child: GridTile(
                          header: Container(
                            color: const Color.fromARGB(255, 15, 70, 114),
                            child: const Center(
                                child: Text("Total Profite",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ),
                          footer: Container(
                            color: Colors.purple,
                            child: const Center(
                                child: Text("1,00,000",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ),
                          child: const Icon(Icons.shopping_basket_outlined),
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ],
      )),
    );
  }
}*/

//Me Try1
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WABAIDController wabaidController = Get.find();
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
            const SizedBox(
              height: 20,
            ),
            Positioned(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: ListView(
                  children: [
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
                            const SizedBox(
                              width: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      "NAME:  .............",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Replace WABAID text with entered WABAID
                                    FutureBuilder<String>(
                                      future: Future.value(
                                          wabaidController.enteredWABAID),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error loading WABAID: ${snapshot.error}');
                                        } else if (snapshot.hasData) {
                                          final enteredWABAID = snapshot.data!;
                                          return Text(
                                            "ID:$enteredWABAID",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        } else {
                                          return const Text('No WABAID found');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
