import 'package:flutter/material.dart';

class TimeBasedColorScheme {

  Color skyStartColor;
  Color skyEndColor;
  Color mainBGColor;

  TimeBasedColorScheme({
    required this.skyStartColor,
    required this.skyEndColor,
    required this.mainBGColor
  });

  static LinearGradient skyStartColors = const LinearGradient(
    colors: [
      Color(0xFF3C009D),
      Color(0xFF699EEE),
      Color(0xFF7ED9CE),
      Color(0xFF693BB2),
      Color(0xFF3C009D),
    ],
    stops: [0.0, 0.42, 0.58, 0.75, 1.0],  // 12 AM, 10 AM, 2 PM, 6 PM, 12 AM (Next day)
  );

  static LinearGradient skyEndColors = const LinearGradient(
    colors: [
      Color(0xFFDEDFFF),
      Color(0xFFD9E9F2),
      Color(0xFFDFFFF2),
      Color(0xFFCBA459),
      Color(0xFFDEDFFF),
    ],
    stops: [0.0, 0.42, 0.58, 0.75, 1.0],
  );

  static LinearGradient mainBGColors = const LinearGradient(
    colors: [
      Color(0xFF695E88),
      Color(0xFF97D3BD),
      Color(0xFFB1D397),
      Color(0xFF695E88),
    ],
    stops: [0.0, 0.42, 0.58, 0.75],
  );

  static Color? lerpGradient(List<Color> colors, List<double> stops, double t) {
    
    for (int s = 0; s < stops.length - 1; s++)
    {
      final leftStop = stops[s], rightStop = stops[s + 1];
      final leftColor = colors[s], rightColor = colors[s + 1];

      if (t <= leftStop)
      {
        return leftColor;
      }
      else if (t < rightStop)
      {
        final sectionT = (t - leftStop) / (rightStop - leftStop);
        return Color.lerp(leftColor, rightColor, sectionT);
      }
    }
    
    return colors.last;
  }

  static TimeBasedColorScheme colorSchemeFromLocalTime(double? dayPercent) {

    Color? currentSkyStartColor = lerpGradient(skyStartColors.colors, skyStartColors.stops!, dayPercent!);
    Color? currentSkyEndColor = lerpGradient(skyEndColors.colors, skyEndColors.stops!, dayPercent);
    Color? currentBGColor = lerpGradient(mainBGColors.colors, mainBGColors.stops!, dayPercent);

    return TimeBasedColorScheme(
      skyStartColor: currentSkyStartColor!,
      skyEndColor: currentSkyEndColor!,
      mainBGColor: currentBGColor!
    );
  }
}