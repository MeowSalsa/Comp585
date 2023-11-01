import 'package:weather_app/api_manager.dart';

class LocationWeatherData {
  String? city;
  String? state;
  String? zip;
  WeatherPoint? weatherPoint;
  Forecast? forecast;
  HourlyForecast? hourlyForecast;

  LocationWeatherData(String location) {
    print("Creating new location");
    _locationToWeatherPoint(location);
  }

  void _locationToWeatherPoint(String location) async {
    Location? locationData;
    locationData = await APIManager().getCoordinates("91340");
    if (locationData == null) {
      print("Geolocation Error. Try again.");
    } else {
      WeatherPoint? weatherPointData;
      weatherPointData = await APIManager().getWeatherPoint(locationData);
      if (weatherPointData == null) {
        print("weather point data error");
      } else {
        _setCity(weatherPointData);
        state =
            weatherPointData.properties?.relativeLocation?.properties?.state;
      }
    }
  }

  void _weatherPointToForecast(WeatherPoint weatherPoint) async {
    Forecast? newForecast;
    newForecast = await APIManager().getForecast(weatherPoint);
    if (newForecast == null) {
      print("Error with Forecast call");
    } else {
      forecast = newForecast;
    }
  }

  void _weatherPointToHourlyForecast(WeatherPoint weatherPoint) async {
    HourlyForecast? newHourlyForecast;
    newHourlyForecast = await APIManager().getHourlyForecast(weatherPoint);
    if (newHourlyForecast == null) {
      print("Error with Forecast call");
    } else {
      hourlyForecast = newHourlyForecast;
    }
  }

  void _setCity(WeatherPoint weatherPointData) {
    city = weatherPointData.properties?.relativeLocation?.properties?.city;
  }

  Forecast? getForecast() async {
    if (forecast == null) {
      await _weatherPointToForecast(weatherPoint!);
      return forecast;
    }
    return forecast;
  }
}
