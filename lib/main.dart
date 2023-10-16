import 'package:flutter/material.dart';
import 'api_manager.dart';

void main() {
  testWeatherPoint();
  runApp(const MainApp());
}

testWeatherPoint() async {
  final weatherPointAPIResult = await APIManager().getWeatherPoint();
  //print(weatherPointAPIResult.gridId);
  print(weatherPointAPIResult.id);
  print(weatherPointAPIResult.properties);
  var prop = weatherPointAPIResult.properties;
  print(prop?.forecast);
  print(prop?.forecastHourly);
  print(prop?.gridId);
  print(prop?.gridX);
  print(prop?.gridY);
  print(prop?.relativeLocation?.properties?.city);
  print(prop?.relativeLocation?.properties?.state);
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
