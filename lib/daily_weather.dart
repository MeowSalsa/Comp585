import 'package:flutter/material.dart';

import 'api_manager.dart';
import 'data_manager.dart';
import 'colors.dart';
import 'local_time.dart';
import 'location_weather_data.dart';
import 'weather_displays.dart';
import 'seven_day_forecast.dart';

class CurrentWeatherDisplay extends StatelessWidget {
  final String locationString;
  final WeatherData weatherData = WeatherData();

  CurrentWeatherDisplay({
    super.key,
    required this.locationString,
  });

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).viewPadding.top;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double bottomBarHeight = screenWidth / 10.0;

    weatherData.locationString = locationString;

    return FutureBuilder(
      future: weatherData.getCurrentWeather(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const CircularProgressIndicator();
        }

        final TextTheme textTheme = Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        );

        final TimeBasedColorScheme colorScheme =
          TimeBasedColorScheme.colorSchemeFromLocalTime(
            LocalTime.getLocalDayPercent(weatherData.locationLongitude)
          );

        return Theme(
          data: Theme.of(context).copyWith(textTheme: textTheme),
          child: Scaffold(
            body: Stack(
              children: [
                Container(
                  width: screenWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          colorScheme.skyStartColor,
                          colorScheme.skyEndColor,
                          colorScheme.skyEndColor,
                          colorScheme.mainBGColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.75, 0.76, 0.77],
                        tileMode: TileMode.clamp),
                  ),
                  child: Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: screenWidth,
                                height: screenHeight - bottomBarHeight - topPadding,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: screenHeight / 50.0,
                                        top: screenHeight / 75.0
                                      ),

                                      // Location Title
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              clipBehavior: Clip.hardEdge,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.arrow_back_ios_new_rounded,
                                                      color: Colors.white,
                                                      size: screenHeight / 32.0,
                                                    ),

                                                    Padding(padding: EdgeInsets.only(left: screenHeight / 53.0)),

                                                    Text(
                                                      "${weatherData.currentCity}",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: screenHeight / 35.0,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // MAJOR WEATHER DISPLAY
                                    MajorWeatherDisplay(
                                      temperatureLabel: "${weatherData.currentTemp}\u00B0${weatherData.currentUnits}",
                                      longitude: weatherData.locationLongitude,
                                      conditionLabel: "${weatherData.currentCond}",
                                    ),

                                    const Spacer(),

                                    Container(
                                      color: colorScheme.mainBGColor,
                                      child: HourlyWeatherDisplay(
                                          hourlyForecasts: weatherData.futurePeriods,
                                          longitude: weatherData.locationLongitude),
                                    ),
                                  ],
                                ),
                              ),

                              // MINOR WEATHER DISPLAYS
                              SizedBox(
                                width: screenWidth,
                                child: Container(
                                  color: colorScheme.mainBGColor,
                                  child: Column(
                                    children: [
                                      GridView(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 1, crossAxisCount: 2),
                                        children: [
                                          WindDisplay(
                                            windSpeed: weatherData.currentWindSpeed,
                                            windDirection: weatherData.currentWindDirection,
                                          ),
                                          PrecipitationDisplay(
                                            precipitationChance: weatherData.currentPrecipitationChance,
                                          ),
                                          HumidityDisplay(
                                            humidityPercent: weatherData.currentHumidity,
                                          ),
                                          DewPointDisplay(
                                            dewPoint: weatherData.currentDewPoint,
                                          ),
                                        ],
                                      ),

                                      NavigationButton(
                                        label: "Weekly Forecast",
                                        destinationWidget: ForecastPage(locationString: locationString),
                                      ),

                                      // Placeholder for buttons
                                      Padding(padding: EdgeInsets.only(top: bottomBarHeight)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Location Quick Switch (Bottom Bar)
                Positioned(
                  bottom: 0,
                  child: SizedBox(
                    height: bottomBarHeight,
                    width: screenWidth,
                    child: Container(
                      color: colorScheme.mainBGColor,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: screenWidth / 12.0,
                            color: colorScheme.mainBGColor,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth / 72.0),
                              child: Icon(
                                Icons.home,
                                color: Colors.white,
                                size: screenWidth / 18.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: bottomBarHeight,
                            width: screenWidth * 11.0 / 12.0,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Bottom BAR",
                                    style: TextStyle(
                                      fontSize: screenWidth / 20.0,
                                    ),
                                  ),
                                  Text(
                                    "Bottom BAR",
                                    style: TextStyle(
                                      fontSize: screenWidth / 20.0,
                                    ),
                                  ),
                                  Text(
                                    "Bottom BAR",
                                    style: TextStyle(
                                      fontSize: screenWidth / 20.0,
                                    ),
                                  ),
                                  Text(
                                    "Bottom BAR",
                                    style: TextStyle(
                                      fontSize: screenWidth / 20.0,
                                    ),
                                  ),
                                  Text(
                                    "Bottom BAR",
                                    style: TextStyle(
                                      fontSize: screenWidth / 20.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NavigationButton extends StatelessWidget {
  final String label;
  final Widget destinationWidget;

  const NavigationButton({
    super.key,
    required this.label,
    required this.destinationWidget,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => destinationWidget
          )
        );
      },

      child: Padding(
        padding: EdgeInsets.all(screenWidth / 21.3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenHeight / 30.0),
          child: Container(
            color: const Color(0x80E7E7E7),
            child: SizedBox(
              height: screenHeight / 15.0,
              child: Padding(
                padding: EdgeInsets.only(left: screenWidth / 21.3, right: screenWidth / 42.6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: screenHeight / 35.5,
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: screenHeight / 32.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WeatherData {
  String? locationString;

  WeatherData({
    this.locationString,
  });

  String? currentCity = "";
  int? currentTemp = 0;
  String? currentUnits = "";
  String? currentCond = "";
  String? currentWindSpeed = "";
  String? currentWindDirection = "";
  String? currentPrecipitationChance;
  String? currentHumidity;
  String? currentDewPoint;
  String? time;
  double? locationLongitude;
  List<Periods>? futurePeriods;

  bool isFirstTimeLoad = true;

  Future<void> getCurrentWeather() async {
    if (!isFirstTimeLoad) {
      return;
    }

    LocationWeatherData weatherLocation = await DataManager.searchForLocation(locationString!);
    HourlyForecast forecast = await DataManager.getForecast(weatherLocation, ForecastType.hourly);
    Periods currentPeriod = forecast.properties!.periods![0];
    ProbabilityOfPrecipitation? precipitation = currentPeriod.probabilityOfPrecipitation;
    ProbabilityOfPrecipitation? humidity = currentPeriod.relativeHumidity;
    Elevation? dewPoint = currentPeriod.dewpoint;

    currentCity = weatherLocation.displayableString;
    currentTemp = currentPeriod.temperature;
    currentUnits = currentPeriod.temperatureUnit;
    currentCond = currentPeriod.shortForecast;

    currentWindSpeed = currentPeriod.windSpeed;
    currentWindDirection = currentPeriod.windDirection;

    currentPrecipitationChance = formatUnitValueString(precipitation!.value, precipitation.unitCode);
    currentHumidity = formatUnitValueString(humidity!.value, humidity.unitCode);

    // Dew Point is in Celsius
    double dewPointValue = (dewPoint!.value!.toDouble() * 9.0) / 5.0 + 32.0;
    currentDewPoint = formatUnitValueString(dewPointValue.toInt(), "\u00B0F");

    locationLongitude = weatherLocation.long!;

    futurePeriods = forecast.properties!.periods!.sublist(1);

    isFirstTimeLoad = false;
  }

  String? formatUnitValueString(int? value, String? unitCode) {
    String? displayString = "";

    if (value == null) {
      displayString += "0";
    } else {
      displayString += "$value";
    }

    if (unitCode!.contains("percent")) {
      displayString += "%";
    } else {
      displayString += unitCode;
    }

    return displayString;
  }
}
