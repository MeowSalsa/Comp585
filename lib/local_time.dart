class LocalTime {
  // Gets Day Percent of current time at given longitude
  static double getLocalDayPercent(double? longitude)
  {
    if (longitude == null)
    {
      return getDayPercent(DateTime.now());
    }

    DateTime localTime = toLocalTime(DateTime.now(), longitude);
    
    return getDayPercent(localTime);
  }

  // Converts given time to local timezone of given longitude
  static DateTime toLocalTime(DateTime time, double? longitude)
  {
    if (longitude == null)
    {
      return time;
    }

    int timeOffset = longitude ~/ 0.004167;

    return time.toUtc().add(Duration(seconds: timeOffset));
  }

  // Converts given time into a percentage of a full day
  static double getDayPercent(DateTime time)
  {
    return (time.hour / 24.0) + (time.minute / 1440.0) + (time.second / 86400.0);
  }
}