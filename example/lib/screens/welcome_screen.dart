import 'package:flutter/material.dart';
import 'package:telematics_sdk_example/screens/user_type_screen.dart';

Widget _decoration() {
  return Stack(
    children: [
      Positioned(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 40, bottom: 15, right: 10, left: 10),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: (const Color.fromARGB(255, 4, 27, 63)),
                width: 5,
              ),
            ),
          ),
        ),
      ),
      // This is that invisible rectangle at the top left.
      Positioned(
        top: 28,
        left: -100,
        child: Container(
          height: 175,
          width: 175,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            shape: BoxShape.rectangle,
          ),
        ),
      ),
      // This is that invisible rectangle at the bottom right.
      Positioned(
        bottom: -45,
        right: -13,
        child: Container(
          height: 175,
          width: 175,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
          ),
        ),
      ),
      // This is for the blue ball-top left.
      Positioned(
        top: 30.0,
        left: -40.0,
        child: Container(
          height: 125,
          width: 125,
          decoration: BoxDecoration(
            color: (const Color.fromARGB(255, 4, 27, 63)),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3.0,
            ),
          ),
        ),
      ),
      // This is for the beige ball-top left.
      Positioned(
        top: 100.0,
        left: -40.0,
        child: Container(
          height: 95,
          width: 95,
          decoration: BoxDecoration(
            color: (const Color.fromARGB(255, 200, 195, 146)),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3.0,
            ),
          ),
        ),
      ),
      // This is for the blue ball-bottom right.
      Positioned(
        bottom: -80.0,
        right: -80.0,
        child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: (const Color.fromARGB(255, 4, 27, 63)),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3.0,
            ),
          ),
        ),
      ),
      // This is for the beige ball-bottom right.
      Positioned(
        bottom: -50.0,
        right: 50.0,
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: (const Color.fromARGB(255, 200, 195, 146)),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3.0,
            ),
          ),
        ),
      ),
      // This belongs to the car logo.
      Positioned(
        top: 100.0,
        right: 90,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color.fromARGB(255, 103, 139, 183),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/images/road.png',
                    height: 200,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// Welcome Text
Widget _header() {
  return const Align(
    alignment: Alignment.center,
    child: Padding(
      padding: const EdgeInsets.only(top: 330),
      child: Column(
        children: [
          Text(
            'Welcome to EyeMyWay!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40.0,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Please sign in to begin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.grey,
            ),
          )
        ],
      ),
    ),
  );
}

Widget _signInButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 575, left: 35),
    child: SizedBox(
      height: 70,
      width: 325,
      child: FilledButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserTypePage()));
        },
        style: FilledButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 103, 139, 183),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Text(
          'EyeMyWay',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 254, 255, 255),
            fontSize: 25.0,
          ),
        ),
      ),
    ),
  );
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [_decoration(), _header(), _signInButton(context)]));
  }
}
