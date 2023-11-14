import 'package:flutter/material.dart';

class MinorWeatherDisplay extends StatelessWidget {

  final String? titleText;
  final String? displayText;

  const MinorWeatherDisplay({
    super.key,
    this.titleText,
    this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          padding: const EdgeInsets.all(15.0),
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
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "$displayText"
                      ),
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
    return MinorWeatherDisplay(titleText: "WIND", displayText: "$windSpeed $windDirection",);
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
    return MinorWeatherDisplay(titleText: "PRECIPITATION", displayText: "$precipitationChance",);
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
    return MinorWeatherDisplay(titleText: "HUMIDITY", displayText: "$humidityPercent",);
  }
}