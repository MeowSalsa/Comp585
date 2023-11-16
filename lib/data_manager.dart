import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'location_weather_data.dart';
import 'api_manager.dart';
import 'package:path_provider/path_provider.dart';

enum ForecastType { now, hourly, daily, weekly }

class DataManager {
  final HashMap<String, LocationWeatherData> _recentSearches = HashMap();
  final HashMap<String, LocationWeatherData> _favoriteLocations = HashMap();

  dynamic getForecast(
      LocationWeatherData locationData, Enum forecastType) async {
    String locationString = locationData.searchInput!;
    switch (forecastType) {
      case ForecastType.now:
        var nowForecast = _getNowForecast(locationString);
        return nowForecast;
      case ForecastType.hourly:
        var hourlyForecast = _getHourlyForecast(locationString);
        return hourlyForecast;
      case ForecastType.daily:
        var dailyForecast = _getDayForecast(locationString);
        return dailyForecast;
      case ForecastType.weekly:
        var forecast = _getWeeklyForecast(locationString);
        return forecast;
      default:
        print("Something went wrong in ForecastType switch");
    }
  }

  Future<HourlyPeriods> _getNowForecast(String locationString) async {
    HourlyForecast hourlyForecast = await _getHourlyForecast(locationString);
    var nowForecast = hourlyForecast.properties?.periods?[0];
    print(nowForecast);
    return nowForecast!;
  }

  Future<List<Periods>> _getDayForecast(String locationString) async {
    List<Periods> dailyForecast = List.empty(growable: true);
    var weeklyForecast = await _getWeeklyForecast(locationString);
    //var nowForecast = weeklyForecast.properties?.periods?[0];
    dailyForecast.add(weeklyForecast.properties!.periods![0]);
    dailyForecast.add(weeklyForecast.properties!.periods![1]);
    return dailyForecast;
  }

  Future<Forecast> _getWeeklyForecast(String locationString) async {
    //In neither map: search for location -> add it to recent map->retrieve forecast -> return forecast
    if (!_recentSearches.containsKey(locationString) &&
        !_favoriteLocations.containsKey(locationString)) {
      var locationObject = await searchForLocation(locationString);
      var forecast = await _retrieveForecastFromObject(locationObject);
      return forecast;
      // In recent map: retrieve locationObject -> check if locationObject.forecast is null -> retrieve it -> return it
    } else if (_recentSearches.containsKey(locationString) &&
        !_favoriteLocations.containsKey(locationString)) {
      //Exists in _recentSearches map
      var locationObject = _recentSearches[locationString]!;
      var forecast = await _retrieveForecastFromObject(locationObject);
      return forecast;
    }
    //in favorites map: retrieve value -> check if value.forecast is null -> retrieve it -> return it
    var locationObject = _favoriteLocations[locationString]!;
    var forecast = await _retrieveForecastFromObject(locationObject);
    return forecast;
  }

  Future<HourlyForecast> _getHourlyForecast(String locationString) async {
    //In neither map: search for location -> add it to recent map->retrieve forecast -> return forecast
    if (!_recentSearches.containsKey(locationString) &&
        !_favoriteLocations.containsKey(locationString)) {
      print("In neither Maps");
      var locationObject = await searchForLocation(locationString);
      var hourlyForecast =
          await _retrieveHourlyForecastFromObject(locationObject);
      return hourlyForecast;
      // In recent map: retrieve locationObject -> check if locationObject.forecast is null -> retrieve it -> return it
    } else if (_recentSearches.containsKey(locationString) &&
        !_favoriteLocations.containsKey(locationString)) {
      //Exists in _recentSearches map
      print("Already in map");
      var locationObject = _recentSearches[locationString]!;
      var hourlyForecast =
          await _retrieveHourlyForecastFromObject(locationObject);
      return hourlyForecast;
    }
    //in favorites map: retrieve value -> check if value.forecast is null -> retrieve it -> return it
    var locationObject = _favoriteLocations[locationString]!;
    var hourlyForecast =
        await _retrieveHourlyForecastFromObject(locationObject);
    return hourlyForecast;
  }

  Future<Forecast> _retrieveForecastFromObject(
      LocationWeatherData location) async {
    var forecast = await location.weatherPointToForecast();
    return forecast;
  }

  Future<HourlyForecast> _retrieveHourlyForecastFromObject(
      LocationWeatherData location) async {
    var hourlyForecast = await location.weatherPointToHourlyForecast();
    return hourlyForecast;
  }

  Future<LocationWeatherData> searchForLocation(String stringInput) async {
    print("Entered 'SearchForLocation'");
    if (_recentSearches.containsKey(stringInput)) {
      print("Already in map, returning previous entry");
      return _recentSearches[stringInput]!;
    }
    LocationWeatherData newLocation = LocationWeatherData(stringInput);
    await newLocation.initializeLocation();
    _recentSearches[stringInput] = newLocation;
    return newLocation;
  }

  Future<String> get _localPath async {
    var dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/Favorites_data.json');
  }

  Future<File> saveFavoritesData(String jsonString) async {
    //Map should go in ()
    final file = await _localFile;
    print("Writing to disk");
    return file.writeAsString(jsonString);
  }

  Future<String> readFavoritesData() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "Error reading file";
    }
  }

  Future<void> loadFavorites() async {
    String fileContents = await readFavoritesData();
    var favorites = json.decode(fileContents);
    print(favorites.toString());
  }

  void addToFavorites(LocationWeatherData dataObj) async {
    _favoriteLocations[dataObj.searchInput!] = dataObj;
    //serialize it
    String data =
        ""; /* 
    _favoriteLocations.forEach((key, value) {
      data += json.encode(value);
    }); */
    data = json.encode(_favoriteLocations);
    await saveFavoritesData(data);
    //save it to disk as string
  }
}
