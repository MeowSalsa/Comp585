import 'package:flutter/material.dart';

import 'api_manager.dart';
import 'data_manager.dart';
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

        return Scaffold(
          backgroundColor: const Color(0xFF699EEE),

          body: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: screenWidth / 24.0, top: screenWidth / 24.0),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          clipBehavior: Clip.hardEdge,
                          child: Text(
                            "${weatherData.currentCity}, ${weatherData.currentState}",
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: screenWidth / 20.0,
                              fontWeight: FontWeight.bold,
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
                      Padding(padding: EdgeInsets.only(top: screenWidth / 13.1)),

                      // MAJOR WEATHER DISPLAY
                      // Condition icon
                      Container(
                        padding: EdgeInsets.all(screenWidth / 36.0),
                        child: Icon(
                          Icons.sunny,
                          color: const Color(0xFFFFF386),
                            size: screenWidth / 2.0,
                        ),
                      ),

                      // Temperature
                      Text(
                        "${weatherData.currentTemp}\u00B0${weatherData.currentUnits}",
                        style: TextStyle(
                          fontSize: screenWidth / 7.5,
                        ),
                      ),

                      //Condition label
                      Text(
                        "${weatherData.currentCond}",
                        style: TextStyle(
                          fontSize: screenWidth / 22.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Padding(padding: EdgeInsets.only(top: screenWidth * (3.0 / 8.0))),

                      // MINOR WEATHER DISPLAYS
                      Card(
                        color: const Color(0xFF97D3BD),
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
  String? currentState = "";
  int? currentTemp = 0;
  String? currentUnits = "";
  String? currentCond = "";
  String? currentWindSpeed = "";
  String? currentWindDirection = "";
  String? currentPrecipitationChance;
  String? currentHumidity;

  bool isFirstTimeLoad = true;

  Future<void> getCurrentWeather() async {

    if (!isFirstTimeLoad)
    {
      return;
    }

    DataManager newDM = DataManager();
    LocationWeatherData weatherLocation = await newDM.searchForLocation(locationString!);
    HourlyForecast forecast = await newDM.getForecast(weatherLocation, ForecastType.hourly);
    RelativeLocation? currentLocation = weatherLocation.weatherPointData!.properties!.relativeLocation;
    HourlyPeriods currentPeriod = forecast.properties!.periods![0];
    ProbabilityOfPrecipitation? precipitation = currentPeriod.probabilityOfPrecipitation;
    ProbabilityOfPrecipitation? humidity = currentPeriod.relativeHumidity;

    currentCity = currentLocation!.properties!.city;
    currentState = currentLocation.properties!.state;
    currentTemp = currentPeriod.temperature;
    currentUnits = currentPeriod.temperatureUnit;
    currentCond = currentPeriod.shortForecast;
    
    currentWindSpeed = currentPeriod.windSpeed;
    currentWindDirection = currentPeriod.windDirection;

    currentPrecipitationChance = formatPrecipitation(precipitation);
    
    currentHumidity = formatPrecipitation(humidity);

    isFirstTimeLoad = false;
  }

  String? formatPrecipitation(ProbabilityOfPrecipitation? p)
  {
    String? displayString = "";

    if (p!.value == null)
    {
      displayString += "0";
    }
    else
    {
      displayString += "${p.value}";
    }

    if (p.unitCode!.contains("percent"))
    {
      displayString += "%";
    }

    return displayString;
  }
}