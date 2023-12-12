import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum FavButtonStates {
  readyToAdd,
  adding,
  readyToRemove,
  removing
}

class NavigationButton extends StatelessWidget {
  final String label;
  final Widget destinationWidget;

  const NavigationButton({
    super.key,
    required this.label,
    required this.destinationWidget,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => destinationWidget
          )
        );
      },

      child: Padding(
        padding: EdgeInsets.all(screenWidth / 21.3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenHeight / 30.0),
          child: Container(
            color: const Color(0x80E7E7E7),
            child: SizedBox(
              height: screenHeight / 15.0,
              child: Padding(
                padding: EdgeInsets.only(left: screenWidth / 21.3, right: screenWidth / 42.6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: screenHeight / 35.5,
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: screenHeight / 32.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {

  final FavButtonStates initialState;
  final String addTarget;

  const FavoriteButton({
    super.key,
    this.initialState = FavButtonStates.readyToAdd,
    required this.addTarget
  });

  @override
  _FavoriteButtonState createState () => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {

  late FavButtonStates currentState;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentState = widget.initialState;
    });
  }

  Widget _readyToAddButton(double size) {
    return GestureDetector(
      onTap: () {
        
        setState(() {
          currentState = FavButtonStates.adding;
        });

        Future.delayed(const Duration(seconds: 2), () {
          
          setState(() {
            currentState = FavButtonStates.readyToRemove;
          });
        });
      },
      child: Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: size,
      ),
    ).animate().moveX(begin: size * -10, end: 0.0, duration: .3.seconds);
  }

  Widget _addingButton(double size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size / 3.0),
      child: Text(
        "Added!",
        style: TextStyle(
          color: Colors.white,
          fontSize: size,
        ),
      )
    ).animate().moveX(begin: size * 10, end: 0.0, duration: .2.seconds);
  }

  Widget _readyToRemoveButton(double size) {
    return GestureDetector(
      onTap: () {
        
        setState(() {
          currentState = FavButtonStates.removing;
        });

        Future.delayed(const Duration(seconds: 2), () {
          
          setState(() {
            currentState = FavButtonStates.readyToAdd;
          });
        });
      },
      child: Icon(
        Icons.remove_rounded,
        color: Colors.white,
        size: size,
      ),
    ).animate().moveX(begin: size * -10, end: 0.0, duration: .3.seconds);
  }

  Widget _removingButton(double size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size / 3.0),
      child: Text(
        "Removed!",
        style: TextStyle(
          color: Colors.white,
          fontSize: size,
        ),
      ),
    ).animate().moveX(begin: size * 10, end: 0.0, duration: .2.seconds);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    Widget? favButton;
    
    switch(currentState)
    {
      case FavButtonStates.readyToAdd:
        favButton = _readyToAddButton(screenHeight / 32.0);
      case FavButtonStates.adding:
        favButton = _addingButton(screenHeight / 45.0);
      case FavButtonStates.readyToRemove:
        favButton = _readyToRemoveButton(screenHeight / 32.0);
      case FavButtonStates.removing:
        favButton = _removingButton(screenHeight / 45.0);
    }
    
    return PreferredSize(
      preferredSize: Size.square(screenHeight / 32.0),
      
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenHeight / 64.0),
        child: Container(
          color: const Color(0x80E7E7E7),
          child: SizedBox(
            height: screenHeight / 32.0,
            child: favButton,
          ),
        ),
      ),
    );
  }
}