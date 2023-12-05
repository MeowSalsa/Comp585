import 'package:flutter/material.dart';

import 'api_manager.dart';
import 'data_manager.dart';
import 'colors.dart';
import 'local_time.dart';
import 'location_weather_data.dart';
import 'weather_displays.dart';
class CurrentWeatherDisplay extends StatelessWidget {

  final String locationString;
  final WeatherData weatherData = WeatherData();

  CurrentWeatherDisplay({
    super.key,
    required this.locationString,
  });

  @override
  Widget build(BuildContext context) {
    
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    weatherData.locationString = locationString;
    double bottomBarHeight = screenWidth / 10.0;

    return FutureBuilder(
      future: weatherData.getCurrentWeather(),
      builder: (context, snapshot) {

        if(snapshot.hasError){
          return const CircularProgressIndicator();
        }

        final TextTheme textTheme = Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        );

        final TimeBasedColorScheme colorScheme = TimeBasedColorScheme.colorSchemeFromLocalTime(LocalTime.getLocalDayPercent(weatherData.locationLongitude));

        return Theme(
          data: Theme.of(context).copyWith(textTheme: textTheme),
          child: Scaffold(
            
            body: Stack(
              children:[
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
                          tileMode: TileMode.clamp
                        ),
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
                                    height: screenHeight - bottomBarHeight,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: screenHeight / 50.0, top: screenHeight / 75.0),

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
                                        
                                        Container(
                                          color: colorScheme.mainBGColor,
                                          child: HourlyWeatherDisplay(hourlyForecasts: weatherData.futurePeriods, longitude: weatherData.locationLongitude),
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
                                              WindDisplay(windSpeed: weatherData.currentWindSpeed, windDirection: weatherData.currentWindDirection,),
                                              PrecipitationDisplay(precipitationChance: weatherData.currentPrecipitationChance,),
                                              HumidityDisplay(humidityPercent: weatherData.currentHumidity,),
                                              DewPointDisplay(dewPoint: weatherData.currentDewPoint,),
                                            ],
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: screenWidth / 18.0,
                            ),
                            Icon(
                              Icons.home,
                              color: Colors.white,
                              size: screenWidth / 18.0,
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
  List<HourlyPeriods>? futurePeriods;

  bool isFirstTimeLoad = true;

  Future<void> getCurrentWeather() async {

    if (!isFirstTimeLoad)
    {
      return;
    }

    DataManager newDM = DataManager();
    LocationWeatherData weatherLocation = await newDM.searchForLocation(locationString!);
    HourlyForecast forecast = await newDM.getForecast(weatherLocation, ForecastType.hourly);
    HourlyPeriods currentPeriod = forecast.properties!.periods![0];
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

  String? formatUnitValueString(int? value, String? unitCode)
  {
    String? displayString = "";

    if (value == null)
    {
      displayString += "0";
    }
    else
    {
      displayString += "$value";
    }
    
    if (unitCode!.contains("percent"))
    {
      displayString += "%";
    }
    else
    {
      displayString += unitCode;
    }

    return displayString;
  }
}