// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:weather_app/tests.dart';
import 'api_manager.dart';
import 'location_weather_data.dart';

void main() {
  //runTests();
  LocationWeatherData newLocation = LocationWeatherData("91340");
  Future.delayed(const Duration(seconds: 2), () {
    newLocation.getForecast();
  });
  Future.delayed(const Duration(seconds: 2), () {
    print(newLocation.city);
    print(newLocation.forecast?.properties?.periods);
  });
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
