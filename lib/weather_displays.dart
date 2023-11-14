import 'package:flutter/material.dart';

class MinorWeatherDisplay extends StatelessWidget {

  final String? displayText;

  const MinorWeatherDisplay({
    super.key,
    this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          color: const Color(0x80E7E7E7),
          child: Center(
            child: Text(
              "$displayText"
            ),
          ),
        ),
      ),
    );
  }
}

class WindDisplay extends MinorWeatherDisplay {

}