// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:weather_app/tests.dart';

import 'package:weather_app/data_manager.dart';
import 'api_manager.dart';
import 'location_weather_data.dart';
import 'tests.dart';

void main() {
  apiSystemTest();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}