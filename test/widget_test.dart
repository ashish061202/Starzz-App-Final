// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:STARZ/screens/home/components/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart'; // Import mockito
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

import 'package:STARZ/main.dart';

class MockSharedPreferences extends Mock
    implements SharedPreferences {} // Create a mock for SharedPreferences

class MockDarkModeController extends Mock implements DarkModeController {}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final mockPrefs = MockSharedPreferences(); // Create an instance of the mock
    final mockDarkModeController = MockDarkModeController();
    when(mockPrefs.getInt('counter'))
        .thenReturn(0); // Mock the behavior of SharedPreferences
        // Mock the behavior of DarkModeController
    when(mockDarkModeController.isDarkMode).thenReturn(RxBool(true));
    when(mockDarkModeController.toggleDarkMode()).thenReturn(null);
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(prefs: mockPrefs, darkModeController: mockDarkModeController));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
