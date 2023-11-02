import 'package:flutter/material.dart';
import 'dart:convert';

import 'api_manager.dart';

class CurrentWeatherDisplay extends StatelessWidget {

  String? formatPrecipitation(ProbabilityOfPrecipitation? p)
  {
    print(p?.value);
    print(p?.unitCode);
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

    Future<WeatherPoint> getCurrentWeather() async {

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

      return currentWeatherPoint;
    }
    
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: getCurrentWeather(),
          builder: (context, snapshot) {

            if(!snapshot.hasData){
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
                Text(
                  "$currentWindSpeed $currentWindDirection",
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                ),
                Text(
                  "$currentPrecipitationChance",
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                ),
                Text(
                  "$currentHumidity",
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}