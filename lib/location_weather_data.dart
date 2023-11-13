// ignore_for_file: avoid_print

import 'package:weather_app/api_manager.dart';

class LocationWeatherData {
  String? zip;
  WeatherPoint? weatherPointData;
  Forecast? forecast;
  HourlyForecast? hourlyForecast;
  double? lat;
  double? long;
  Location? location;
  String? searchInput;
  String? displayableString;
  DateTime? hourlyForecastTimeStamp;
  DateTime? forecastTimeStamp;

  LocationWeatherData(String location) {
    searchInput = location;
  }

  Future<Forecast> weatherPointToForecast() async {
    if (forecast == null ||
        (DateTime.now().difference(forecastTimeStamp!) >
            const Duration(hours: 1))) {
      forecast = await APIManager().getForecast(weatherPointData!);
      forecastTimeStamp = DateTime.now();
    }
    return forecast!;
  }

  Future<HourlyForecast> weatherPointToHourlyForecast() async {
    if (hourlyForecast == null ||
        (DateTime.now().difference(hourlyForecastTimeStamp!) >
            const Duration(hours: 1))) {
      hourlyForecast = await APIManager().getHourlyForecast(weatherPointData!);
      hourlyForecastTimeStamp = DateTime.now();
    }
    return hourlyForecast!;
  }

  Future<void> initializeLocation() async {
    CoordinatesFromLocation? locationData;
    locationData = await APIManager().getCoordinatesFromLocation(searchInput!);
    //if locationData ! null, perform bottom. add an else
    if (locationData != null) {
      //have to iterate through lists to find the proper data the below stuff
      location = locationData.results?[0].geometry?.location as Location;
      createDisplayableString(locationData);
      lat = location?.latitude;
      long = location?.longitude;
      //init weatherpoint
      weatherPointData = await APIManager().getWeatherPoint(location!);
    } else {
      print("Error at location initialization in Data Manager");
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
}
