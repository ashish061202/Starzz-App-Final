import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:googleapis/sheets/v4.dart' as sheets_api;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GoogleSheetsService {
  final sheets_api.SheetsApi _sheets;

  GoogleSheetsService._(this._sheets);

  static Future<GoogleSheetsService> create(
      ServiceAccountCredentials credentials) async {
    final sheets = await sheets_api.SheetsApi(
      await clientViaServiceAccount(
        credentials,
        ["https://www.googleapis.com/auth/spreadsheets"],
      ),
    );
    return GoogleSheetsService._(sheets);
  }

  Future<List<List<Object?>>> getSheetData(
      String spreadsheetId, String range) async {
    final response =
        await _sheets.spreadsheets.values.get(spreadsheetId, range);
    return response.values ?? [];
  }
}

Future<Map<String, Map<String, double>>> fetchData() async {
  final googleSheetsService = await GoogleSheetsService.create(
    ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "steady-method-412112",
      "private_key_id": "69c3011f9fbf0567aab35e747aa624ef6e6fc380",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC2kwBm8U2EaYJA\n2F85e7hHMQUWM1JG5evF74W3IO+zHm7o5KzKP8HHSjmuu6XhYutxleebgaDuhPnD\n2wwhdtrSZJVlA6g7eJjXLrEldWEKMzTmqDQtOjNN9KRdh+I3Jpfdo7XGrjQtgOBe\nKlFFMJ23bGmS8DG3bX9sfvsm+6K8GNgPPtZQ0ECyHws7rNg7/m421xJh8pxU1QWk\nfqwVZSjcC22O7FNxPOeqwa9gk4n/WBE/SzvxjNr5/ME033lC5nptJnrtwDoVYGBu\nAVfRPmneaw6vCVyi/pRTZoiag/Goo0n+cqzLMrMp+BS3JXYQM3E8o/W2NLtJ5k4a\n1sR+Z+UjAgMBAAECggEAAM8avvOhLRqg+4b563GwGcCoQRzt55qFNojrksNc/779\nLTlpYP8/U8UkbeQu+MmAOZSfqufvV2wHbBkmyJv6N3LZDQWJhua8TQr/H43EzE+S\nk6MTK1AitUNSpyEL0F3ynLmcLv3+nstlzLg4FZJnLU5+eUQ1mpZ40t/Z+D/Z//Nd\ngZVa9/+A//KDTGximcYtBqCltrWaRvRSMzfbRlS6iZ8Y3Zc8TBiSBXGxWjgIKfwd\ncfBoW+8fprvGl6lLlUG4K0W7JT81yyGTE44hv3NMlSy/hCW0In0lYP+mXYvYSATu\nL0sci+dyZ9eWuFMAHndFtLn9cVp+U97AyGb1b0YMwQKBgQDu8ncasDJLNTZ+te22\nJNHsWWUaS+BfzNM6WeaDQ6JC6q+Ycsy36IvkjzJ6+om+5oH2LqPQM1zDzfOUJH1O\njlsTBGz46DFBQjN6l6yCUkuZfs9n4pJBa8oYysz8sx8FZkpSPv2NB+SA4NbHqFOK\nRmtSeoOP5H8qEtUVKoyGuqJgiwKBgQDDmpw6FOqnsNHw5e/zDVI8v8LFK9S3dMp5\nL2SYbwaKTmtFV0YkO8Lkasw14w4KM2OntilGEHN0CUd6bkdULhts4cKpAV2/DCa4\naV2O/Pe4rtTfIiI6yA84wu68N0DBXBQHENPEProtRUGZTMY/H6bSmBScs3C8RDgj\n0jFZaqlIyQKBgH9qle6KVFdcadHJq5e8LKDOzqXmHiCXtW9hLxWCBE2QndA6L0ZG\nYAqh/XYskTVV76laF4pXSTk0YpX1m0g/ivsqGf3kuxckeRT/OkNIJP4V6/1miT0P\ngHYV9pct4PXdJPaUlloVAlljC8Tt0pZilKonoG4jl1fVMQEXblYNwbafAoGBAK5A\nevJnFdADflNbk9HzSRKjRhC+hkZUfddNeBEvvyTQzVE9eVfoASvZVEihGC3QL/QF\nHGm1WBTD+3A+874zQO1ThUVn2SrL2WapPtaV1t0oqqyIzPOOq7jGN0Vm94IJ1DGj\nNPP7aYHQ06qMsYMkYEn1f09Fr6WYJGcM5jehBGO5AoGBAOTGfcsPWaXn5KDWyLpV\nSK2TjQJkyDkC1SlmGX81WC7fT74f0GndDHDrjuAcYQcm0J5XlY+loHPKD0dc5mPf\nt/L+hh4lESH79ZzUu45fPvTZDxPnYzxTTGivVwCxoEC7NYggtnaV3uxR6GTKogKc\nRefXPCQ+HvpZiqjt8aZkAKiI\n-----END PRIVATE KEY-----\n",
      "client_email": "sheet-965@steady-method-412112.iam.gserviceaccount.com",
      "client_id": "115173403809616435356",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/sheet-965%40steady-method-412112.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    }),
  );
  final sheetData = await googleSheetsService.getSheetData(
    '1AYjukkMf_OrPYxI-N79J27oGP8-Fn6hrx3709oJvOnA',
    'Sheet1!A1:D4',
  );

  final dataMap = Map<String, Map<String, double>>();

  for (var row in sheetData) {
    final user = row[0].toString();
    final productivity = double.tryParse(row[1].toString()) ?? 0.0;
    final expense = double.tryParse(row[2].toString()) ?? 0.0;
    final revenue = double.tryParse(row[3].toString()) ?? 0.0;

    dataMap[user] = {
      'Productivity': productivity,
      'Expense': expense,
      'Revenue': revenue,
    };
  }

  return dataMap;
}

//Me Try3
class DashboardScreen extends StatelessWidget {
  final LinkedScrollControllerGroup _controllerGroup =
      LinkedScrollControllerGroup();
  DashboardScreen({super.key});

  List<PieChartSectionData> _generatePieSections(
      Map<String, Map<String, double>> dataMap) {
    List<PieChartSectionData> sections = [];

    dataMap.forEach((user, analytics) {
      final color = Color.fromARGB(
        255,
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
      );

      final total = analytics.values.reduce((sum, value) => sum + value);
      final totalPercentage = (total / 300.0) * 100.0;

      sections.add(
        PieChartSectionData(
          color: color,
          value: totalPercentage,
          title:
              '$user\n${totalPercentage.toStringAsFixed(2)}%', // Add user name and total percentage
          radius: 100.0,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xffffffff),
          ),
        ),
      );
    });

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    WABAIDController wabaidController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Dashboard",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent, // Make app bar transparent
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 255, 183, 138),
                Color.fromARGB(255, 255, 111, 145)
              ],
            ),
          ),
        ), // Make app bar transparent
      ),
      body: SafeArea(
        child:
            // Stack(
            //   children: [
            //     Positioned(
            //       child: Padding(
            //         padding: const EdgeInsets.all(14.0),
            //         child: Container(
            //           padding:
            //               const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            //           decoration: BoxDecoration(
            //             color: Colors.white,
            //             borderRadius: BorderRadius.circular(15),
            //             boxShadow: [
            //               BoxShadow(
            //                 color: Colors.grey.withOpacity(0.3),
            //                 spreadRadius: 2,
            //                 blurRadius: 5,
            //                 offset: const Offset(0, 2),
            //               ),
            //             ],
            //           ),
            //           child: ListView(
            //             children: [
            //               Row(
            //                 children: [
            //                   Row(
            //                     children: [
            //                       CircleAvatar(
            //                         radius: 50,
            //                         backgroundColor:
            //                             const Color.fromARGB(255, 202, 181, 240),
            //                         child: CircleAvatar(
            //                           radius: 48,
            //                           child: SvgPicture.asset(
            //                             "assets/person.svg",
            //                             fit: BoxFit.contain,
            //                             color:
            //                                 const Color.fromARGB(255, 37, 30, 30),
            //                             height: 44,
            //                             width: 44,
            //                           ),
            //                         ),
            //                       ),
            //                       const SizedBox(
            //                         width: 15,
            //                       ),
            //                       Row(
            //                         crossAxisAlignment: CrossAxisAlignment.start,
            //                         children: [
            //                           FutureBuilder<String>(
            //                             future: Future.value(
            //                                 wabaidController.enteredWABAID),
            //                             builder: (context, snapshot) {
            //                               if (snapshot.connectionState ==
            //                                   ConnectionState.waiting) {
            //                                 return const CircularProgressIndicator();
            //                               } else if (snapshot.hasError) {
            //                                 return Text(
            //                                   'Error loading WABAID: ${snapshot.error}',
            //                                   style: const TextStyle(
            //                                       color: Colors.red),
            //                                 );
            //                               } else if (snapshot.hasData) {
            //                                 final enteredWABAID = snapshot.data!;
            //                                 return Padding(
            //                                   padding:
            //                                       const EdgeInsets.only(top: 8.0),
            //                                   child: Text(
            //                                     "ID: $enteredWABAID",
            //                                     style: const TextStyle(
            //                                       fontWeight: FontWeight.bold,
            //                                       fontSize: 18,
            //                                       color: Colors.black,
            //                                     ),
            //                                   ),
            //                                 );
            //                               } else {
            //                                 return const Text(
            //                                   'No WABAID found',
            //                                   style: TextStyle(color: Colors.grey),
            //                                 );
            //                               }
            //                             },
            //                           ),
            //                         ],
            //                       ),
            //                     ],
            //                   ),
            //                 ],
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //     Positioned(
            //       top: 160,
            //       left: 0,
            //       right: 0,
            //       bottom: 0,
            //       child: Container(
            //         decoration: BoxDecoration(
            //           gradient: const LinearGradient(
            //             begin: Alignment.topLeft,
            //             end: Alignment.bottomRight,
            //             colors: [
            //               Color.fromARGB(255, 255, 183, 138),
            //               Color.fromARGB(255, 255, 111, 145),
            //             ],
            //           ),
            //           borderRadius: const BorderRadius.only(
            //             topLeft: Radius.circular(40),
            //             topRight: Radius.circular(40),
            //           ),
            //           boxShadow: [
            //             BoxShadow(
            //               color: Colors.black.withOpacity(0.3),
            //               spreadRadius: 5,
            //               blurRadius: 10,
            //               offset: const Offset(0, 3),
            //             ),
            //           ],
            //         ),
            //         child: Column(
            //           children: [
            //             const SizedBox(height: 20),
            //             Center(
            //               child: Text(
            //                 "Our Services",
            //                 style: GoogleFonts.openSans(
            //                     textStyle: const TextStyle(
            //                         color: Colors.white,
            //                         fontSize: 24,
            //                         fontWeight: FontWeight.w600)),
            //               ),
            //             ),
            //             const SizedBox(height: 20),
            //             // Horizontally scrollable services
            //             // SizedBox(
            //             //   height: 150,
            //             //   child: ListView.builder(
            //             //     scrollDirection: Axis.horizontal,
            //             //     controller: _controllerGroup.addAndGet(),
            //             //     itemCount: 5, // Displaying the first 5 services
            //             //     itemBuilder: (context, index) {
            //             //       return Padding(
            //             //         padding: const EdgeInsets.all(8.0),
            //             //         child: ServiceCard(
            //             //           service: services[index],
            //             //         ),
            //             //       );
            //             //     },
            //             //   ),
            //             // ),
            //             // // Second row of horizontally scrollable services
            //             // SizedBox(
            //             //   height: 150,
            //             //   child: ListView.builder(
            //             //     scrollDirection: Axis.horizontal,
            //             //     controller: _controllerGroup.addAndGet(),
            //             //     itemCount: 4, // Displaying the remaining 4 services
            //             //     itemBuilder: (context, index) {
            //             //       return Padding(
            //             //         padding: const EdgeInsets.all(8.0),
            //             //         child: ServiceCard(
            //             //           service: services[index + 5],
            //             //         ),
            //             //       );
            //             //     },
            //             //   ),
            //             // ),
            //             Positioned(
            //               top: 300,
            //               left: 16,
            //               right: 16,
            //               bottom: 16,
            //               child:
            FutureBuilder<Map<String, Map<String, double>>>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error loading data: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final dataMap = snapshot.data!;

              // Process sheetData and create a Pie Chart
              return PieChart(
                PieChartData(
                  sectionsSpace: 5.0,
                  centerSpaceRadius: 40.0,
                  sections: _generatePieSections(dataMap),
                  // Customize other properties as needed
                ),
              );
            } else {
              return const Text('No data found');
            }
          },
        ),
      ),
      //],
    );
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}