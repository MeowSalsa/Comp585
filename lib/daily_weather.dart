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

    List<MinorWeatherDisplay>? minorWeatherDisplays;

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
        MinorWeatherDisplay(displayText: "$currentWindSpeed $currentWindDirection",),
        MinorWeatherDisplay(displayText: "$currentPrecipitationChance",),
        MinorWeatherDisplay(displayText: "$currentHumidity",),
      ];
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF699EEE),
      body: Center(
        child: FutureBuilder(
          future: getCurrentWeather(),
          builder: (context, snapshot) {

            if(snapshot.hasError || minorWeatherDisplays == null){
              return const CircularProgressIndicator();
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // MAJOR WEATHER DISPLAY
                Text(
                  "$currentCity, $currentState",
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
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

                // MINOR WEATHER DISPLAY
                Flexible(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      const crossAxisCount = 2;

                      return GridView.builder(
                        itemCount: minorWeatherDisplays!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 1, crossAxisCount: crossAxisCount),
                        itemBuilder: (BuildContext context, int index) {
                          return minorWeatherDisplays![index];
                        }
                      );
                    }
                  )
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}