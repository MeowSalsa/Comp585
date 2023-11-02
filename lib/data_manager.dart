import 'location_weather_data.dart';
import 'api_manager.dart';

class DataManager {
  static void getForecast(LocationWeatherData locationData) async {
    print("Current weatherpoint  ${locationData.weatherPointData}");
    await locationData.weatherPointToForecast();
    //return locationData;
  }

  static void getHourlyForecast(LocationWeatherData locationData) async {
    print("Current weatherpoint  ${locationData.weatherPointData}");
    await locationData.weatherPointToHourlyForecast();
    //return locationData;
  }
}
