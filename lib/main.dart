// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:weather_app/tests.dart';

import 'package:weather_app/data_manager.dart';
import 'api_manager.dart';
import 'location_weather_data.dart';
import 'tests.dart';

import 'daily_weather.dart';

void main() {
  apiSystemTest();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );
    
    return MaterialApp(
      theme: ThemeData(textTheme: textTheme),
      home: Scaffold(
        body: Center(
          child: CurrentWeatherDisplay(locationString: "91344",)
        ),
      ),
    );
  }
}