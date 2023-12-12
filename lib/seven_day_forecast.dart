import 'package:flutter/material.dart';
import 'api_manager.dart';
import 'data_manager.dart';
import 'location_weather_data.dart';
import 'weather_displays.dart';
import 'local_time.dart';
import 'colors.dart';


class ForecastPage extends StatefulWidget {
  final String locationString;

  const ForecastPage({Key? key, required this.locationString})
      : super(key: key);

  @override
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  late Future<Forecast> _sevenDayForecast;
  late LocationWeatherData? _locationWeatherData;

  @override
  void initState() {
    super.initState();
    _sevenDayForecast = _loadForecast();
  }

  Future<Forecast> _loadForecast() async {
    try {
      // Use the provided location string to search for the location and get the forecast
      _locationWeatherData = await DataManager.searchForLocation(widget.locationString);
      // we want the weekly forecast
      return await DataManager.getForecast(_locationWeatherData!, ForecastType.weekly);
    } catch (e) {
      print("Error fetching seven day forecast: $e");
      // Handle error
      rethrow;
    }
  }

  List<DayData> groupWeekData(List<Periods> data) {
    List<DayData> weekData = [];
    int itemCount = data.length;

    if (data[0].name!.contains("night"))
    {
      // Move last item to start of list if data was gathered at night
      // Since data for the morning isn't given
      data = data.sublist(itemCount - 1) + data.sublist(0, itemCount - 1);

      // data[0].shortForecast = data[1].shortForecast isnt valid
      // Make a copy of data[0] with that one change instead
      data[0] = Periods(
        name: data[0].name,
        temperature: data[0].temperature,
        temperatureUnit: data[0].temperatureUnit,
        shortForecast: data[1].shortForecast,
      );
    }

    // Shorten each shortForecast to only include first condition
    for (Periods period in data)
    {
      String? currentCond = period.shortForecast;
      currentCond = (currentCond!.contains("then")) 
        ? currentCond.substring(0, currentCond.indexOf("then") - 1) 
        : currentCond;
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

    return weekData;
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: FutureBuilder<Forecast>(
        future: _sevenDayForecast,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            var data = snapshot.data!.properties!.periods!;
            List<DayData> weekData = groupWeekData(data);

            List<int> minLowInds = [];
            List<int> maxHighInds = [];

            int minLow = weekData[0].low!;
            int maxHigh = weekData[0].high!;

            for (int i = 0; i < weekData.length; i++)
            {
              int currLow = weekData[i].low!;
              int currHigh = weekData[i].high!;

              if (currLow < minLow)
              {
                minLow = currLow;
              }

              if (currHigh > maxHigh)
              {
                maxHigh = currHigh;
              }
            }

            double topPadding = MediaQuery.of(context).viewPadding.top;
            double screenWidth = MediaQuery.of(context).size.width;
            double screenHeight = MediaQuery.of(context).size.height;
            Color bgColor = TimeBasedColorScheme.colorSchemeFromLocalTime(
              LocalTime.getLocalDayPercent(_locationWeatherData!.long)
            ).mainBGColor;
            
            return Container(
              color: bgColor,
              width: screenWidth,
              height: screenHeight,
              child: Column(
                children: [
                  
                  // Location Title
                  Padding(
                    padding: EdgeInsets.only(
                      left: screenHeight / 50.0,
                      top: screenHeight / 75.0 + topPadding
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            clipBehavior: Clip.hardEdge,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: screenHeight / 32.0,
                                  ),

                                  Padding(padding: EdgeInsets.only(left: screenHeight / 53.0)),

                                  Text(
                                    widget.locationString,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenHeight / 35.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(
                      screenHeight / 42.6, 
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "7-Day Forecast",
                          style: TextStyle(
                            fontSize: screenHeight / 35.6,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth / 21.3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(screenHeight / 30.0),
                      child: Container(
                        padding: EdgeInsets.all(screenWidth / 42.6),
                        color: const Color(0x80E7E7E7),
                        child:ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: weekData.length,
                          separatorBuilder: (context, index) => Padding(
                            padding: EdgeInsets.only(top: screenHeight / 80.0),
                          ),
                          itemBuilder: (context, index) {
                            var dayData = weekData[index];

                            return _buildForecastItem(dayData, minLow, maxHigh);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No forecast data available.'));
          }
        },
      ),
    );
  }

  Widget _buildForecastItem(DayData data, int minLow, int maxHigh) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          data.dayLabel ?? "Unknown",
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth / 20.0,
            fontWeight: FontWeight.w900,
          ),
        ),

        // Get condition icon like it is always morning
        MajorWeatherDisplay.getConditionIcon(data.dayCondition!, screenWidth / 10.0, DateTime.now().copyWith(hour: 10), 0.0), // Replace with actual weather icon
        
        Text(
          '${data.low}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: (data.low != minLow) ? null : FontWeight.bold,
            fontSize: screenWidth / 15.0,
          ),
        ),

        _buildTemperatureBar(minLow, maxHigh, data.low!, data.high!),

        Text(
          '${data.high}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: (data.high != maxHigh) ? null : FontWeight.bold,
            fontSize: screenWidth / 15.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureBar(int min, int max, int start, int end) {
    double screenWidth = MediaQuery.of(context).size.width;

    double barWidth = screenWidth * 3.0 / 16.0;
    double barHeight = screenWidth / 72.0;

    double innerBarPercent = (end - start) / (max - min);
    double innerBarWidth = barWidth * innerBarPercent;

    double innerBarSpacingPercent = (start - min) / (max - min);
    double innerBarSpacing = barWidth * innerBarSpacingPercent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(barHeight / 2.0),
      child: Container(
        color:const Color(0x80808080),
        child: SizedBox(
          width: barWidth,
          height: barHeight,
          child: Row(
            children: [
              Padding(padding: EdgeInsets.only(left: innerBarSpacing)),

              ClipRRect(
                borderRadius: BorderRadius.circular(barHeight / 2.0),
                child: Container(
                  color: Colors.white,
                  child: SizedBox(
                    width: innerBarWidth,
                    height: barHeight,
                  )
                ),
              ),
            ],
          ),
        ),
      ),
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