import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'local_time.dart';
import 'colors.dart';

class Radar extends StatefulWidget {
  final String? locationString;
  final double? locationLongitude;
  const Radar({
    super.key,
    required this.locationString,
    required this.locationLongitude,
  });

  @override
  _RadarPageState createState() => _RadarPageState();
}

class _RadarPageState extends State<Radar> {
  String imageUrl =
      'https://cdn.star.nesdis.noaa.gov/GOES18/ABI/SECTOR/wus/GEOCOLOR/GOES18-WUS-GEOCOLOR-1000x1000.gif';

  // Set the percentage of screen height for the image
  double imageHeightPercentage = 0.75;
  double horizontalPadding = 16.0;
  double verticalPadding = 8.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = MediaQuery.of(context).size.width;
              double screenHeight = MediaQuery.of(context).size.height;
              double topPadding = MediaQuery.of(context).viewPadding.top;
              Color bgColor = TimeBasedColorScheme.colorSchemeFromLocalTime(
                LocalTime.getLocalDayPercent(widget.locationLongitude)
              ).mainBGColor;
              double imageSize = screenHeight * imageHeightPercentage;
              return Container(
                color: bgColor,
                width: screenWidth,
                height: screenHeight,
                child: Column(
                  children: [
                    
                    // Location Title
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenHeight / 50.0,
                        top: screenHeight / 75.0 + topPadding
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              clipBehavior: Clip.hardEdge,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: screenHeight / 32.0,
                                    ),

                                    Padding(padding: EdgeInsets.only(left: screenHeight / 53.0)),

                                    Text(
                                      widget.locationString ?? "",
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenHeight / 35.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(
                        screenHeight / 42.6, 
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Weather Radar",
                            style: TextStyle(
                              fontSize: screenHeight / 35.6,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        width: constraints.maxWidth,
                        height: imageSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
