// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:weather_app/data_manager.dart';
import 'package:weather_app/tests.dart';
import 'api_manager.dart';
import 'location_weather_data.dart';

void main() {
  //runTests();
  LocationWeatherData newLocation = LocationWeatherData("91340");
  Future.delayed(const Duration(seconds: 10), () {
    print("Getting forecast but WP is ${newLocation.weatherPointData}");
    DataManager.getForecast(newLocation);
  });
  Future.delayed(const Duration(seconds: 15), () {
    print("Getting hourly forecast but WP is ${newLocation.weatherPointData}");
    DataManager.getHourlyForecast(newLocation);
  });
  Future.delayed(const Duration(seconds: 15), () {
    print("Printing Data class stuff");
    print(newLocation.city);
    print(newLocation.state);
    print(newLocation.forecast?.properties?.periods?.length);
    print(newLocation.hourlyForecast?.properties?.periods?.length);
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
