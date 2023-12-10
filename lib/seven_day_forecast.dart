import 'package:flutter/material.dart';
import 'package:weather_app/api_manager.dart';
import 'package:weather_app/weather_displays.dart';
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
      rethrow;
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
            var data = snapshot.data!.properties!.periods!;
            int itemCount = data.length;

            List<DayData> weekData = List.empty(growable: true);

            if (data[0].name  == "Tonight")
            {
              // Move last item to start of list if data was gathered at night
              // Since data for the morning isn't given
              data = data.sublist(itemCount - 1) + data.sublist(0, itemCount - 1);
              itemCount--;
            }
            
            for (int i = 0; i < itemCount; i += 2)
            {
              String? currentDay = (i == 0) ? "Now" : data[i].name!.substring(0, 3);
              int? currentHigh = data[i].temperature;
              int? currentLow = data[i + 1].temperature;
              String? currentCond = data[i].shortForecast;

              weekData.add(
                DayData(
                  dayLabel: currentDay,
                  low: currentLow,
                  high: currentHigh,
                  dayCondition: currentCond,
                )
              );
            }
            
            return Container(
              color: Colors.grey,
              child: ListView.separated(
                itemCount: weekData.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  var dayData = weekData[index];

                  return _buildForecastItem(dayData);
                },
              ),
            );
          } else {
            return const Center(child: Text('No forecast data available.'));
          }
        },
      ),
    );
  }

  Widget _buildForecastItem(DayData data) {
    // Build your list item with forecast data
    // This is just an example, adjust it to fit the actual data structure
    return ListTile(
      // Get condition icon like it is always morning
      leading: MajorWeatherDisplay.getConditionIcon(data.dayCondition!, 40.0, DateTime.now().copyWith(hour: 10), 0.0), // Replace with actual weather icon
      title: Text(data.dayLabel ?? "Unknown"),
      subtitle: Text(data.dayCondition ?? "No forecast available"),
      trailing: Text('${data.low} --> ${data.high}'),
    );
  }
}

class DayData {
  String? dayLabel;
  int? low;
  int? high;
  String? dayCondition;

  DayData({
    required this.dayLabel,
    required this.low,
    required this.high,
    required this.dayCondition,
  });
}