import 'dart:math';

import 'package:flutter/material.dart';

import 'api_manager.dart';
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

  static Widget getConditionIcon(
      String condition, double iconSize, DateTime time, double? longitude) {
    Widget sun = Padding(
      padding: EdgeInsets.all(iconSize / 4.0),
      child: Icon(
        WeatherIcons.sun,
        color: const Color(0xFFFFF386),
        size: iconSize,
      ),
    );

    Widget moon = Padding(
        padding: EdgeInsets.all(iconSize / 2.9),
        child: Icon(
          WeatherIcons.moon,
          color: Colors.white,
          size: iconSize * 0.8,
        ));

    Widget partlySun = Padding(
      padding: EdgeInsets.symmetric(vertical: iconSize / 20.0),
      child: Stack(
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
      ),
    );

    Widget partlyMoon = Padding(
      padding: EdgeInsets.symmetric(vertical: iconSize / 20.0),
      child: Stack(
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
      ),
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

    switch (condition) {
      case String s when (s.contains("Partly") || s.contains("Mostly")):
        double dayPercent = LocalTime.getDayPercent(time);
        if (dayPercent > 0.25 && dayPercent < 0.75) {
          return partlySun;
        } else {
          return partlyMoon;
        }

      case String s when (s.contains("Cloudy") || s.contains("Fog")):
        return cloudy;

      case String s when (s.contains("Rain") || s.contains("Showers")):
        if (s.contains("Chance") || s.contains("Likely")) {
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
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Condition icon
        Container(
          child: getConditionIcon(
              conditionLabel, screenHeight / 3.8, DateTime.now(), longitude),
        ),

        // Temperature
        Text(
          temperatureLabel,
          style: TextStyle(
            fontSize: screenHeight / 13.3,
          ),
        ),

        //Condition label
        Text(
          conditionLabel,
          style: TextStyle(
            fontSize: screenHeight / 40,
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
        borderRadius: BorderRadius.circular(screenWidth / 18.0),
        child: Container(
            padding: EdgeInsets.all(screenWidth / 24.0),
            color: const Color(0x80E7E7E7),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
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
                        ]),
                  ),
                ])),
      ),
    );
  }
}

class WindDisplay extends StatelessWidget {
  final String? windSpeed;
  final String? windDirection;

  const WindDisplay(
      {super.key, required this.windSpeed, required this.windDirection});

  double directionToRotation(String dir) {
    double rotation = 0;

    double rotationInfluence = 90.0;
    for (int i = 0; i < dir.length; i++) {
      double correctRotInf;
      switch (dir.substring(i, i + 1)) {
        case 'N':
          correctRotInf = (i > 0)
              ? correctRotationInfluence(0, rotation, rotationInfluence)
              : 0;
          rotation +=
              (((rotation + correctRotInf) - 0).abs() < (rotation - 0).abs())
                  ? correctRotInf
                  : 0.0;
          break;
        case 'E':
          correctRotInf = (i > 0)
              ? correctRotationInfluence(90, rotation, rotationInfluence)
              : 90;
          rotation +=
              (((rotation + correctRotInf) - 90).abs() < (rotation - 90).abs())
                  ? correctRotInf
                  : 0.0;
          break;
        case 'S':
          // check if current angle is closer to +180 than -180
          int targetRot = 180;
          if (rotation >= 0) {
            // make influence move closer to +180 if positive
            correctRotInf = (i > 0)
                ? correctRotationInfluence(180, rotation, rotationInfluence)
                : 180;
          } else {
            // make influence move closer to -180 if negative
            targetRot = -180;
            correctRotInf = (i > 0)
                ? correctRotationInfluence(-180, rotation, rotationInfluence)
                : -180;
          }
          rotation += (((rotation + correctRotInf) - targetRot).abs() <
                  (rotation - targetRot).abs())
              ? correctRotInf
              : 0.0;
          break;
        case 'W':
          if (rotation > 0) {
            rotation = -rotation;
          }
          correctRotInf = (i > 0)
              ? correctRotationInfluence(-90, rotation, rotationInfluence)
              : -90;
          rotation +=
              (((rotation + correctRotInf) + 90).abs() < (rotation + 90).abs())
                  ? correctRotInf
                  : 0.0;
          break;
      }

      rotationInfluence /= 2.0;
    }

    return rotation;
  }

  double correctRotationInfluence(
      double targetRot, double currentRot, double rotInf) {
    return (currentRot < targetRot) ? rotInf : -rotInf;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double compassSize = screenWidth / 4;
    double needleAngle = (windDirection != null)
        ? directionToRotation(windDirection!) * (pi / 180)
        : 0;

    String windSpeedValue = (windSpeed != null && windSpeed!.length > 3)
        ? windSpeed!.substring(0, windSpeed!.indexOf(" "))
        : "";
    String windSpeedUnit = (windSpeed != null)
        ? windSpeed!.substring(windSpeed!.indexOf(" ") + 1)
        : "";

    return MinorWeatherDisplay(
      titleText: "WIND",
      displayWidget: Center(
        child: Stack(
          children: [
            SizedBox(
              width: compassSize,
              height: compassSize,
              child: Icon(
                Icons.brightness_1_outlined,
                color: Colors.white,
                size: compassSize,
              ),
            ),
            Transform.rotate(
              angle: needleAngle,
              child: SizedBox(
                width: compassSize,
                height: compassSize,
                child: Center(
                  child: Icon(
                    Icons.north,
                    color: Colors.red,
                    size: compassSize,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: compassSize,
              height: compassSize,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      windSpeedValue,
                      style: TextStyle(
                        fontSize: screenWidth / 22.5,
                      ),
                    ),
                    Text(
                      windSpeedUnit,
                      style: TextStyle(
                        fontSize: screenWidth / 22.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          Padding(padding: EdgeInsets.only(top: screenWidth / 28.0)),
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
          Padding(padding: EdgeInsets.only(top: screenWidth / 28.0)),
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

class DewPointDisplay extends StatelessWidget {
  final String? dewPoint;

  const DewPointDisplay({
    super.key,
    required this.dewPoint,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return MinorWeatherDisplay(
      titleText: "DEW POINT",
      displayWidget: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: screenWidth / 48.0)),
          Icon(
            WeatherIcons.dew_point,
            color: Colors.white,
            size: screenWidth * (3.0 / 20.0),
          ),
          Padding(padding: EdgeInsets.only(top: screenWidth / 28.0)),
          Text(
            "$dewPoint",
            style: TextStyle(
              fontSize: screenWidth / 22.5,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniWeatherDisplay extends StatelessWidget {
  final Widget? topLabel;
  final String? conditionString;
  final Widget? bottomLabel;
  final double iconSize;
  final DateTime time;
  final double? longitude;

  const MiniWeatherDisplay(
      {super.key,
      required this.topLabel,
      required this.conditionString,
      required this.bottomLabel,
      required this.iconSize,
      required this.time,
      required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        topLabel ?? const Spacer(),
        MajorWeatherDisplay.getConditionIcon(
            conditionString!, iconSize, time, longitude),
        bottomLabel ?? const Spacer(),
      ],
    );
  }
}

class HourlyWeatherDisplay extends StatelessWidget {
  final List<Periods>? hourlyForecasts;
  final double? longitude;

  const HourlyWeatherDisplay({
    super.key,
    required this.hourlyForecasts,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.fromLTRB(screenHeight / 42.6, screenHeight / 68,
          screenHeight / 42.6, screenHeight / 42.6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Hourly Weather",
                style: TextStyle(
                  fontSize: screenHeight / 35.6,
                ),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: screenHeight / 64.0)),
          SizedBox(
            height: screenHeight / 7.2,
            width: screenWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenHeight / 32.0),
              child: (hourlyForecasts == null) ? null : Container(
                color: const Color(0x80E7E7E7),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth / 36.0),
                  child: Center(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: 24,
                      itemBuilder:(context, index) {

                        DateTime currentTime = LocalTime.toLocalTime(DateTime.parse(hourlyForecasts![index].startTime!), longitude);

                        int currentHour = currentTime.hour;
                        String ampm = "AM";
                        if (currentHour >= 12)
                        {
                          ampm = "PM";
                          if (currentHour > 12)
                          {
                            currentHour -= 12;
                          }
                        }
                        if (currentHour == 0)
                        {
                          currentHour = 12;
                        }

                        double leftPadding = (index != 0) ? screenWidth / 72.0 : 0.0;
                        double rightPadding = (index != 23) ? screenWidth / 72.0 : 0.0;

                        return Padding(
                          padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
                          child: MiniWeatherDisplay(
                            topLabel: Text(
                              "$currentHour$ampm",
                              style: TextStyle(
                                fontSize: screenHeight / 53.3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            bottomLabel: Text(
                              "${hourlyForecasts![index].temperature}\u00B0${hourlyForecasts![index].temperatureUnit}",
                              style: TextStyle(
                                fontSize: screenHeight / 64.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            conditionString: hourlyForecasts![index].shortForecast,
                            time: currentTime,
                            iconSize: min(screenWidth / 7.2, screenHeight / 20.0),
                            longitude: longitude
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
