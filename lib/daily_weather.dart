import 'package:flutter/material.dart';
import 'dart:convert';

import 'api_manager.dart';

class CurrentWeatherDisplay extends StatelessWidget {

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

      var currentWeatherPoint = await APIManager().getWeatherPoint();
      Forecast forecast = await APIManager().getForecast(currentWeatherPoint);
      RelativeLocation? currentLocation = currentWeatherPoint.properties!.relativeLocation;
      Periods currentPeriod = forecast.properties!.periods![0];
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