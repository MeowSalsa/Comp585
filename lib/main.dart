// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

// void main() {
//   runApp(const MyApp());
// }

// Mock function to simulate fetching weather details for a city
// Future<String> fetchWeatherDetails(String city) async {
// In reality, you'd make an API call here and get the details for the city.
//   await Future.delayed(const Duration(seconds: 1)); // Simulating network delay
//   return "Weather details for $city"; // Placeholder text
// }

import 'package:weather_app/tests.dart';

import 'package:weather_app/data_manager.dart';
import 'api_manager.dart';
import 'location_weather_data.dart';


void main() {
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
    );
  }
}

Future<String> fetchWeatherDetails(String city) async {
  await Future.delayed(const Duration(seconds: 1));
  return "Weather details for $city";
}

class DetailScreen extends StatefulWidget {
  final String city;

  const DetailScreen({Key? key, required this.city}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<String> weatherDetails;

  @override
  void initState() {
    super.initState();
    weatherDetails = fetchWeatherDetails(widget.city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.city} Weather Details')),
      body: Center(
        child: FutureBuilder<String>(
          future: weatherDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text("Error fetching weather details");
            } else {
              return Text(snapshot.data ?? "No details available");
            }
          },
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  MyApp({super.key}); // Step 1

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: TextField(
              controller: _controller, // set the controller for the TextField
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
              onSubmitted: (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(city: _controller.text),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                formattedDate,
                style: const TextStyle(
                    fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10.0),
            const Expanded(child: CurvedSquareIcon()),
          ],
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
        _buildWeatherBox(context, 'Los Angeles, CA', '76°', 'Sunny',
            FontAwesomeIcons.sun, Colors.yellow),
        _buildWeatherBox(context, 'New York, NY', '63°', 'Mostly Sunny',
            Icons.wb_sunny, Colors.yellow),
        _buildWeatherBox(context, 'Las Vegas, NV', '90°', 'Sunny',
            FontAwesomeIcons.sunPlantWilt, Colors.yellow),
        _buildWeatherBox(context, 'Boston, MA', '63°', 'Isolated Rain Showers',
            FontAwesomeIcons.cloudRain, Colors.blue),
        _buildWeatherBox(
            context,
            'Miami, FL',
            '87°',
            'Chance Showers And Thunderstorms',
            // ignore: deprecated_member_use
            FontAwesomeIcons.thunderstorm,
            Colors.red),
        _buildWeatherBox(context, 'Austin, TX', '81°',
            'Slight Chance Rain Showers', Icons.cloud, Colors.grey),
      ],
    );
  }

  Widget _buildWeatherBox(BuildContext context, String city, String temperature,
      String weather, IconData icon, Color iconColor) {
    return Builder(builder: (BuildContext innerContext) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              innerContext,
              MaterialPageRoute(
                builder: (context) => DetailScreen(city: city),
              ),
            );
          },
          child: Container(
            width: 150.0,
            height: 150.0,
            decoration: BoxDecoration(
              // color: Colors.transparent,
              // borderRadius: BorderRadius.circular(15.0),
              // border:
              //     Border.all(color: Colors.white.withOpacity(0.5), width: 1.0),
              color: Colors.grey.withOpacity(0.3), // 0.5 means 50% opacity
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Adjust the main axis size
                children: [
                  Text(city,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 5),
                  Icon(icon, size: 40, color: iconColor),
                  const SizedBox(height: 5),
                  Text(temperature,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(weather, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
