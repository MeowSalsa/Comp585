import 'package:flutter/material.dart';

import 'api_manager.dart';
import 'data_manager.dart';
import 'colors.dart';
import 'local_time.dart';
import 'location_weather_data.dart';
import 'weather_displays.dart';
class CurrentWeatherDisplay extends StatelessWidget {

  final String locationString;
  final WeatherData weatherData = WeatherData();

  CurrentWeatherDisplay({
    super.key,
    required this.locationString,
  });

  @override
  Widget build(BuildContext context) {
    
    double screenWidth = MediaQuery.of(context).size.width;
    weatherData.locationString = locationString;

    return FutureBuilder(
      future: weatherData.getCurrentWeather(),
      builder: (context, snapshot) {

        if(snapshot.hasError){
          return const CircularProgressIndicator();
        }

        final TextTheme textTheme = Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        );

        final TimeBasedColorScheme colorScheme = TimeBasedColorScheme.colorSchemeFromLocalTime(LocalTime.getLocalDayPercent(weatherData.locationLongitude));

        return Theme(
          data: Theme.of(context).copyWith(textTheme: textTheme),
          child: Scaffold(
            
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.skyStartColor,
                    colorScheme.skyEndColor,
                  ],
                  begin: Alignment.topCenter,
                  end: const Alignment(0.0, 0.75),
                  stops: const [0.0, 1.0],
                  tileMode: TileMode.clamp
                ),
              ),
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [

                    // Location label
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth / 28.0, top: screenWidth / 24.0),

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
                                      size: screenWidth / 18.0,
                                    ),

                                    Padding(padding: EdgeInsets.only(left: screenWidth / 72.0)),

                                    Text(
                                      "${weatherData.currentCity}",
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: screenWidth / 20.0,
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
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          // MAJOR WEATHER DISPLAY
                          MajorWeatherDisplay(
                            temperatureLabel: "${weatherData.currentTemp}\u00B0${weatherData.currentUnits}", 
                            longitude: weatherData.locationLongitude,
                            conditionLabel: "${weatherData.currentCond}",
                          ),

                          Padding(padding: EdgeInsets.only(top: screenWidth * (3.0 / 8.0))),

                          // MINOR WEATHER DISPLAYS
                          Card(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            color: colorScheme.mainBGColor,
                            margin: EdgeInsets.zero,
                            child: Column(
                              children: [
                                GridView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 1, crossAxisCount: 2),

                                  children: [
                                    WindDisplay(windSpeed: weatherData.currentWindSpeed, windDirection: weatherData.currentWindDirection,),
                                    PrecipitationDisplay(precipitationChance: weatherData.currentPrecipitationChance,),
                                    HumidityDisplay(humidityPercent: weatherData.currentHumidity,),
                                    DewPointDisplay(dewPoint: weatherData.currentDewPoint,),
                                  ],
                                ),

                                // Placeholder for buttons
                                const Text("hello",),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class WeatherData {

  String? locationString;

  WeatherData({
    this.locationString,
  });

  String? currentCity = "";
  int? currentTemp = 0;
  String? currentUnits = "";
  String? currentCond = "";
  String? currentWindSpeed = "";
  String? currentWindDirection = "";
  String? currentPrecipitationChance;
  String? currentHumidity;
  String? currentDewPoint;
  String? time;
  double? locationLongitude;

  bool isFirstTimeLoad = true;

  Future<void> getCurrentWeather() async {

    if (!isFirstTimeLoad)
    {
      return;
    }

    DataManager newDM = DataManager();
    LocationWeatherData weatherLocation = await newDM.searchForLocation(locationString!);
    HourlyForecast forecast = await newDM.getForecast(weatherLocation, ForecastType.hourly);
    HourlyPeriods currentPeriod = forecast.properties!.periods![0];
    ProbabilityOfPrecipitation? precipitation = currentPeriod.probabilityOfPrecipitation;
    ProbabilityOfPrecipitation? humidity = currentPeriod.relativeHumidity;
    Elevation? dewPoint = currentPeriod.dewpoint;

    currentCity = weatherLocation.displayableString;
    currentTemp = currentPeriod.temperature;
    currentUnits = currentPeriod.temperatureUnit;
    currentCond = currentPeriod.shortForecast;
    
    currentWindSpeed = currentPeriod.windSpeed;
    currentWindDirection = currentPeriod.windDirection;

    currentPrecipitationChance = formatUnitValueString(precipitation!.value, precipitation.unitCode);
    currentHumidity = formatUnitValueString(humidity!.value, humidity.unitCode);

    // Dew Point is in Celsius
    double dewPointValue = (dewPoint!.value!.toDouble() * 9.0) / 5.0 + 32.0;
    currentDewPoint = formatUnitValueString(dewPointValue.toInt(), "\u00B0F");

    locationLongitude = weatherLocation.long!;

    isFirstTimeLoad = false;
  }

  String? formatUnitValueString(int? value, String? unitCode)
  {
    String? displayString = "";

    if (value == null)
    {
      displayString += "0";
    }
    else
    {
      displayString += "$value";
    }
    
    if (unitCode!.contains("percent"))
    {
      displayString += "%";
    }
    else
    {
      displayString += unitCode;
    }

    return displayString;
  }
}