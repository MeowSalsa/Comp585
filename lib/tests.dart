// ignore_for_file: avoid_print

import 'dart:collection';

import 'api_manager.dart';

/* HashMap<String, WeatherPoint> locationMap = HashMap();
testWeatherPoint() async {
  final weatherPointAPIResult = await APIManager().getWeatherPoint();
  if (weatherPointAPIResult == null) {
    return;
    //Show an Error and refresh button?
  }
  testWeatherPointPrintouts(weatherPointAPIResult);
  locationMap[weatherPointAPIResult.properties?.gridId as String] =
      weatherPointAPIResult;
  print("Map length: ${locationMap.length}");
} */

/* void testWeatherPointPrintouts(WeatherPoint apiResult) {
  print(apiResult.id);
  print(apiResult.properties);
  var properties = apiResult.properties;
  print(properties?.gridId);
  print(properties?.gridX);
  print(properties?.gridY);
  print(properties?.relativeLocation?.properties?.city);
  print(properties?.relativeLocation?.properties?.state);
} */

/* testForecast() async {
  Forecast result;
  locationMap.forEach((key, value) async {
    result = await APIManager().getForecast(value);
    print("Forceast periods length ${result.properties?.periods?.length}");
  });
} */

/* void testHourlyForecast() async {
  HourlyForecast result;
  locationMap.forEach((key, value) async {
    result = await APIManager().getHourlyForecast(value);
    print(
        "Hourly Forecast Periods Length ${result.properties?.periods?.length}");
  });
} */

/* void testCoordsFromZip() async {
  String zip = "91340";
  Location? locationData;
  locationMap.forEach((key, value) async {
    locationData = await APIManager().getCoordinates(zip);
    if (locationData == null) {
      print("Error occured in HTTP request");
      print("Please try again");
    } else {
      print(
          "COORDINATES FROM ZIP $zip   ARE:${locationData?.latitude} , ${locationData?.longitude}");
    }
  });
} */

/* void testCoordsFromCityState() async {
  String cityState = "Berkeley California";
  Location? locationData;
  locationMap.forEach((key, value) async {
    locationData = await APIManager().getCoordinates(cityState);
    print(
        "COORDINATES FROM city,State $cityState   ARE:${locationData?.latitude} , ${locationData?.longitude}");
  });
}
 */