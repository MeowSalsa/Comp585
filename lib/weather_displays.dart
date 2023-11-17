import 'package:flutter/material.dart';

class MajorWeatherDisplay extends StatelessWidget {

  final String temperatureLabel;
  final String conditionLabel;

  const MajorWeatherDisplay({
    super.key,
    required this.temperatureLabel,
    required this.conditionLabel,
  });

  Icon getConditionIcon(String condition, double iconSize) {

    switch(condition) {
      case String s when s.contains("Cloudy"):
        return Icon(
          Icons.cloud_outlined,
          color: Colors.white,
          size: iconSize,
        );
      case String s when (s.contains("Rain") || s.contains("Showers")):
        if (s.contains("Chance"))
        {
          return Icon(
            Icons.cloud_outlined,
            color: Colors.white,
            size: iconSize,
          );
        }
        return Icon(
          Icons.cloudy_snowing,
          color: Colors.white,
          size: iconSize,
        );
      case String s when s.contains("Snow"):
        return Icon(
          Icons.ac_unit,
          color: Colors.white,
          size: iconSize,
        );
      default:
        return Icon(
          Icons.wb_sunny_outlined,
          color: const Color(0xFFFFF386),
          size: iconSize,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // Condition icon
        Container(
          padding: EdgeInsets.all(screenWidth / 36.0),
          child: getConditionIcon(conditionLabel, screenWidth / 2.0)
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
            Icons.snowing,
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
            Icons.wind_power,
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