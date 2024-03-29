// ignore_for_file: avoid_print

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'location_weather_data.dart';
import 'api_manager.dart';
import 'package:path_provider/path_provider.dart';

enum ForecastType { now, hourly, daily, weekly }

class DataManager {
  static final HashMap<String, LocationWeatherData> _recentSearches = HashMap();
  static HashMap<String, LocationWeatherData> _favoriteLocations = HashMap();

  static dynamic getForecast(
      LocationWeatherData locationData, Enum forecastType) async {
    String locationString = locationData.searchInput!;
    switch (forecastType) {
      case ForecastType.now:
        var nowForecast = await _getNowForecast(locationString);
        return nowForecast;
      case ForecastType.hourly:
        var hourlyForecast = await _getHourlyForecast(locationString);
        return hourlyForecast;
      case ForecastType.daily:
        var dailyForecast = await _getDayForecast(locationString);
        return dailyForecast;
      case ForecastType.weekly:
        var forecast = await _getWeeklyForecast(locationString);
        return forecast;
      default:
        print("Something went wrong in ForecastType switch");
    }
  }

  static Future<Periods> _getNowForecast(String locationString) async {
    HourlyForecast hourlyForecast = await _getHourlyForecast(locationString);
    var nowForecast = hourlyForecast.properties?.periods?[0];
    print(nowForecast);
    return nowForecast!;
  }

  static Future<List<Periods>> _getDayForecast(String locationString) async {
    List<Periods> dailyForecast = List.empty(growable: true);
    var weeklyForecast = await _getWeeklyForecast(locationString);
    dailyForecast.add(weeklyForecast.properties!.periods![0]);
    dailyForecast.add(weeklyForecast.properties!.periods![1]);
    return dailyForecast;
  }

  static Future<Forecast> _getWeeklyForecast(String locationString) async {
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

  static Future<HourlyForecast> _getHourlyForecast(
      String locationString) async {
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

  static Future<Forecast> _retrieveForecastFromObject(
      LocationWeatherData locationData) async {
    var forecast = await weatherPointToForecast(locationData);
    return forecast;
  }

  static Future<HourlyForecast> _retrieveHourlyForecastFromObject(
      LocationWeatherData locationData) async {
    var hourlyForecast = await weatherPointToHourlyForecast(locationData);
    return hourlyForecast;
  }

  static Future<LocationWeatherData> searchForLocation(
      String stringInput) async {
    print("Entered 'SearchForLocation'");
    if (_recentSearches.containsKey(stringInput)) {
      print("Already in map, returning previous entry");
      return _recentSearches[stringInput]!;
    }
    LocationWeatherData newLocation =
        LocationWeatherData.defaultConstructor(stringInput);
    await initializeLocation(newLocation);
    _recentSearches[stringInput] = newLocation;
    return newLocation;
  }

  //API Call stuff below
  static Future<Forecast> weatherPointToForecast(
      LocationWeatherData locationData) async {
    if (locationData.forecast == null ||
        (DateTime.now().difference(locationData.forecastTimeStamp!) >
            const Duration(hours: 1))) {
      locationData.forecast =
          await APIManager().getForecast(locationData.weatherPointData!);
      locationData.forecastTimeStamp = DateTime.now();
    }
    return locationData.forecast!;
  }

  static Future<HourlyForecast> weatherPointToHourlyForecast(
      LocationWeatherData locationData) async {
    if (locationData.hourlyForecast == null ||
        (DateTime.now().difference(locationData.hourlyForecastTimeStamp!) >
            const Duration(hours: 1))) {
      locationData.hourlyForecast =
          await APIManager().getHourlyForecast(locationData.weatherPointData!);
      locationData.hourlyForecastTimeStamp = DateTime.now();
      locationData.nowForecast =
          locationData.hourlyForecast?.properties?.periods?.first;
    }
    return locationData.hourlyForecast!;
  }

  static Future<void> initializeLocation(
      LocationWeatherData locationData) async {
    CoordinatesFromLocation? locationCoordinateData;
    locationCoordinateData = await APIManager()
        .getCoordinatesFromLocation(locationData.searchInput!);
    if (locationCoordinateData != null) {
      //have to iterate through lists to find the proper data the below stuff
      locationData.location =
          locationCoordinateData.results?[0].geometry?.location as Location;
      createDisplayableString(locationCoordinateData, locationData);
      locationData.lat = locationData.location?.latitude;
      locationData.long = locationData.location?.longitude;
      //init weatherpoint
      locationData.weatherPointData =
          await APIManager().getWeatherPoint(locationData.location!);
    } else {
      print("Error at location initialization");
    }
  }

  static void createDisplayableString(CoordinatesFromLocation coordinateData,
      LocationWeatherData locationData) {
    var addressComponents = coordinateData.results?[0].addressComponents;
    for (var component in addressComponents!) {
      if (component.types?[0] == "postal_code") {
        locationData.zip = component.types?[0];
      } else if (component.types?[0] == "neighborhood") {
        locationData.displayableString = component.longName;
      } else if (component.types?[0] == "locality") {
        locationData.displayableString ??= component.longName;
      } else if (component.types?[0] == "administrative_area_level_1") {
        locationData.displayableString =
            (!locationData.displayableString!.contains(component.shortName!))
                ? "${locationData.displayableString!}, ${component.shortName!}"
                : locationData.displayableString;
      }
    }
  }

// File management stuff below
  static Future<String> get _localPath async {
    var dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    final directory = Directory('$path\\Weather_Application\\Data');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    //print("Path: ${directory.path.toString()}");
    return File('${directory.path}\\Favorites_data.json');
  }

  static Future<void> _saveFavoritesData(String jsonString) async {
    final file = await _localFile;
    print("Writing to disk on ${file.path}");
    file.writeAsString(jsonString);
  }

  static Future<String> _readFavoritesData() async {
    try {
      final file = await _localFile;
      print("Reading from disk on ${file.path}");
      // Read the file
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "Error reading file";
    }
  }

  /// Asynchronous function that reads the user's favorites locations and
  /// populates a _FavoriteLocations hashmap with the data.
  static Future<void> loadFavorites() async {
    print("Loading...");
    String fileContents = await _readFavoritesData();
    if (fileContents != "Error reading file") {
      if (fileContents.isNotEmpty) {
        var favoritesData = json.decode(fileContents);
        _favoriteLocations = HashMap.from(
            (favoritesData as Map<String, dynamic>).map((key, value) =>
                MapEntry(key, LocationWeatherData.fromJson(value))));
        await initializeFavoriteForecasts();
      }
    }
  }

  ///Initializes the hourlyForecasts that the Main Menu requires.
  static Future<void> initializeFavoriteForecasts() async {
    for (var value in _favoriteLocations.values) {
      print("Initializing Hourly Forecast for ${value.searchInput}");
      await _getHourlyForecast(value.searchInput!);
      await initializeLocation(value);
    }
  }

  /// Adds a LocationWeatherData object to the _FavoriteLocations hashmap, and asynchronously
  /// writes the new location to the favorite locations JSON file.
  static Future<void> addToFavorites(LocationWeatherData dataObj) async {
    _favoriteLocations[dataObj.searchInput!] = dataObj;
    String jsonString = favoritesToJson();
    await _saveFavoritesData(jsonString);
    if (dataObj.hourlyForecast == null) {
      await _getHourlyForecast(dataObj.searchInput!);
    }
  }

  static Future<void> removeFromFavorites(LocationWeatherData dataObj) async {
    if (_favoriteLocations.containsKey(dataObj.searchInput)) {
      _favoriteLocations.remove(dataObj.searchInput);
      String jsonString = favoritesToJson();
      await _saveFavoritesData(jsonString);
    }
  }

  static String favoritesToJson() {
    String data = "";
    data = json.encode(_favoriteLocations);
    return data;
  }

  /// Turns the _favoriteLocations hashmap into a list<LocationWeatherData> then returns it.
  static List<LocationWeatherData> getFavorites() {
    List<LocationWeatherData> favoritesList = List.empty(growable: true);
    _favoriteLocations.forEach((key, value) {
      favoritesList.add(value);
    });
    return favoritesList;
  }

  static Periods getNowForecast(LocationWeatherData currentLocation) {
    return currentLocation.nowForecast!;
  }
}
