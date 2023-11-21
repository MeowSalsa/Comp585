// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;
/* Additionally, in your AndroidManifest.xml file, add the Internet permission.
    <!-- Required to fetch data from the internet. -->
    <uses-permission android:name="android.permission.INTERNET" /> */

///
/// API DOCUMENTATION: https://www.weather.gov/documentation/services-web-api#/
/// We are using the GeoJson format so if you try to look up the data in the
///  API documentation look for "GridpointForecastGeoJson"
///
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (properties != null) {
      data['properties'] = properties!.toJson();
    }
    return data;
  }
}

class Properties {
  String? id;
  String? gridId;
  int? gridX;
  int? gridY;
  RelativeLocation? relativeLocation;

  Properties(
      {this.id, this.gridId, this.gridX, this.gridY, this.relativeLocation});

  Properties.fromJson(Map<String, dynamic> json) {
    id = json['@id'];
    gridId = json['gridId'];
    gridX = json['gridX'];
    gridY = json['gridY'];
    relativeLocation = json['relativeLocation'] != null
        ? RelativeLocation.fromJson(json['relativeLocation'])
        : null;
  }
//Might need this section for saving user's favorited locations.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['@id'] = id;
    data['gridId'] = gridId;
    data['gridX'] = gridX;
    data['gridY'] = gridY;
    return data;
  }
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

class Forecast {
  ForecastProperties? properties;

  Forecast({this.properties});

  Forecast.fromJson(Map<String, dynamic> json) {
    properties = json['properties'] != null
        ? ForecastProperties.fromJson(json['properties'])
        : null;
  }
}

class ForecastProperties {
  String? updated;
  String? units;
  String? forecastGenerator;
  String? generatedAt;
  String? updateTime;
  String? validTimes;
  Elevation? elevation;
  List<Periods>? periods;

  ForecastProperties(
      {this.updated,
      this.units,
      this.forecastGenerator,
      this.generatedAt,
      this.updateTime,
      this.validTimes,
      this.elevation,
      this.periods});

  ForecastProperties.fromJson(Map<String, dynamic> json) {
    updated = json['updated'];
    units = json['units'];
    forecastGenerator = json['forecastGenerator'];
    generatedAt = json['generatedAt'];
    updateTime = json['updateTime'];
    validTimes = json['validTimes'];
    elevation = json['elevation'] != null
        ? Elevation.fromJson(json['elevation'])
        : null;
    if (json['periods'] != null) {
      periods = <Periods>[];
      json['periods'].forEach((v) {
        periods!.add(Periods.fromJson(v));
      });
    }
  }
}

class Elevation {
  String? unitCode;
  num? value;

  Elevation({this.unitCode, this.value});

  Elevation.fromJson(Map<String, dynamic> json) {
    unitCode = json['unitCode'];
    value = json['value'];
  }
}

class Periods {
  int? number;
  String? name;
  String? startTime;
  String? endTime;
  bool? isDaytime;
  int? temperature;
  String? temperatureUnit;
  ProbabilityOfPrecipitation? probabilityOfPrecipitation;
  ProbabilityOfPrecipitation? relativeHumidity;
  Elevation? dewpoint;
  String? windSpeed;
  String? windDirection;
  String? icon;
  String? shortForecast;
  String? detailedForecast;

  Periods(
      {this.number,
      this.name,
      this.startTime,
      this.endTime,
      this.isDaytime,
      this.temperature,
      this.temperatureUnit,
      this.probabilityOfPrecipitation,
      this.relativeHumidity,
      this.dewpoint,
      this.windSpeed,
      this.windDirection,
      this.icon,
      this.shortForecast,
      this.detailedForecast});

  Periods.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    name = json['name'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    isDaytime = json['isDaytime'];
    temperature = json['temperature'];
    temperatureUnit = json['temperatureUnit'];
    probabilityOfPrecipitation = json['probabilityOfPrecipitation'] != null
        ? ProbabilityOfPrecipitation.fromJson(
            json['probabilityOfPrecipitation'])
        : null;
    dewpoint =
        json['dewpoint'] != null ? Elevation.fromJson(json['dewpoint']) : null;
    relativeHumidity = json['relativeHumidity'] != null
        ? ProbabilityOfPrecipitation.fromJson(json['relativeHumidity'])
        : null;
    windSpeed = json['windSpeed'];
    windDirection = json['windDirection'];
    icon = json['icon'];
    shortForecast = json['shortForecast'];
    detailedForecast = json['detailedForecast'];
  }
}

class ProbabilityOfPrecipitation {
  String? unitCode;
  int? value;

  ProbabilityOfPrecipitation({this.unitCode, this.value});

  ProbabilityOfPrecipitation.fromJson(Map<String, dynamic> json) {
    unitCode = json['unitCode'];
    value = json['value'];
  }
}

//Hourly Forecast classes
class HourlyForecast {
  HourlyForecastProperties? properties;

  HourlyForecast({this.properties});

  HourlyForecast.fromJson(Map<String, dynamic> json) {
    properties = json['properties'] != null
        ? HourlyForecastProperties.fromJson(json['properties'])
        : null;
  }
}

class HourlyForecastProperties {
  String? updated;
  String? units;
  String? forecastGenerator;
  String? generatedAt;
  String? updateTime;
  String? validTimes;
  List<HourlyPeriods>? periods;

  HourlyForecastProperties(
      {this.updated,
      this.units,
      this.forecastGenerator,
      this.generatedAt,
      this.updateTime,
      this.validTimes,
      this.periods});

  HourlyForecastProperties.fromJson(Map<String, dynamic> json) {
    updated = json['updated'];
    units = json['units'];
    forecastGenerator = json['forecastGenerator'];
    generatedAt = json['generatedAt'];
    updateTime = json['updateTime'];
    validTimes = json['validTimes'];
    if (json['periods'] != null) {
      periods = <HourlyPeriods>[];
      json['periods'].forEach((v) {
        periods!.add(HourlyPeriods.fromJson(v));
      });
    }
  }
}

class HourlyPeriods {
  int? number;
  String? name;
  String? startTime;
  String? endTime;
  bool? isDaytime;
  int? temperature;
  String? temperatureUnit;
  ProbabilityOfPrecipitation? probabilityOfPrecipitation;
  ProbabilityOfPrecipitation? relativeHumidity;
  String? windSpeed;
  String? windDirection;
  String? icon;
  String? shortForecast;
  String? detailedForecast;

  HourlyPeriods(
      {this.number,
      this.name,
      this.startTime,
      this.endTime,
      this.isDaytime,
      this.temperature,
      this.temperatureUnit,
      this.probabilityOfPrecipitation,
      this.relativeHumidity,
      this.windSpeed,
      this.windDirection,
      this.icon,
      this.shortForecast,
      this.detailedForecast});

  HourlyPeriods.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    name = json['name'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    isDaytime = json['isDaytime'];
    temperature = json['temperature'];
    temperatureUnit = json['temperatureUnit'];
    probabilityOfPrecipitation = json['probabilityOfPrecipitation'] != null
        ? ProbabilityOfPrecipitation.fromJson(
            json['probabilityOfPrecipitation'])
        : null;
    relativeHumidity = json['relativeHumidity'] != null
        ? ProbabilityOfPrecipitation.fromJson(json['relativeHumidity'])
        : null;
    windSpeed = json['windSpeed'];
    windDirection = json['windDirection'];
    icon = json['icon'];
    shortForecast = json['shortForecast'];
    detailedForecast = json['detailedForecast'];
  }
}

class HourlyProbabilityOfPrecipitation {
  String? unitCode;
  int? value;

  HourlyProbabilityOfPrecipitation({this.unitCode, this.value});

  HourlyProbabilityOfPrecipitation.fromJson(Map<String, dynamic> json) {
    unitCode = json['unitCode'];
    value = json['value'];
  }
}

//Geocoding: Coordinates from zip code

class CoordinatesFromLocation {
  List<Results>? results;
  String? status;

  CoordinatesFromLocation({this.results, this.status});

  CoordinatesFromLocation.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
    status = json['status'];
  }
}

class Results {
  List<AddressComponents>? addressComponents;
  String? formattedAddress;
  Geometry? geometry;
/*   String? placeId;
  List<String>? postcodeLocalities;
  List<String>? types; */

  Results({
    this.formattedAddress,
    this.geometry,
    /* this.placeId,
      this.postcodeLocalities,
      this.types */
  });

  Results.fromJson(Map<String, dynamic> json) {
    if (json['address_components'] != null) {
      addressComponents = <AddressComponents>[];
      json['address_components'].forEach((v) {
        addressComponents!.add(AddressComponents.fromJson(v));
      });
    }
    formattedAddress = json['formatted_address'];
    geometry =
        json['geometry'] != null ? Geometry.fromJson(json['geometry']) : null;
    //placeId = json['place_id'];
    //postcodeLocalities = json['postcode_localities'].cast<String>();
    //types = json['types'].cast<String>();
  }
}

class AddressComponents {
  String? longName;
  String? shortName;
  List<String>? types;

  AddressComponents({this.longName, this.shortName, this.types});

  AddressComponents.fromJson(Map<String, dynamic> json) {
    longName = json['long_name'];
    shortName = json['short_name'];
    types = json['types'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['long_name'] = longName;
    data['short_name'] = shortName;
    data['types'] = types;
    return data;
  }
}

class Geometry {
  Location? location;

  Geometry({
    this.location,
  });

  Geometry.fromJson(Map<String, dynamic> json) {
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
  }
}

class Location {
  double latitude = double.infinity;
  double longitude = double.infinity;
  Location.fromJson(Map<String, dynamic> json) {
    latitude = json['lat'];
    longitude = json['lng'];
  }
}

//GeoCoding: Coordinates from city, state

///APIManager class is responsible for making the appropriate API calls,
///handling the data returned by the API,
///and returning the appropriate object that can hold the data required for the
///application.
class APIManager {
  ///  Uses two coordinates to make a call to National Weather API
  ///  to retrieve the id, gridId, gridX, gridY.
  ///
  /// Needs latitude and longitude strings to make the call.
  Future<WeatherPoint?> getWeatherPoint(Location locationData) async {
    var lat = locationData.latitude;
    var long = locationData.longitude;
    final response =
        await http.get(Uri.parse('https://api.weather.gov/points/$lat,$long'));

    if (response.statusCode == 200) {
      print("WeatherPoint HTTP: Success");
      final data = jsonDecode(response.body);
      //print(data);
      final newWeatherPoint = WeatherPoint.fromJson(data);
      return newWeatherPoint;
    } else {
      throw Exception('WeatherPoint HTTP: Fail');
    }
  }

  /// Uses the gridID, gridX, gridY to get the weather information for the requested
  /// area.
  Future<Forecast> getForecast(WeatherPoint currentWeatherPoint) async {
    String? gridX = currentWeatherPoint.properties?.gridX.toString();
    String? gridY = currentWeatherPoint.properties?.gridY.toString();
    final response = await http.get(Uri.parse(
        "https://api.weather.gov/gridpoints/${currentWeatherPoint.properties?.gridId}/$gridX,$gridY/forecast"));

    if (response.statusCode == 200) {
      print("Forecast HTTP: Success");
      final data = jsonDecode(response.body);
      //print(data);
      final newForecast = Forecast.fromJson(data);
      return newForecast;
    } else {
      throw Exception('Forecast HTTP: Fail');
    }
  }

  Future<HourlyForecast> getHourlyForecast(
      WeatherPoint currentWeatherPoint) async {
    String? gridX = currentWeatherPoint.properties?.gridX.toString();
    String? gridY = currentWeatherPoint.properties?.gridY.toString();
    print(
        "https://api.weather.gov/gridpoints/${currentWeatherPoint.properties?.gridId}/$gridX,$gridY/forecast/hourly");
    final response = await http.get(Uri.parse(
        "https://api.weather.gov/gridpoints/${currentWeatherPoint.properties?.gridId}/$gridX,$gridY/forecast/hourly"));

    if (response.statusCode == 200) {
      print("Hourly Forecast HTTP: Success");
      final data = jsonDecode(response.body);
      //print(data);
      final newForecast = HourlyForecast.fromJson(data);
      return newForecast;
    } else {
      throw Exception('Hourly Forecast HTTP: Fail');
    }
  }

  Future<CoordinatesFromLocation?> getCoordinatesFromLocation(
      String location) async {
    final response = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?address=$location&key=AIzaSyDeKwo1CHHgV09Jfh-MVGxHzpvKWDXr-vQ"));
    if (response.statusCode == 200) {
      print("Geocode Location->Coord HTTP: Success");
      final data = jsonDecode(response.body);
      //print(data);
      final newCoord = CoordinatesFromLocation.fromJson(data);
      return newCoord;
    } else {
      //return a null location instead. Prevents stack from being thrown out
      print("Geocode Location->Coord HTTP: Fail");
      return null;
    }
  }
}
