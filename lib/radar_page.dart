import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Radar extends StatefulWidget {
  const Radar({super.key});

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
      appBar: AppBar(
          title: const Text('Radar Animation'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              double screenHeight = MediaQuery.of(context).size.height;
              double imageSize = screenHeight * imageHeightPercentage;
              return Padding(
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
              );
            },
          ),
        ],
      ),
    );
  }
}
