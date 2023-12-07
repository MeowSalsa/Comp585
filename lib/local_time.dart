class LocalTime {
  static double getLocalDayPercent(double? longitude)
  {
    if (longitude == null)
    {
      return getDayPercent(DateTime.now());
    }

    DateTime localTime = toLocalTime(DateTime.now(), longitude);
    
    return getDayPercent(localTime);
  }

  static DateTime toLocalTime(DateTime time, double? longitude)
  {
    if (longitude == null)
    {
      return time;
    }

    int timeOffset = longitude ~/ 0.004167;

    return time.toUtc().add(Duration(seconds: timeOffset));
  }

  static double getDayPercent(DateTime time)
  {
    return (time.hour / 24.0) + (time.minute / 1440.0) + (time.second / 86400.0);
  }
}