// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:weather_app/tests.dart';
import 'api_manager.dart';

void main() {
  runTests();
  runApp(const MainApp());
}

void runTests() {
  print(DateTime.now());
  testWeatherPoint();
  Future.delayed(const Duration(seconds: 1), () {
    print("Starting Forecast Test");
    print(DateTime.now());
    testForecast();
  });
  Future.delayed(Duration(seconds: 1), () {
    print("Starting Hourly Forecast Test");
    testHourlyForecast();
  });
  Future.delayed(Duration(seconds: 1), () {
    print("Starting Coordinates from City,State");
    testCoordsFromCityState();
  });
  Future.delayed(Duration(seconds: 1), () {
    print("Starting Coordinates from City,State");
    testCoordsFromZip();
  });
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
