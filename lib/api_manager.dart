import 'dart:convert';

import 'package:http/http.dart' as http;
/* Additionally, in your AndroidManifest.xml file, add the Internet permission.
    <!-- Required to fetch data from the internet. -->
    <uses-permission android:name="android.permission.INTERNET" /> */

/* class WeatherPoint {
  //final String gridId;
  final String gridX;
  final String gridY;
  final String forecast;
  final String forecastHourly;
  final String city;
  final String state;

  const WeatherPoint(
      { //required this.gridId,
      required this.gridX,
      required this.gridY,
      required this.forecast,
      required this.forecastHourly,
      required this.city,
      required this.state});

  factory WeatherPoint.fromJSon(Map<String, dynamic> json) {
    return WeatherPoint(
        // gridId: json['gridId'],
        gridX: json['gridX'],
        gridY: json['gridY'],
        forecast: json['forecast'],
        forecastHourly: json['forecastHourly'],
        city: json['city'],
        state: json['state']);
  }
} */
class WeatherPoint {
  String? id;
  Properties? properties;

  WeatherPoint({this.id, this.properties});

  WeatherPoint.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    properties = json['properties'] != null
        ? Properties.fromJson(json['properties'])
        : null;
  }

/*   Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    if (properties != null) {
      data['properties'] = properties!.toJson();
    }
    return data;
  } */
}

class Properties {
  String? id;
  String? type;
  String? gridId;
  int? gridX;
  int? gridY;
  String? forecast;
  String? forecastHourly;
  RelativeLocation? relativeLocation;
  String? radarStation;

  Properties(
      {this.id,
      this.type,
      this.gridId,
      this.gridX,
      this.gridY,
      this.forecast,
      this.forecastHourly,
      this.relativeLocation,
      this.radarStation});

  Properties.fromJson(Map<String, dynamic> json) {
    id = json['@id'];
    type = json['@type'];
    gridId = json['gridId'];
    gridX = json['gridX'];
    gridY = json['gridY'];
    forecast = json['forecast'];
    forecastHourly = json['forecastHourly'];
    relativeLocation = json['relativeLocation'] != null
        ? RelativeLocation.fromJson(json['relativeLocation'])
        : null;
    radarStation = json['radarStation'];
  }
//Might need this section for saving user's favorited locations.
  /*  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@id'] = this.id;
    data['@type'] = this.type;
    data['gridId'] = this.gridId;
    data['gridX'] = this.gridX;
    data['gridY'] = this.gridY;
    data['forecast'] = this.forecast;
    data['forecastHourly'] = this.forecastHourly;
    if (this.relativeLocation != null) {
      data['relativeLocation'] = this.relativeLocation!.toJson();
    }
    data['radarStation'] = this.radarStation;
    return data;
  } */
}

class RelativeLocation {
  LocationProperties? properties;

  RelativeLocation({this.properties});

  RelativeLocation.fromJson(Map<String, dynamic> json) {
    properties = json['properties'] != null
        ? LocationProperties.fromJson(json['properties'])
        : null;
  }
}

class LocationProperties {
  String? city;
  String? state;

  LocationProperties({this.city, this.state});

  LocationProperties.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    state = json['state'];
  }
}

class APIManager {
  //Debugging: Coordinates for CSUN.
  final String testLat = "34.2406756";
  final String testLong = "-118.5325945";

  Future<WeatherPoint> getWeatherPoint() async {
    final response = await http
        .get(Uri.parse('https://api.weather.gov/points/$testLat,$testLong'));

    if (response.statusCode == 200) {
      print("All good in HTTP call");
      final data = jsonDecode(response.body);
      print(data);
      final newWeatherPoint = WeatherPoint.fromJson(data);
      return newWeatherPoint;
    } else {
      throw Exception('HTTP Failed');
    }
  }
}
