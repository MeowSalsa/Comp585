import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/daily_weather.dart';
import 'package:weather_app/tests.dart';
import 'package:weather_app/data_manager.dart';
import 'api_manager.dart';
import 'location_weather_data.dart';
import 'seven_day_forecast.dart';

DataManager dataManager = DataManager();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Load favorites from file
  await dataManager.loadFavorites();
  /* var newLocation = await dataManager.searchForLocation("Eugene, Oregon");
  await dataManager.addToFavorites(newLocation);
  newLocation = await dataManager.searchForLocation("91331");
  await dataManager.addToFavorites(newLocation);
  newLocation = await dataManager.searchForLocation("Los Angeles, California");
  await dataManager.addToFavorites(newLocation);
  newLocation = await dataManager.searchForLocation("Houston, Texas");
  await dataManager.addToFavorites(newLocation);
  newLocation = await dataManager.searchForLocation("New York, New York");
  await dataManager.addToFavorites(newLocation); */
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

  MyApp({super.key});

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
              controller: _controller,
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
                    builder: (context) =>
                        CurrentWeatherDisplay(locationString: _controller.text),
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
  late List<LocationWeatherData> favoriteLocations;

  @override
  void initState() {
    super.initState();
    weatherForecasts = fetchWeatherForecasts();
    favoriteLocations = dataManager.getFavorites();
    print(favoriteLocations.length);
  }

  Future<List<HourlyPeriods>> fetchWeatherForecasts() async {
    await dataManager.loadFavorites(); // Load favorites from file
    List<LocationWeatherData> favorites = dataManager.getFavorites();

    List<HourlyPeriods> forecasts = [];
    for (var favorite in favorites) {
      try {
        HourlyPeriods forecast =
            await dataManager.getForecast(favorite, ForecastType.now);
        forecasts.add(forecast);
      } catch (e) {
        print('Error fetching forecast for ${favorite.searchInput}: $e');
      }
    }
    return forecasts;
  }

  @override
  Widget build(BuildContext context) {
    if (favoriteLocations.isNotEmpty) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 50.0, // Horizontal spacing between grid items
        mainAxisSpacing: 50.0, // Vertical spacing between grid items
        childAspectRatio: 1.0, // Aspect ratio for items in the grid
        children: favoriteLocations
            .map((location) =>
                _buildWeatherBoxWithLocationObject(context, location))
            .toList(),
      );
    } else {
      return const Text('No weather data available');
    }
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

  Widget _buildWeatherBoxWithLocationObject(
      BuildContext context, LocationWeatherData location) {
    var city = location.displayableString ?? 'Unknown Location';
    var currentForecast = dataManager.getNowForecast(location);
    var temperature = '${currentForecast.temperature ?? 'N/A'}°';
    String weather = currentForecast.shortForecast ?? 'Unavailable';
    IconData icon =
        getIconForCondition(dataManager.getNowForecast(location).shortForecast);
    Color iconColor = getColorForTemperature(
        dataManager.getNowForecast(location).temperature);
    print(
        "${location.displayableString} last updated at ${location.hourlyForecastTimeStamp}");
    // This widget builds each individual weather box with the city, temperature, and weather condition.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForecastPage(
                locationString: location.searchInput ?? "Unknown Location",
              ),
            ),
          );
        },
        // ---this sends you to the weather details of the clicked location------------------
        // onTap: () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => CurrentWeatherDisplay(
        //           locationString:
        //               location.searchInput ?? "something went wrong"),
        //     ),
        //   );
        // },
        //----------------------------------------------------------------------------------
        child: Container(
          // width: 150.0,
          // height: 150.0,
          decoration: BoxDecoration(
            //color: Colors.white.withOpacity(0.3),
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              // Just trying this out, Optional: Adds a shadow to lift the card visually
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
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
}
