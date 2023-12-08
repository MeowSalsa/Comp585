import 'package:flutter/material.dart';
import 'package:weather_app/api_manager.dart';
import 'location_weather_data.dart';
import 'data_manager.dart';

class ForecastPage extends StatefulWidget {
  final String locationString;

  const ForecastPage({Key? key, required this.locationString})
      : super(key: key);

  @override
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  late Future<Forecast> _sevenDayForecast;

  @override
  void initState() {
    super.initState();
    _sevenDayForecast = _loadForecast();
  }

  Future<Forecast> _loadForecast() async {
    try {
      // Use the provided location string to search for the location and get the forecast
      LocationWeatherData locationWeatherData =
          await DataManager.searchForLocation(widget.locationString);
      // we want the weekly forecast
      return await DataManager.getForecast(
          locationWeatherData, ForecastType.weekly);
    } catch (e) {
      print("Error fetching seven day forecast: $e");
      // Handle error
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('7-Day Forecast'),
      ),
      body: FutureBuilder<Forecast>(
        future: _sevenDayForecast,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return ListView.separated(
              itemCount: snapshot.data!.properties!.periods!.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                var period = snapshot.data!.properties!.periods![index];
                return _buildForecastItem(period);
              },
            );
          } else {
            return const Center(child: Text('No forecast data available.'));
          }
        },
      ),
    );
  }

  Widget _buildForecastItem(Periods forecast) {
    // Build your list item with forecast data
    // This is just an example, adjust it to fit the actual data structure
    return ListTile(
      leading: Icon(Icons.wb_sunny), // Replace with actual weather icon
      title: Text(forecast.name ?? "Unknown"),
      subtitle: Text(forecast.shortForecast ?? "No forecast available"),
      trailing: Text('${forecast.temperature}°${forecast.temperatureUnit}'),
    );
  }
}
