// ignore_for_file: avoid_print

import 'dart:collection';

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

DataManager dataManager = DataManager();
void main() async {
  runApp(const RootApp());
  //RUN THE BELOW COMMENTED SECTION ONCE TO CREATE AND POPULATE THE FAVORITES
  //FILE AND FAVORITES HASHMAP. COMMENT IT OUT AFTER TO WORK ON ONLY THE FAVORITED DATA
  /* LocationWeatherData newLocation =
      await dataManager.searchForLocation("91331");
  dataManager.addToFavorites(newLocation);
  newLocation = await dataManager.searchForLocation("Los Angeles, California");
  dataManager.addToFavorites(newLocation); */
  await dataManager.loadFavorites(); // reads favorite file
  var favorites = dataManager.getFavorites();
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

class CurvedSquareIcon extends StatefulWidget {
  const CurvedSquareIcon({Key? key}) : super(key: key);

  @override
  _CurvedSquareIconState createState() => _CurvedSquareIconState();
}

class _CurvedSquareIconState extends State<CurvedSquareIcon> {
  late Future<List<HourlyPeriods>> weatherForecasts;

  @override
  void initState() {
    super.initState();
    weatherForecasts = fetchWeatherForecasts();
  }

  Future<List<HourlyPeriods>> fetchWeatherForecasts() async {
    List<LocationWeatherData> cities = List.empty(growable: true);

    DataManager dataManager = DataManager();
    cities.add(await dataManager.searchForLocation("Los Angeles, California"));
    List<HourlyPeriods> forecasts = [];

    for (var city in cities) {
      try {
        HourlyPeriods forecast =
            await dataManager.getForecast(city, ForecastType.now);
        forecasts.add(forecast);
      } catch (e) {
        print('Error fetching forecast for $city: $e');
        // Handle the error or add a placeholder
      }
    }
    return forecasts;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HourlyPeriods>>(
      future: weatherForecasts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text("Error fetching weather data");
        } else if (snapshot.hasData) {
          return GridView.count(
            crossAxisCount: 2,
            children: snapshot.data!
                .map((forecast) => _buildWeatherBox(
                      context,
                      forecast.name ?? 'Unknown Location',
                      '${forecast.temperature ?? 'N/A'}°',
                      forecast.shortForecast ?? 'Unavailable',
                      getIconForCondition(forecast.shortForecast),
                      getColorForTemperature(forecast.temperature),
                    ))
                .toList(),
          );
        } else {
          return const Text('No weather data available');
        }
      },
    );
  }

  IconData getIconForCondition(String? iconCode) {
    // Implement your own logic to map iconCode to IconData
    // This is just a placeholder
    return FontAwesomeIcons.sun;
  }

  Color getColorForTemperature(int? temperature) {
    // Implement your own logic to return a color based on the temperature
    // This is just a placeholder
    return Colors.yellow;
  }
}
//---------------------------------------------------
//uncomment this to go back how i had it - A.C.
//--------------------------------------------------
//     children: <Widget>[
//       _buildWeatherBox(context, 'Los Angeles, CA', '76°', 'Sunny',
//           FontAwesomeIcons.sun, Colors.yellow),
//       _buildWeatherBox(context, 'New York, NY', '63°', 'Mostly Sunny',a
//           Icons.wb_sunny, Colors.yellow),
//       _buildWeatherBox(context, 'Las Vegas, NV', '90°', 'Sunny',
//           FontAwesomeIcons.sunPlantWilt, Colors.yellow),
//       _buildWeatherBox(context, 'Boston, MA', '63°', 'Isolated Rain Showers',
//           FontAwesomeIcons.cloudRain, Colors.blue),
//       _buildWeatherBox(
//           context,
//           'Miami, FL',
//           '87°',
//           'Chance Showers And Thunderstorms',
//           / ignore: deprecated_member_use
//           FontAwesomeIcons.thunderstorm,
//           Colors.red),
//       _buildWeatherBox(context, 'Austin, TX', '81°',
//           'Slight Chance Rain Showers', Icons.cloud, Colors.grey),
//     ],
//   );
// }

Widget _buildWeatherBox(BuildContext context, String city, String temperature,
    String weather, IconData icon, Color iconColor) {
  // This widget builds each individual weather box with the city, temperature, and weather condition.
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(city: city),
          ),
        );
      },
      child: Container(
        width: 150.0,
        height: 150.0,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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
}
