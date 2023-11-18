class LocalTime {
  static double getLocalDayPercent(double? longitude)
  {
    if (longitude == null)
    {
      return 0.42;
    }

    int timeOffset = longitude ~/ 0.004167;

    DateTime currentTime = DateTime.now().toUtc().add(Duration(seconds: timeOffset));
    return (currentTime.hour / 24.0) + (currentTime.minute / 1440.0) + (currentTime.second / 86400.0);
  }
}