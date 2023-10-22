import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.lightBlue[50], // Light sky blue background
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Day, Month Date, Year',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10.0),
              Expanded(child: CurvedSquareIcon()),
            ],
          ),
        ),
      ),
    );
  }
}

class CurvedSquareIcon extends StatelessWidget {
  const CurvedSquareIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      primary: false,
      childAspectRatio: 1.0,
      // Adjust this value to change the width-to-height ratio of the boxes
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: <Widget>[
        _buildWeatherBox('Los Angeles, CA', '76°', 'Sunny',
            FontAwesomeIcons.sun, Colors.yellow),
        _buildWeatherBox('New York, NY', '63°', 'Mostly Sunny', Icons.wb_sunny,
            Colors.yellow),
        _buildWeatherBox('Las Vegas, NV', '90°', 'Sunny',
            FontAwesomeIcons.sunPlantWilt, Colors.yellow),
        _buildWeatherBox('Boston, MA', '63°', 'Isolated Rain Showers',
            FontAwesomeIcons.cloudRain, Colors.blue),
        _buildWeatherBox(
            'Miami, FL',
            '87°',
            'Chance Showers And Thunderstorms',
            // ignore: deprecated_member_use
            FontAwesomeIcons.thunderstorm,
            Colors.red),
        _buildWeatherBox('Austin, TX', '81°', 'Slight Chance Rain Showers',
            Icons.cloud, Colors.grey),
      ],
    );
  }

  Widget _buildWeatherBox(String city, String temperature, String weather,
      IconData icon, Color iconColor) {
    return Container(
      width: 150.0,
      height: 150.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Adjust the main axis size
          children: [
            Text(city,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            // Adjusted font size
            SizedBox(height: 5),
            Icon(icon, size: 40, color: iconColor),
            // Adjusted icon size
            SizedBox(height: 5),
            Text(temperature,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            // Adjusted font size
            SizedBox(height: 5),
            Text(weather, style: TextStyle(fontSize: 12)),
            // Adjusted font size
          ],
        ),
      ),
    );
  }
}
