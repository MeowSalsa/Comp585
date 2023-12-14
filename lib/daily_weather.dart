import 'package:flutter/material.dart';

import 'api_manager.dart';
import 'data_manager.dart';
import 'local_time.dart';
import 'colors.dart';
import 'buttons.dart';
import 'location_weather_data.dart';
import 'weather_displays.dart';
import 'seven_day_forecast.dart';
import 'radar_page.dart';

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
      future: weatherData.loadPageData(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
        {
          return Container(
            color: Colors.white,
            child: SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: Center(
                child: Column(
                  children: [
                    Text("${snapshot.error}"),
                    BackButton(
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting || weatherData.currentCity == null) {
          return Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator()
            ),
          );
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
                                    // Location Title
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: screenHeight / 50.0,
                                        right: screenHeight / 50.0,
                                        top: screenHeight / 75.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                                          FavoriteButton(
                                            addTarget: weatherData.searchInput!,
                                            initialState: (weatherData.isInFavorites) ? FavButtonStates.readyToRemove : FavButtonStates.readyToAdd,
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
                                        destinationWidget: ForecastPage(locationString: weatherData.currentCity!),
                                      ),

                                      NavigationButton(
                                        label: "Weather Radar",
                                        destinationWidget: Radar(
                                          locationString: weatherData.currentCity!,
                                          locationLongitude: weatherData.locationLongitude,
                                        ),
                                      ),
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

                          // Home Button
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
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
                          ),

                          SizedBox(
                            height: bottomBarHeight,
                            width: screenWidth * 11.0 / 12.0,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: weatherData.favoriteLocationNames.length,
                                itemBuilder:(context, index) {
                                  String currentFavorite = weatherData.favoriteLocationNames[index];
                                  String currentSearch = weatherData.favoriteLocationSearches[index];
                                  bool isViewingFavorite = locationString.contains(currentSearch);
                                  return Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (isViewingFavorite) {
                                            return;
                                          }
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context, 
                                            MaterialPageRoute(
                                              builder: (context) => CurrentWeatherDisplay(
                                                locationString: currentSearch
                                              ),
                                            )
                                          );
                                        },
                                        child: Text(
                                          currentFavorite,
                                          style: TextStyle(
                                            fontSize: screenWidth / 20.0,
                                            fontWeight: (isViewingFavorite) 
                                            ? FontWeight.bold
                                            : null
                                          ),
                                        ),
                                      ),

                                      //Funky way of doing
                                      // if (index < itemCount)
                                      //   return VerticalDivider()
                                      // else
                                      //   return Padding()
                                      (index >= weatherData.favoriteLocationNames.length - 1)
                                      ? Padding(padding: EdgeInsets.only(right: screenWidth / 36.0))
                                      : VerticalDivider(
                                        thickness: 2,
                                        color: Colors.white,
                                        indent: screenWidth / 36.0,
                                        endIndent: screenWidth / 36.0,
                                      ),
                                    ],
                                  );
                                },
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

class WeatherData {
  String? locationString;

  WeatherData({
    this.locationString,
  });

  String? currentCity;
  String? searchInput;
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
  List<String> favoriteLocationNames = [];
  List<String> favoriteLocationSearches = [];
  bool isInFavorites = false;

  bool isFirstTimeLoad = true;

  Future<void> loadPageData() async {
    if (!isFirstTimeLoad) {
      return;
    }

    await getCurrentWeather();
    await getFavoritesData();
    
    isFirstTimeLoad = false;
  }

  Future<void> getCurrentWeather() async {

    // Get Weather Data from DataManager
    LocationWeatherData weatherLocation = await DataManager.searchForLocation(locationString!);
    HourlyForecast forecast = await DataManager.getForecast(weatherLocation, ForecastType.hourly);
    Periods currentPeriod = forecast.properties!.periods![0];

    // Pieces of data that need to be formatted later
    ProbabilityOfPrecipitation? precipitation = currentPeriod.probabilityOfPrecipitation;
    ProbabilityOfPrecipitation? humidity = currentPeriod.relativeHumidity;
    Elevation? dewPoint = currentPeriod.dewpoint;

    // Storing all the needed information
    currentCity = weatherLocation.displayableString;
    searchInput = weatherLocation.searchInput;
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
  }

  Future<void> getFavoritesData() async {
    favoriteLocationNames = [];
    for (var favorite in DataManager.getFavorites()) {
      String favName = favorite.displayableString!;
      favoriteLocationNames.add(favName.substring(0, favName.indexOf(",")));

      String favSearch = favorite.searchInput!;
      favoriteLocationSearches.add(favSearch);
    }

    for (String fav in favoriteLocationSearches) {
      if (locationString!.contains(fav)) {
        isInFavorites = true;
        break;
      }
    }
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
