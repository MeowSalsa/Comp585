// ignore_for_file: avoid_print

import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'api_manager.dart';

void main() {
  testWeatherPoint();
  runApp(const MainApp());
}

//Testing functions Begin
HashMap<String, WeatherPoint> locationMap = HashMap();
testWeatherPoint() async {
  final weatherPointAPIResult = await APIManager().getWeatherPoint();
  testPrintouts(weatherPointAPIResult);
  locationMap[weatherPointAPIResult.properties?.gridId as String] =
      weatherPointAPIResult;
  print("Map length: ${locationMap.length}");
  testForecast();
}

void testPrintouts(WeatherPoint apiResult) {
  print(apiResult.id);
  print(apiResult.properties);
  var properties = apiResult.properties;
  print(properties?.gridId);
  print(properties?.gridX);
  print(properties?.gridY);
  print(properties?.relativeLocation?.properties?.city);
  print(properties?.relativeLocation?.properties?.state);
}

testForecast() async {
  Forecast result;
  locationMap.forEach((key, value) async {
    result = await APIManager().getForecast(value);
    print("Forceast periods length ${result.properties?.periods?.length}");
    printForecast(result);
  });
}

printForecast(Forecast forecast) {
  List<Periods>? weatherPeriods = forecast.properties?.periods;

  for (int i = 0; i < weatherPeriods!.length; i++)
  {
    int? currentTemp = weatherPeriods[i].temperature;
    String? currentStartTime = weatherPeriods[i].startTime;
    DateTime currentDate = DateTime.parse(currentStartTime!).toLocal();
    print("$currentDate: $currentTemp");
  }
}

//Testing Functions End
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
