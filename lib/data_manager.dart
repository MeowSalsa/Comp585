import 'dart:collection';

import 'location_weather_data.dart';
import 'api_manager.dart';

enum ForecastType { now, hourly, daily, weekly }

class DataManager {
  final HashMap<String, LocationWeatherData> _recentSearches = HashMap();
  final HashMap<String, LocationWeatherData> _favoriteLocations = HashMap();

  dynamic getForecast(LocationWeatherData locationData, Enum forecastType) async {
    String locationString = locationData.searchInput!;
    switch (forecastType) {
      case ForecastType.now:
        //handlenow();
        break;
      case ForecastType.hourly:
        var hourlyForecast = _getHourlyForecast(locationString);
        return hourlyForecast;
      case ForecastType.daily:
        //handleDaily();
        break;
      case ForecastType.weekly:
        var forecast = _getWeeklyForecast(locationString);
        return forecast;
      default:
        print("Something went wrong in ForecastType switch");
    }
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
}
