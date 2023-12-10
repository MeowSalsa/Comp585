import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data_manager.dart';
import 'api_manager.dart';
import 'location_weather_data.dart';
import 'colors.dart';
import 'local_time.dart';
import 'daily_weather.dart';
import 'weather_displays.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Load favorites from file
  await DataManager.loadFavorites();
  for (var favorite in DataManager.getFavorites())
  {
    await DataManager.initializeLocation(favorite);
  }
  /* var newLocation = await DataManager.searchForLocation("Eugene, Oregon");
  await DataManager.addToFavorites(newLocation);
  newLocation = await DataManager.searchForLocation("91331");
  await DataManager.addToFavorites(newLocation);
  newLocation = await DataManager.searchForLocation("Los Angeles, California");
  await DataManager.addToFavorites(newLocation);
  newLocation = await DataManager.searchForLocation("Houston, Texas");
  await DataManager.addToFavorites(newLocation);
  newLocation = await DataManager.searchForLocation("New York, New York");
  await DataManager.addToFavorites(newLocation); */
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

  String getOrdinal(int num)
  {
    if(num >= 11 && num <= 13)
    {
      return "th";
    }

    switch(num % 10)
    {
      case 1: 
        return "st";
      case 2: 
        return "nd";
      case 3: 
        return "rd";
      default: 
        return "th";
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(currentDate);
    formattedDate = formattedDate.substring(0, formattedDate.lastIndexOf(",")) + getOrdinal(currentDate.day) + formattedDate.substring(formattedDate.lastIndexOf(","));
    
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
                  fontSize: 24.0, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 20.0)),
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
  late Future<List<Periods>> weatherForecasts;
  late List<LocationWeatherData> favoriteLocations;

  @override
  void initState() {
    super.initState();
    weatherForecasts = fetchWeatherForecasts();
    favoriteLocations = DataManager.getFavorites();
    print(favoriteLocations.length);
  }

  Future<List<Periods>> fetchWeatherForecasts() async {
    await DataManager.loadFavorites(); // Load favorites from file
    List<LocationWeatherData> favorites = DataManager.getFavorites();

    List<Periods> forecasts = [];
    for (var favorite in favorites) {
      try {
        Periods forecast =
            await DataManager.getForecast(favorite, ForecastType.now);
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
        crossAxisSpacing: 20.0, // Horizontal spacing between grid items
        mainAxisSpacing: 20.0, // Vertical spacing between grid items
        childAspectRatio: 1.0, // Aspect ratio for items in the grid
        children: favoriteLocations
            .map((location) =>
                _buildWeatherBoxWithLocationObject(context, location))
            .toList(),
      );
    } else {
      return const Text('No locations saved. Try searching for one above.');
    }
  }


  Widget _buildWeatherBoxWithLocationObject(BuildContext context, LocationWeatherData location) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    var city = location.displayableString ?? 'Unknown Location';
    var currentForecast = DataManager.getNowForecast(location);
    var temperature = '${currentForecast.temperature ?? 'N/A'}°';
    String weather = currentForecast.shortForecast ?? 'Unavailable';

    TimeBasedColorScheme colorScheme = TimeBasedColorScheme.colorSchemeFromLocalTime(LocalTime.getLocalDayPercent(location.long));

    print("${location.displayableString} (${location.long}) last updated at ${location.hourlyForecastTimeStamp}");
    
    // This widget builds each individual weather box with the city, temperature, and weather condition.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CurrentWeatherDisplay(
                locationString: location.searchInput ?? "something went wrong"
              ),
            ),
          );
        },
        child: Container(
          // width: 150.0,
          // height: 150.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.skyStartColor,
                colorScheme.skyEndColor,
              ],
              begin: Alignment.topCenter,
              end: const Alignment(0.0, 2.0),
            ),
            borderRadius: BorderRadius.circular(screenHeight / 32.0),
            // boxShadow: [
            //   // Just trying this out, Optional: Adds a shadow to lift the card visually
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.5),
            //     spreadRadius: 2,
            //     blurRadius: 4,
            //     offset: const Offset(0, 3), // changes position of shadow
            //   ),
            // ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                MiniWeatherDisplay(
                  topLabel: Text(
                    city,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    )
                  ),
                  conditionString: weather,
                  bottomLabel: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        temperature,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )
                      ),
                      Text(
                        weather,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        )
                      ),
                    ],
                  ),
                  iconSize: screenWidth / 10.0,
                  time: DateTime.now(),
                  longitude: location.long,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
