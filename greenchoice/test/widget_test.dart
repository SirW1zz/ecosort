import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_project_name/main.dart'; // Replace with your actual project name

void main() {
  testWidgets('Home page loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verify that the home page is shown
    expect(find.text('Home'), findsOneWidget);

    // Verify that the "Open Scanner" button exists
    expect(find.text('Open Scanner'), findsOneWidget);
  });
}
