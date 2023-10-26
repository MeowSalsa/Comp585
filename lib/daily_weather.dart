import 'package:flutter/material.dart';

import 'api_manager.dart';

class CurrentWeatherDisplay extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    String? currentCity = "";
    String? currentState = "";
    int? currentTemp = 0;
    String? currentUnits = "";
    String? currentCond = "";

    Future<WeatherPoint> getCurrentWeather() async {

      var currentWeatherPoint = await APIManager().getWeatherPoint();
      Forecast forecast = await APIManager().getForecast(currentWeatherPoint);
      RelativeLocation? currentLocation = currentWeatherPoint.properties!.relativeLocation;
      Periods currentPeriod = forecast.properties!.periods![0];

      currentCity = currentLocation!.properties!.city;
      currentState = currentLocation!.properties!.state;
      currentTemp = currentPeriod.temperature;
      currentUnits = currentPeriod.temperatureUnit;
      currentCond = currentPeriod.shortForecast;

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
              ],
            );
          },
        ),
      ),
    );
  }
}