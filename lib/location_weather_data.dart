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
    locationToWeatherPoint(location);
  }

  void locationToWeatherPoint(String location) async {
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
        setCity(weatherPointData);
        state =
            weatherPointData.properties?.relativeLocation?.properties?.state;
      }
    }
  }

  void setCity(WeatherPoint weatherPointData) {
    city = weatherPointData.properties?.relativeLocation?.properties?.city;
  }
}
