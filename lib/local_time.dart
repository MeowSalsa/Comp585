class LocalTime {
  static double getLocalDayPercent(double? longitude)
  {
    if (longitude == null)
    {
      return getDayPercent(DateTime.now());
    }

    int timeOffset = longitude ~/ 0.004167;

    DateTime localTime = DateTime.now().toUtc().add(Duration(seconds: timeOffset));
    return getDayPercent(localTime);
  }

  static double getDayPercent(DateTime time)
  {
    return (time.hour / 24.0) + (time.minute / 1440.0) + (time.second / 86400.0);
  }
}