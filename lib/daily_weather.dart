import 'package:flutter/material.dart';

import 'api_manager.dart';
import 'data_manager.dart';
import 'location_weather_data.dart';
import 'weather_displays.dart';

class CurrentWeatherDisplay extends StatelessWidget {

  final String locationString;

  const CurrentWeatherDisplay({
    super.key,
    required this.locationString,
  });

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

  @override
  Widget build(BuildContext context) {

    String? currentCity = "";
    String? currentState = "";
    int? currentTemp = 0;
    String? currentUnits = "";
    String? currentCond = "";
    String? currentWindSpeed = "";
    String? currentWindDirection = "";
    String? currentPrecipitationChance;
    String? currentHumidity;

    List<Widget>? minorWeatherDisplays;

    Future<void> getCurrentWeather() async {

      DataManager newDM = DataManager();
      LocationWeatherData weatherLocation = await newDM.searchForLocation(locationString);
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

      minorWeatherDisplays = [
        WindDisplay(windSpeed: currentWindSpeed, windDirection: currentWindDirection,),
        PrecipitationDisplay(precipitationChance: currentPrecipitationChance,),
        HumidityDisplay(humidityPercent: currentHumidity,),
      ];
    }
    
    return FutureBuilder(
      future: getCurrentWeather(),
      builder: (context, snapshot) {

        if(snapshot.hasError || minorWeatherDisplays == null){
          return const CircularProgressIndicator();
        }

        return Scaffold(
          backgroundColor: const Color(0xFF699EEE),

          body: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, top: 30.0),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.cover,
                        child: Text(
                          "$currentCity, $currentState",
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
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
                      const Padding(padding: EdgeInsets.only(top: 100)),

                      // MAJOR WEATHER DISPLAY
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        child: const Icon(
                          Icons.sunny,
                          color: Color(0xFFFFF386),
                          size: 300.0,
                        ),
                      ),
                      Text(
                        "$currentTemp\u00B0$currentUnits",
                        style: const TextStyle(
                          fontSize: 96,
                        ),
                      ),
                      Text(
                        "$currentCond",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Padding(padding: EdgeInsets.only(top: 100)),

                      // MINOR WEATHER DISPLAYS
                      Card(
                        color: const Color(0xFF97D3BD),
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                const crossAxisCount = 2;

                                return GridView.builder(
                                  shrinkWrap: true,
                                  itemCount: minorWeatherDisplays!.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 1, crossAxisCount: crossAxisCount),
                                  itemBuilder: (BuildContext context, int index) {
                                    return minorWeatherDisplays![index];
                                  }
                                );
                              }
                            ),

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