import 'package:flutter/material.dart';

import 'local_time.dart';
import 'weather_icons.dart';

class MajorWeatherDisplay extends StatelessWidget {

  final String temperatureLabel;
  final String conditionLabel;
  final double? longitude;

  const MajorWeatherDisplay({
    super.key,
    required this.temperatureLabel,
    required this.conditionLabel,
    required this.longitude,
  });

  Widget getConditionIcon(String condition, double iconSize) {
    
    Widget sun = Padding(
      padding: EdgeInsets.only(top: iconSize / 3.0, bottom: iconSize / 3.0),
      child: Icon(
        WeatherIcons.sun,
        color: const Color(0xFFFFF386),
        size: iconSize,
      ),
    );

    Widget moon = Padding(
      padding: EdgeInsets.only(top: iconSize / 3.0, bottom: iconSize / 3.0),
      child: Icon(
        WeatherIcons.moon,
        color: Colors.white,
        size: iconSize * 0.8,
      )
    );

    Widget partlySun = Stack(
      children: [
        Icon(
          WeatherIcons.sun_partly,
          color: const Color(0xFFFFF386),
          size: iconSize * 1.4,
        ),
        Icon(
          WeatherIcons.cloud_partly,
          color: Colors.white,
          size: iconSize * 1.4,
        ),
      ],
    );

    Widget partlyMoon = Stack(
      children: [
        Icon(
          WeatherIcons.moon_partly,
          color: Colors.white,
          size: iconSize * 1.4,
        ),
        Icon(
          WeatherIcons.cloud_partly,
          color: Colors.white,
          size: iconSize * 1.4,
        ),
      ],
    );

    Widget cloudy = Padding(
      padding: EdgeInsets.all(iconSize / 4.0),
      child: Icon(
        WeatherIcons.cloud,
        color: Colors.white,
        size: iconSize,
      ),
    );

    Widget rainy = Padding(
      padding: EdgeInsets.all(iconSize / 4.0),
        child: Stack(
        children: [
          Icon(
            WeatherIcons.cloud_precipitation,
            color: Colors.white,
            size: iconSize,
          ),
          Icon(
            WeatherIcons.rain,
            color: const Color(0xFF60C0F6),
            size: iconSize,
          ),
        ],
      ),
    );

    Widget snowy = Padding(
      padding: EdgeInsets.all(iconSize / 4.0),
      child: Stack(
        children: [
          Icon(
            WeatherIcons.cloud_precipitation,
            color: Colors.white,
            size: iconSize,
          ),
          Icon(
            WeatherIcons.snow,
            color: Colors.white,
            size: iconSize,
          ),
        ],
      ),
    );

    switch(condition) {
      case String s when (s.contains("Cloudy") || s.contains("Fog")):
        if (s.contains("Partly"))
        {
          double dayPercent = LocalTime.getLocalDayPercent(longitude);
          if (dayPercent > 0.25 && dayPercent < 0.75)
          {
            return partlySun;
          }
          else
          {
            return partlyMoon;
          }
        }
        return cloudy;

      case String s when (s.contains("Rain") || s.contains("Showers")):
        if (s.contains("Chance") || s.contains("Likely"))
        {
          return cloudy;
        }
        return rainy;

      case String s when s.contains("Snow"):
        return snowy;

      case String s when s.contains("Clear"):
        return moon;

      default:
        return sun;
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // Condition icon
        Container(
          child: getConditionIcon(conditionLabel, screenWidth / 2.2),
        ),

        // Temperature
        Text(
          temperatureLabel,
          style: TextStyle(
            fontSize: screenWidth / 7.5,
          ),
        ),

        //Condition label
        Text(
          conditionLabel,
          style: TextStyle(
            fontSize: screenWidth / 22.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class MinorWeatherDisplay extends StatelessWidget {

  final String? titleText;
  final Widget displayWidget;

  const MinorWeatherDisplay({
    super.key,
    this.titleText,
    required this.displayWidget,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: EdgeInsets.all(screenWidth / 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          padding: EdgeInsets.all(screenWidth / 24.0),
          color: const Color(0x80E7E7E7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              FittedBox(
                fit: BoxFit.scaleDown,
                child:
                Text(
                  "$titleText",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: screenWidth / 22.5,
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: displayWidget,
                    ),
                  ]
                ),
              ),
            ]
          )
        ),
      ),
    );
  }
}

class WindDisplay extends StatelessWidget {
  
  final String? windSpeed;
  final String? windDirection;

  const WindDisplay({
    super.key,
    required this.windSpeed,
    required this.windDirection
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return MinorWeatherDisplay(
      titleText: "WIND", 
      displayWidget: Text(
        "$windSpeed $windDirection",
        style: TextStyle(
          fontSize: screenWidth / 22.5,
        ),
      ),
    );
  }
}

class PrecipitationDisplay extends StatelessWidget {
  
  final String? precipitationChance;

  const PrecipitationDisplay({
    super.key,
    required this.precipitationChance,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return MinorWeatherDisplay(
      titleText: "PRECIPITATION", 
      displayWidget: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: screenWidth / 48.0)),
          Icon(
            WeatherIcons.precipitation,
            color: Colors.white,
            size: screenWidth * (3.0 / 20.0),
          ),
          Padding(padding: EdgeInsets.only(top: screenWidth / 24.0)),
          Text(
            "$precipitationChance",
            style: TextStyle(
              fontSize: screenWidth / 22.5,
            ),
          ),
        ],
      ),
    );
  }
}

class HumidityDisplay extends StatelessWidget {
  
  final String? humidityPercent;

  const HumidityDisplay({
    super.key,
    required this.humidityPercent,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return MinorWeatherDisplay(
      titleText: "HUMIDITY", 
      displayWidget: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: screenWidth / 48.0)),
          Icon(
            WeatherIcons.humidity,
            color: Colors.white,
            size: screenWidth * (3.0 / 20.0),
          ),
          Padding(padding: EdgeInsets.only(top: screenWidth / 24.0)),
          Text(
            "$humidityPercent",
            style: TextStyle(
              fontSize: screenWidth / 22.5,
            ),
          ),
        ],
      ),
    );
  }
}