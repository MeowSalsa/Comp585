import 'package:flutter/material.dart';

import 'api_manager.dart';

class CurrentWeatherDisplay extends StatelessWidget {

  getWeatherPeriods() async {
    final weatherPoint = await APIManager().getWeatherPoint();

    Forecast forecast = await APIManager().getForecast(weatherPoint);

    List<Periods>? weatherPeriods = forecast.properties?.periods;
    return weatherPeriods;

    //for (int i = 0; i < weatherPeriods!.length; i++)
    //{
    //  currentTemp = weatherPeriods![0].temperature;
    //  String? currentStartTime = weatherPeriods[0].startTime;
    //  currentDate = DateTime.parse(currentStartTime!).toLocal();
    //}
  }

  @override
  Widget build(BuildContext context) {

    int? currentTemp = 0;
    DateTime currentDate = DateTime.now();

    Future<List<Periods>> getCurrentWeather() async {
      var currentWeatherPeriods = await getWeatherPeriods();

      for (int i = 0; i < currentWeatherPeriods!.length; i++)
      {
        currentTemp = currentWeatherPeriods![i].temperature;
        String? currentStartTime = currentWeatherPeriods[i].startTime;
        currentDate = DateTime.parse(currentStartTime!).toLocal();

        print("$currentDate: $currentTemp");
      }

      currentTemp = currentWeatherPeriods![0].temperature;
      String? currentStartTime = currentWeatherPeriods[0].startTime;
      currentDate = DateTime.parse(currentStartTime!).toLocal();

      return currentWeatherPeriods;
    }
    
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: getCurrentWeather(),
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return const CircularProgressIndicator();
            }
            return Text("$currentDate: $currentTemp");
          },
        ),
      ),
    );
  }
}