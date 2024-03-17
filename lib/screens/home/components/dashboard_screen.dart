import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets_api;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

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

// //Function to fetch data from google sheet
// Future<Map<String, Map<String, double>>> fetchData(String spreadsheetId, String selectedDate) async {
//   final googleSheetsService = await GoogleSheetsService.create(
//     ServiceAccountCredentials.fromJson({
//       "type": "service_account",
//       "project_id": "steady-method-412112",
//       "private_key_id": "69c3011f9fbf0567aab35e747aa624ef6e6fc380",
//       "private_key":
//           "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC2kwBm8U2EaYJA\n2F85e7hHMQUWM1JG5evF74W3IO+zHm7o5KzKP8HHSjmuu6XhYutxleebgaDuhPnD\n2wwhdtrSZJVlA6g7eJjXLrEldWEKMzTmqDQtOjNN9KRdh+I3Jpfdo7XGrjQtgOBe\nKlFFMJ23bGmS8DG3bX9sfvsm+6K8GNgPPtZQ0ECyHws7rNg7/m421xJh8pxU1QWk\nfqwVZSjcC22O7FNxPOeqwa9gk4n/WBE/SzvxjNr5/ME033lC5nptJnrtwDoVYGBu\nAVfRPmneaw6vCVyi/pRTZoiag/Goo0n+cqzLMrMp+BS3JXYQM3E8o/W2NLtJ5k4a\n1sR+Z+UjAgMBAAECggEAAM8avvOhLRqg+4b563GwGcCoQRzt55qFNojrksNc/779\nLTlpYP8/U8UkbeQu+MmAOZSfqufvV2wHbBkmyJv6N3LZDQWJhua8TQr/H43EzE+S\nk6MTK1AitUNSpyEL0F3ynLmcLv3+nstlzLg4FZJnLU5+eUQ1mpZ40t/Z+D/Z//Nd\ngZVa9/+A//KDTGximcYtBqCltrWaRvRSMzfbRlS6iZ8Y3Zc8TBiSBXGxWjgIKfwd\ncfBoW+8fprvGl6lLlUG4K0W7JT81yyGTE44hv3NMlSy/hCW0In0lYP+mXYvYSATu\nL0sci+dyZ9eWuFMAHndFtLn9cVp+U97AyGb1b0YMwQKBgQDu8ncasDJLNTZ+te22\nJNHsWWUaS+BfzNM6WeaDQ6JC6q+Ycsy36IvkjzJ6+om+5oH2LqPQM1zDzfOUJH1O\njlsTBGz46DFBQjN6l6yCUkuZfs9n4pJBa8oYysz8sx8FZkpSPv2NB+SA4NbHqFOK\nRmtSeoOP5H8qEtUVKoyGuqJgiwKBgQDDmpw6FOqnsNHw5e/zDVI8v8LFK9S3dMp5\nL2SYbwaKTmtFV0YkO8Lkasw14w4KM2OntilGEHN0CUd6bkdULhts4cKpAV2/DCa4\naV2O/Pe4rtTfIiI6yA84wu68N0DBXBQHENPEProtRUGZTMY/H6bSmBScs3C8RDgj\n0jFZaqlIyQKBgH9qle6KVFdcadHJq5e8LKDOzqXmHiCXtW9hLxWCBE2QndA6L0ZG\nYAqh/XYskTVV76laF4pXSTk0YpX1m0g/ivsqGf3kuxckeRT/OkNIJP4V6/1miT0P\ngHYV9pct4PXdJPaUlloVAlljC8Tt0pZilKonoG4jl1fVMQEXblYNwbafAoGBAK5A\nevJnFdADflNbk9HzSRKjRhC+hkZUfddNeBEvvyTQzVE9eVfoASvZVEihGC3QL/QF\nHGm1WBTD+3A+874zQO1ThUVn2SrL2WapPtaV1t0oqqyIzPOOq7jGN0Vm94IJ1DGj\nNPP7aYHQ06qMsYMkYEn1f09Fr6WYJGcM5jehBGO5AoGBAOTGfcsPWaXn5KDWyLpV\nSK2TjQJkyDkC1SlmGX81WC7fT74f0GndDHDrjuAcYQcm0J5XlY+loHPKD0dc5mPf\nt/L+hh4lESH79ZzUu45fPvTZDxPnYzxTTGivVwCxoEC7NYggtnaV3uxR6GTKogKc\nRefXPCQ+HvpZiqjt8aZkAKiI\n-----END PRIVATE KEY-----\n",
//       "client_email": "sheet-965@steady-method-412112.iam.gserviceaccount.com",
//       "client_id": "115173403809616435356",
//       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//       "token_uri": "https://oauth2.googleapis.com/token",
//       "auth_provider_x509_cert_url":
//           "https://www.googleapis.com/oauth2/v1/certs",
//       "client_x509_cert_url":
//           "https://www.googleapis.com/robot/v1/metadata/x509/sheet-965%40steady-method-412112.iam.gserviceaccount.com",
//       "universe_domain": "googleapis.com"
//     }),
//   );

//   final response =
//       await googleSheetsService.getSheetData(spreadsheetId, 'Sheet1!A1:Z1');

//   if (response.isEmpty) {
//     // Handle the case where there are no headers
//     return {};
//   }

//   // Extract column names from the first row
//   final columnNames = response.first.map((value) => value.toString()).toList();

//   final sheetData = await googleSheetsService.getSheetData(
//     spreadsheetId,
//     'Sheet1!A1:Z100',
//   );

//   final dataMap = Map<String, Map<String, double>>();
//   print('Fetched data: $dataMap');

//   for (var row in sheetData) {
//     final user = row[1].toString();
//     final date = row[0].toString();
//     // Filter data based on both user and date
//     if ((selectedUser.isEmpty || user == selectedUser) &&
//         (selectedDate.isEmpty || date == selectedDate)) {
//       final userData = <String, double>{};

//     for (var i = 2; i < row.length; i++) {
//       final columnName = columnNames[i];
//       final value = double.tryParse(row[i].toString()) ?? 0;
//       userData[columnName] = value;
//     }

//     dataMap[user] = userData;
//   }
//   }
//   return dataMap;
// }

class UserData {
  final String category;
  final double value;
  final Color color;

  UserData(this.category, this.value, this.color);
}

FunnelSeries<dynamic, dynamic> convertDataToSeries(
    Map<String, double> userData) {
  final colorList = <Color>[
    Colors.red, // You can customize the colors as needed
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  // Explicitly specify the order of categories
  final categoryOrder = ['booking', 'meeting', 'quotation', 'closure'];

  final dataList = categoryOrder
      .where((category) => userData.containsKey(category))
      .map((category) {
    final index = categoryOrder.indexOf(category);
    return UserData(category, userData[category]!, colorList[index]);
  }).toList();

  // Sorting the dataList in descending order based on values
  //dataList.sort((a, b) => b.value.compareTo(a.value));

  return FunnelSeries<UserData, String>(
    dataSource: dataList,
    xValueMapper: (UserData data, _) => data.category,
    yValueMapper: (UserData data, _) => data.value,
    pointColorMapper: (UserData data, _) => data.color,
    neckWidth: '50%',
    width: '90%',
    neckHeight: '0%',
    // Show data labels on the inside of the funnel chart
    dataLabelSettings: const DataLabelSettings(
      isVisible: true,
      labelPosition: ChartDataLabelPosition.inside,
    ),
  );
}

class FunnelChart extends StatelessWidget {
  final FunnelSeries<dynamic, dynamic> series;

  FunnelChart(this.series);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      child: SfFunnelChart(
        series: series,
        legend: const Legend(
            isVisible: true,
            orientation: LegendItemOrientation.vertical,
            position: LegendPosition.right,
            textStyle: TextStyle(color: Colors.white)),
      ),
    );
  }
}

//Me Try3
class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  static const id = "/dashboard";

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _serviceCardsController = ScrollController();
  TextEditingController spreadsheetIdController = TextEditingController();
  bool showInputCard = true;
  bool showFunnelChart = false;
  List<String> userList = [];
  List<String> dateList = [];
  String selectedUser = '';
  String selectedDate = '';
  String selectedTimestamp = '';
  List<String> savedSpreadsheetIds = [];

  @override
  void initState() {
    super.initState();
    loadSavedSpreadsheetId();
  }

  // Method to load previously saved spreadsheet ID
  Future<void> loadSavedSpreadsheetId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedSpreadsheetIds = prefs.getStringList('saved_spreadsheet_ids') ?? [];
    });
    // print('Saved ID: $storedSpreadsheetId');
  }

  // Method to save entered spreadsheet ID
  Future<void> saveSpreadsheetId(String spreadsheetId) async {
    final prefs = await SharedPreferences.getInstance();
    // Save the entered spreadsheet ID
    prefs.setString('spreadsheet_id', spreadsheetId);

    // Save the spreadsheet ID in the list of saved IDs
    if (!savedSpreadsheetIds.contains(spreadsheetId)) {
      savedSpreadsheetIds.add(spreadsheetId);
      prefs.setStringList('saved_spreadsheet_ids', savedSpreadsheetIds);
    }
  }

  //Function to fetch data from google sheet
  Future<Map<String, Map<String, double>>> fetchData(
      String spreadsheetId, String selectedDate) async {
    final googleSheetsService = await GoogleSheetsService.create(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "steady-method-412112",
        "private_key_id": "69c3011f9fbf0567aab35e747aa624ef6e6fc380",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC2kwBm8U2EaYJA\n2F85e7hHMQUWM1JG5evF74W3IO+zHm7o5KzKP8HHSjmuu6XhYutxleebgaDuhPnD\n2wwhdtrSZJVlA6g7eJjXLrEldWEKMzTmqDQtOjNN9KRdh+I3Jpfdo7XGrjQtgOBe\nKlFFMJ23bGmS8DG3bX9sfvsm+6K8GNgPPtZQ0ECyHws7rNg7/m421xJh8pxU1QWk\nfqwVZSjcC22O7FNxPOeqwa9gk4n/WBE/SzvxjNr5/ME033lC5nptJnrtwDoVYGBu\nAVfRPmneaw6vCVyi/pRTZoiag/Goo0n+cqzLMrMp+BS3JXYQM3E8o/W2NLtJ5k4a\n1sR+Z+UjAgMBAAECggEAAM8avvOhLRqg+4b563GwGcCoQRzt55qFNojrksNc/779\nLTlpYP8/U8UkbeQu+MmAOZSfqufvV2wHbBkmyJv6N3LZDQWJhua8TQr/H43EzE+S\nk6MTK1AitUNSpyEL0F3ynLmcLv3+nstlzLg4FZJnLU5+eUQ1mpZ40t/Z+D/Z//Nd\ngZVa9/+A//KDTGximcYtBqCltrWaRvRSMzfbRlS6iZ8Y3Zc8TBiSBXGxWjgIKfwd\ncfBoW+8fprvGl6lLlUG4K0W7JT81yyGTE44hv3NMlSy/hCW0In0lYP+mXYvYSATu\nL0sci+dyZ9eWuFMAHndFtLn9cVp+U97AyGb1b0YMwQKBgQDu8ncasDJLNTZ+te22\nJNHsWWUaS+BfzNM6WeaDQ6JC6q+Ycsy36IvkjzJ6+om+5oH2LqPQM1zDzfOUJH1O\njlsTBGz46DFBQjN6l6yCUkuZfs9n4pJBa8oYysz8sx8FZkpSPv2NB+SA4NbHqFOK\nRmtSeoOP5H8qEtUVKoyGuqJgiwKBgQDDmpw6FOqnsNHw5e/zDVI8v8LFK9S3dMp5\nL2SYbwaKTmtFV0YkO8Lkasw14w4KM2OntilGEHN0CUd6bkdULhts4cKpAV2/DCa4\naV2O/Pe4rtTfIiI6yA84wu68N0DBXBQHENPEProtRUGZTMY/H6bSmBScs3C8RDgj\n0jFZaqlIyQKBgH9qle6KVFdcadHJq5e8LKDOzqXmHiCXtW9hLxWCBE2QndA6L0ZG\nYAqh/XYskTVV76laF4pXSTk0YpX1m0g/ivsqGf3kuxckeRT/OkNIJP4V6/1miT0P\ngHYV9pct4PXdJPaUlloVAlljC8Tt0pZilKonoG4jl1fVMQEXblYNwbafAoGBAK5A\nevJnFdADflNbk9HzSRKjRhC+hkZUfddNeBEvvyTQzVE9eVfoASvZVEihGC3QL/QF\nHGm1WBTD+3A+874zQO1ThUVn2SrL2WapPtaV1t0oqqyIzPOOq7jGN0Vm94IJ1DGj\nNPP7aYHQ06qMsYMkYEn1f09Fr6WYJGcM5jehBGO5AoGBAOTGfcsPWaXn5KDWyLpV\nSK2TjQJkyDkC1SlmGX81WC7fT74f0GndDHDrjuAcYQcm0J5XlY+loHPKD0dc5mPf\nt/L+hh4lESH79ZzUu45fPvTZDxPnYzxTTGivVwCxoEC7NYggtnaV3uxR6GTKogKc\nRefXPCQ+HvpZiqjt8aZkAKiI\n-----END PRIVATE KEY-----\n",
        "client_email":
            "sheet-965@steady-method-412112.iam.gserviceaccount.com",
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

    final response =
        await googleSheetsService.getSheetData(spreadsheetId, 'Sheet1!A1:Z1');

    if (response.isEmpty) {
      // Handle the case where there are no headers
      return {};
    }

    // Extract column names from the first row
    final columnNames =
        response.first.map((value) => value.toString()).toList();

    final sheetData = await googleSheetsService.getSheetData(
      spreadsheetId,
      'Sheet1!A1:Z100',
    );

    dateList = sheetData.map((row) => row[0].toString()).toSet().toList();

    final dataMap = Map<String, Map<String, double>>();
    print('Fetched data: $dataMap');

    for (var row in sheetData) {
      final user = row[1].toString();
      final date = row[0].toString();
      // Filter data based on both user and date
      if ((selectedUser.isEmpty || user == selectedUser) &&
          (selectedDate.isEmpty || date == selectedDate)) {
        final userData = <String, double>{};

        for (var i = 2; i < row.length; i++) {
          final columnName = columnNames[i];
          final value = double.tryParse(row[i].toString()) ?? 0;
          userData[columnName] = value;
        }

        dataMap[user] = userData;
      }
    }
    return dataMap;
  }

  // Function to load the dates based on the entered spreadsheet ID
  Future<void> loadDates(String spreadsheetId) async {
    final data = await fetchData(spreadsheetId, '');
    setState(() {
      dateList =
          data.values.expand((userData) => userData.keys).toSet().toList();
    });
  }

  Widget _buildInputCard() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 1, // Set thicker border width
            ),
            borderRadius: BorderRadius.circular(8.0), // Set border radius
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    controller: spreadsheetIdController,
                    style: const TextStyle(
                      color: Colors.white,
                    ), // Set text color to white
                    decoration: const InputDecoration(
                      labelText: 'Enter Spreadsheet ID',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ), // Set label color to white
                      border: InputBorder.none, // Remove the default border
                    ),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                onSelected: (String selectedId) {
                  setState(() {
                    spreadsheetIdController.text = selectedId;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return savedSpreadsheetIds.map((String id) {
                    return PopupMenuItem<String>(
                      value: id,
                      child: Text(id,
                          style: TextStyle(
                              color: Get.isDarkMode
                                  ? Colors.white
                                  : Colors.black)),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              showFunnelChart = true;
              // Reset selectedUser when generating a new funnel chart
              selectedUser = '';
              selectedDate = '';
            });
            // Save the entered spreadsheet ID
            await saveSpreadsheetId(spreadsheetIdController.text);

            // Fetch data immediately after entering the spreadsheet ID
            final data = await fetchData(
              spreadsheetIdController.text,
              selectedDate,
            );

            // Populate the userList with the keys from the dataMap
            setState(() {
              userList = data.keys.toList();
            });

            // Load dates based on the entered spreadsheet ID
            await loadDates(spreadsheetIdController.text);
          },
          child: const Text('Show Analytics'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          ),
        ),
        elevation: 0,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF0D1F23)
            : Colors.transparent, // Make app bar transparent
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Get.isDarkMode
                  ? [
                      const Color.fromARGB(1, 39, 52, 67),
                      const Color.fromARGB(1, 39, 52, 67),
                    ]
                  : [
                      const Color.fromARGB(255, 255, 183, 138),
                      const Color.fromARGB(255, 255, 111, 145)
                    ],
            ),
          ),
        ), // Make app bar transparent
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                controller: _serviceCardsController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.baloo2(
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Our Services',
                              style: TextStyle(
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Color.fromARGB(255, 61, 163, 247),
                                      Color.fromARGB(255, 21, 94, 153),
                                      Colors.purple
                                    ],
                                  ).createShader(
                                    const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                                  ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Horizontally scrollable services
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: _serviceCardsController,
                        itemCount: 5, // Displaying the first 5 services
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ServiceCard(
                              service: services[index],
                            ),
                          );
                        },
                      ),
                    ),
                    // Second row of horizontally scrollable services
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: _serviceCardsController,
                        itemCount: 4, // Displaying the remaining 4 services
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ServiceCard(
                              service: services[index + 5],
                            ),
                          );
                        },
                      ),
                    ),
                    Card(
                      color: Get.isDarkMode
                          ? Colors.grey.shade900
                          : const Color(0xff453658),
                      elevation: 5,
                      margin: const EdgeInsets.all(10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildInputCard(),
                            if (showFunnelChart)
                              // FunnelChart and Dropdown with their scroll controllers
                              FutureBuilder<Map<String, Map<String, double>>>(
                                future: fetchData(
                                    spreadsheetIdController.text, selectedDate),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    var color = 0xff453658;
                                    // Show loading indicator if data is still loading
                                    return Card(
                                      color: Get.isDarkMode
                                          ? Colors.grey.shade900
                                          : Color(color),
                                      elevation: 5,
                                      margin: const EdgeInsets.all(10),
                                      child: Container(
                                        height: 400.0, // Adjust as needed
                                        padding: const EdgeInsets.all(10),
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 20),
                                              Text('Loading data...'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    var color = 0xff453658;
                                    print(
                                        'Error loading data: ${snapshot.error}');
                                    // Show error message if there's an error
                                    return Card(
                                      color: Get.isDarkMode
                                          ? Colors.grey.shade900
                                          : Color(color),
                                      elevation: 5,
                                      margin: const EdgeInsets.all(10),
                                      child: Container(
                                        height: 400.0, // Adjust as needed
                                        padding: const EdgeInsets.all(10),
                                        child: const Center(
                                          child: Text(
                                              'Please enter spreadsheet ID'),
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.hasData) {
                                    // Populate the userList with the keys from the dataMap
                                    userList = snapshot.data!.keys.toList();
                                    var color = 0xff453658;

                                    return Card(
                                      color: Get.isDarkMode
                                          ? Colors.grey.shade900
                                          : Color(color),
                                      elevation: 5,
                                      margin: const EdgeInsets.all(10),
                                      child: Container(
                                        height: 300.0, // Adjust as needed
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            if (selectedDate.isNotEmpty &&
                                                selectedUser.isNotEmpty)
                                              // FunnelChart with selected user data and date
                                              FunnelChart(
                                                convertDataToSeries(
                                                  snapshot.data![
                                                          selectedUser] ??
                                                      {},
                                                ),
                                              ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // DropdownButton for selecting the date
                                                DropdownButton<String>(
                                                  value: selectedDate,
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      selectedDate = newValue!;
                                                      selectedUser = '';
                                                    });
                                                  },
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.white),
                                                  dropdownColor:
                                                      Colors.grey.shade800,
                                                  elevation: 2,
                                                  underline: Container(
                                                    height: 2,
                                                    color: Colors.black,
                                                  ),
                                                  items: [
                                                    const DropdownMenuItem<
                                                        String>(
                                                      value: '',
                                                      child: Text(
                                                          'Select a date',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                    ...dateList.map<
                                                            DropdownMenuItem<
                                                                String>>(
                                                        (String value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(value,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                      );
                                                    }).toList(),
                                                  ],
                                                ),
                                                const SizedBox(width: 10),
                                                // DropdownButton code with updated userList
                                                DropdownButton<String>(
                                                  value: userList.contains(
                                                          selectedUser)
                                                      ? selectedUser
                                                      : '',
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      // Ensure newValue is in the userList or set it to an empty string
                                                      selectedUser =
                                                          userList.contains(
                                                                  newValue)
                                                              ? newValue!
                                                              : '';
                                                    });
                                                  },
                                                  style: const TextStyle(
                                                      color: Colors
                                                          .white), // Text color of the selected item
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors
                                                          .white), // Dropdown arrow color
                                                  dropdownColor: Colors.grey
                                                      .shade800, // Dropdown background color
                                                  elevation: 2,
                                                  underline: Container(
                                                    height:
                                                        2, // Height of the underline/border
                                                    color: Colors
                                                        .black, // Color of the underline/border
                                                  ),
                                                  items: [
                                                    const DropdownMenuItem<
                                                        String>(
                                                      value: '',
                                                      child: Text(
                                                          'Select a user',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                    ...userList.map<
                                                            DropdownMenuItem<
                                                                String>>(
                                                        (String value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(value,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                      );
                                                    }).toList(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Show a message if no data is found
                                    return Card(
                                      elevation: 5,
                                      margin: const EdgeInsets.all(10),
                                      child: Container(
                                        height: 400.0, // Adjust as needed
                                        padding: const EdgeInsets.all(10),
                                        child: const Center(
                                          child: Text('No data found'),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
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

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({
    super.key,
    required this.service,
  });

  void _showDescriptionPopup(BuildContext context) {
    final List<TextSpan> textSpans = [
      TextSpan(
        text: service.demoDescription,
        style: GoogleFonts.baloo2(
          textStyle: TextStyle(
            color: Get.isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    ];

    if (service.demoDescription.isNotEmpty) {
      textSpans.add(const TextSpan(text: ' ')); // Add space before the link

      textSpans.add(TextSpan(
        text: 'Know more',
        style: TextStyle(
          color: Get.isDarkMode ? Colors.blue : Colors.indigo,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launchUrl(Uri.parse(service.redirectUrl));
          },
      ));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
          backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: Get.isDarkMode ? Colors.blue : Colors.indigo,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  padding: const EdgeInsets.all(16),
                  child: Text.rich(
                    TextSpan(children: textSpans),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Get.isDarkMode ? Colors.blue : Colors.indigo,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var color = 0xff453658;
    bool isSmallScreen = MediaQuery.of(context).size.width < 350;
    return GestureDetector(
      onTap: () {
        _showDescriptionPopup(context);
      },
      child: Card(
        elevation: 6,
        child: Container(
          decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.grey.shade800 : Color(color),
              borderRadius: BorderRadius.circular(10)),
          width: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Image.asset(
                        service.logoAsset,
                        height: 24,
                        width: 24,
                      ),
                    ),
                    const TextSpan(text: " "), // Adjust spacing as needed
                    TextSpan(
                      text: service.name,
                      style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.demoDescription,
                maxLines: isSmallScreen ? 4 : 5,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              if (service.demoDescription.length > 6)
                GestureDetector(
                  onTap: () {
                    _showDescriptionPopup(context);
                  },
                  child: Text(
                    'Read more',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Service {
  final String name;
  final String demoDescription;
  final String logoAsset;
  final String redirectUrl;

  Service({
    required this.name,
    required this.demoDescription,
    required this.logoAsset,
    required this.redirectUrl,
  });
}

final List<Service> services = [
  Service(
    name: "Websites",
    demoDescription:
        "STARZ specializes in crafting professional and user-friendly websites tailored to meet the unique needs of your clients. Our team of skilled developers and designers work collaboratively to create visually appealing and functional websites that leave a lasting impression. Whether it's a simple informational site or a complex e-commerce platform, we ensure a seamless and engaging user experience.",
    logoAsset: "assets/web_dev.png",
    redirectUrl: "https://www.google.com",
  ),
  Service(
    name: "Hosting",
    demoDescription:
        "STARZ provides reliable and secure hosting solutions to ensure that your clients' websites are always up and running smoothly. Our hosting services guarantee high performance, robust security measures, and scalable options to accommodate the growth of their online presence.",
    logoAsset: 'assets/hosting.png',
    redirectUrl: "https://starzventures.in",
  ),
  Service(
    name: "E-commerce",
    demoDescription:
        "We excel in developing e-commerce solutions that empower businesses to thrive in the digital marketplace. Our e-commerce platforms are designed to enhance user experience, streamline transactions, and optimize online sales. From product listings to secure payment gateways, we cover all aspects of creating a successful online store.",
    logoAsset: 'assets/ecommerce.png',
    redirectUrl: "https://starzventures.in",
  ),
  Service(
    name: "Web Application",
    demoDescription:
        "STARZ specializes in developing custom web applications tailored to meet specific business requirements. Our experienced team of developers utilizes the latest technologies to create scalable, secure, and efficient web applications that enhance productivity and contribute to business growth.",
    logoAsset: 'assets/web.png',
    redirectUrl: "https://starzventures.in",
  ),
  Service(
    name: "Android Apps",
    demoDescription:
        "As mobile usage continues to surge, STARZ ensures that your clients stay ahead by offering Android app development services. We design and develop innovative and user-friendly apps that cater to various business needs, enhancing brand visibility and customer engagement on the Android platform.",
    logoAsset: 'assets/andriod.png',
    redirectUrl: "https://starzventures.in",
  ),
  Service(
    name: "Technical Marketing",
    demoDescription:
        "At STARZ, we understand the importance of effective technical marketing strategies. Our team devises comprehensive marketing plans that leverage the latest digital tools and techniques to increase brand visibility, attract target audiences, and drive conversions. We focus on data-driven approaches to optimize marketing campaigns for maximum impact.",
    logoAsset: 'assets/technical marketing.png',
    redirectUrl: "https://starzventures.in",
  ),
  Service(
    name: "Content Writing",
    demoDescription:
        "Our team of skilled content writers crafts compelling and relevant content to engage your clients' audiences. From website copy and blog posts to product descriptions and marketing collateral, we ensure that the content aligns with brand messaging and resonates with the target audience.",
    logoAsset: 'assets/content marketing.png',
    redirectUrl: "https://starzventures.in",
  ),
  Service(
    name: "Analytics",
    demoDescription:
        "STARZ integrates advanced analytics tools to provide valuable insights into website and app performance. By analyzing user behavior, traffic patterns, and other key metrics, we help your clients make informed decisions, refine strategies, and maximize the effectiveness of their online presence.",
    logoAsset: 'assets/analytics.png',
    redirectUrl: "https://starzventures.in",
  ),
  Service(
    name: "Whatsapp Automation",
    demoDescription:
        "To enhance communication and efficiency, STARZ offers WhatsApp automation services. We develop custom automation solutions that enable businesses to automate routine tasks, engage with customers seamlessly, and leverage the power of WhatsApp for marketing, support, and other business processes.",
    logoAsset: 'assets/whatsapp.png',
    redirectUrl: "https://starzventures.in",
  ),
];
