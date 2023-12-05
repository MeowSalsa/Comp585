// ignore_for_file: avoid_print

import 'package:weather_app/api_manager.dart';

class LocationWeatherData {
  String? zip;
  WeatherPoint? weatherPointData;
  Forecast? forecast;
  HourlyForecast? hourlyForecast;
  HourlyPeriods? nowForecast;
  double? lat;
  double? long;
  Location? location;
  String? searchInput;
  String? displayableString;
  DateTime? hourlyForecastTimeStamp;
  DateTime? forecastTimeStamp;

  Map<String, dynamic> toJson() => {
        'weatherPointData': weatherPointData?.toJson(),
        'searchInput': searchInput,
        'displayableString': displayableString,
      };
  factory LocationWeatherData.fromJson(Map<String, dynamic> json) {
    return LocationWeatherData(
      weatherPointData: WeatherPoint.fromJson(json['weatherPointData']),
      searchInput: json['searchInput'],
      displayableString: json['displayableString'],
    );
  }
  LocationWeatherData.defaultConstructor(String location) {
    searchInput = location;
  }
  LocationWeatherData(
      {required this.weatherPointData,
      required this.searchInput,
      required this.displayableString});
}
