// ignore_for_file: avoid_print

import 'package:weather_app/api_manager.dart';

class LocationWeatherData {
  String? city;
  String? state;
  String? zip;
  WeatherPoint? weatherPointData;
  Forecast? forecast;
  HourlyForecast? hourlyForecast;

  LocationWeatherData(String location) {
    print("Creating new location");
    locationToWeatherPoint(location);
  }

  void locationToWeatherPoint(String location) async {
    Location? locationData;
    locationData = await APIManager().getCoordinates("91340");
    if (locationData == null) {
      print("Geolocation Error. Try again.");
    } else {
      //WeatherPoint? weatherPointData;
      weatherPointData = await APIManager().getWeatherPoint(locationData);
      //weatherPoint = weatherPointData;
      if (weatherPointData == null) {
        print("weather point data error");
      } else {
        _setCity(weatherPointData);
        _setState(weatherPointData);
      }
    }
  }

  Future<Forecast> weatherPointToForecast() async {
    Forecast? newForecast;
    //print("Continue or wait?");
    newForecast = await APIManager().getForecast(weatherPointData!);
    //print("Does this continue or wait?");
    forecast = newForecast;
    return newForecast;
  }

  Future<HourlyForecast> weatherPointToHourlyForecast() async {
    HourlyForecast? newHourlyForecast;
    newHourlyForecast = await APIManager().getHourlyForecast(weatherPointData!);
    hourlyForecast = newHourlyForecast;
    return newHourlyForecast;
  }

  void _setCity(WeatherPoint? weatherPointData) {
    city = weatherPointData?.properties?.relativeLocation?.properties?.city;
  }

  void _setState(WeatherPoint? weatherPointData) {
    state = weatherPointData?.properties?.relativeLocation?.properties?.state;
  }
  /*  Future<Forecast?> getForecast() async {
    print("Current weatherpoint  $weatherPointData");
    if (forecast == null) {
      Forecast? newForecast = await weatherPointToForecast(weatherPointData);
      forecast = newForecast;
      return forecast;
    }
    return forecast;
  } */
}
