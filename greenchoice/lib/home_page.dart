import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
// import '../routes.dart';
import 'scanner_page.dart';

class HomePage extends StatelessWidget {
  final Function(bool) toggleTheme;
  final bool isDarkTheme;

  const HomePage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScannerPage()),
            );
          },
          child: Text("Open Scanner"),
        ),
      ),
    );
  }
}
