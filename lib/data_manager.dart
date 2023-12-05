// ignore_for_file: avoid_print

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'location_weather_data.dart';
import 'api_manager.dart';
import 'package:path_provider/path_provider.dart';

enum ForecastType { now, hourly, daily, weekly }

class DataManager {
  final HashMap<String, LocationWeatherData> _recentSearches = HashMap();
  HashMap<String, LocationWeatherData> _favoriteLocations = HashMap();

  dynamic getForecast(
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
      LocationWeatherData locationData) async {
    var forecast = await weatherPointToForecast(locationData);
    return forecast;
  }

  Future<HourlyForecast> _retrieveHourlyForecastFromObject(
      LocationWeatherData locationData) async {
    var hourlyForecast = await weatherPointToHourlyForecast(locationData);
    return hourlyForecast;
  }

  Future<LocationWeatherData> searchForLocation(String stringInput) async {
    print("Entered 'SearchForLocation'");
    if (_recentSearches.containsKey(stringInput)) {
      print("Already in map, returning previous entry");
      return _recentSearches[stringInput]!;
    }
    LocationWeatherData newLocation =
        LocationWeatherData.defaultConstructor(stringInput);
    await initializeLocation();
    _recentSearches[stringInput] = newLocation;
    return newLocation;
  }

  //API Call stuff below
  Future<Forecast> weatherPointToForecast(
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

  Future<HourlyForecast> weatherPointToHourlyForecast(
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

  Future<void> initializeLocation(LocationWeatherData locationData) async {
    CoordinatesFromLocation? locationCoordinateData;
    locationCoordinateData = await APIManager()
        .getCoordinatesFromLocation(locationData.searchInput!);
    //if locationData ! null, perform bottom. add an else
    if (locationCoordinateData != null) {
      //have to iterate through lists to find the proper data the below stuff
      locationData.location =
          locationCoordinateData.results?[0].geometry?.location as Location;
      createDisplayableString(locationCoordinateData);
      locationData.lat = locationData.location?.latitude;
      locationData.long = locationData.location?.longitude;
      //init weatherpoint
      locationData.weatherPointData =
          await APIManager().getWeatherPoint(locationData.location!);
    } else {
      print("Error at location initialization");
    }
  }

  void createDisplayableString(CoordinatesFromLocation locationData) {
    var addressComponents = locationData.results?[0].addressComponents;
    for (var component in addressComponents!) {
      if (component.types?[0] == "postal_code") {
        zip = component.types?[0];
      } else if (component.types?[0] == "neighborhood") {
        displayableString ??= component.longName;
      } else if (component.types?[0] == "locality") {
        if (displayableString == null) {
          displayableString = component.longName;
        } else {
          displayableString = "${displayableString!}, ${component.longName!}";
        }
      } else if (component.types?[0] == "administrative_area_level_1") {
        displayableString = "${displayableString!}, ${component.longName!}";
      }
    }
  }

// File management stuff below
  Future<String> get _localPath async {
    var dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    final directory = Directory('$path\\Weather_Application\\Data');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    //print("Path: ${directory.path.toString()}");
    return File('${directory.path}\\Favorites_data.json');
  }

  Future<File> _saveFavoritesData(String jsonString) async {
    final file = await _localFile;
    print("Writing to disk on ${file.path}");
    return file.writeAsString(jsonString);
  }

  Future<String> _readFavoritesData() async {
    try {
      final file = await _localFile;
      print("Reading from disk on ${file.path}");

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "Error reading file";
    }
  }

  /// Asynchronous function that reads the user's favorites locations and
  /// populates a _FavoriteLocations hashmap with the data.
  Future<void> loadFavorites() async {
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
  Future<void> initializeFavoriteForecasts() async {
    for (var value in _favoriteLocations.values) {
      print("Initializing Hourly Forecast for ${value.searchInput}");
      await _getHourlyForecast(value.searchInput!);
    }
  }

  /// Adds a LocationWeatherData object to the _FavoriteLocations hashmap, and asynchronously
  /// writes the new location to the favorite locations JSON file.
  Future<void> addToFavorites(LocationWeatherData dataObj) async {
    _favoriteLocations[dataObj.searchInput!] = dataObj;
    String data = "";
    data = json.encode(_favoriteLocations);
    await _saveFavoritesData(data);
    if (dataObj.hourlyForecast == null) {
      await _getHourlyForecast(dataObj.searchInput!);
    }
  }

  /// Turns the _favoriteLocations hashmap into a list<LocationWeatherData> then returns it.
  List<LocationWeatherData> getFavorites() {
    List<LocationWeatherData> favoritesList = List.empty(growable: true);
    _favoriteLocations.forEach((key, value) {
      favoritesList.add(value);
    });
    return favoritesList;
  }

  HourlyPeriods getNowForecast(LocationWeatherData currentLocation) {
    return currentLocation.nowForecast!;
  }
}
