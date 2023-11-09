import 'package:flutter/material.dart';

import 'api_manager.dart';
import 'data_manager.dart';
import 'location_weather_data.dart';

class CurrentWeatherDisplay extends StatelessWidget {

  final String locationString;

  const CurrentWeatherDisplay({
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
    }
    
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: getCurrentWeather(),
          builder: (context, snapshot) {

            if(snapshot.hasError){
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
                MinorWeatherDisplay(displayText: "$currentWindSpeed $currentWindDirection",),
                MinorWeatherDisplay(displayText: "$currentPrecipitationChance",),
                MinorWeatherDisplay(displayText: "$currentHumidity",),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MinorWeatherDisplay extends StatelessWidget {

  final String? displayText;

  const MinorWeatherDisplay({
    this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      displayText!,
      style: const TextStyle(
        fontSize: 32,
      ),
    );
  }
}