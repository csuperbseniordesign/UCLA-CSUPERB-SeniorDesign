import 'package:flutter/material.dart';

class AboutAppScreen extends StatefulWidget {
  AboutAppScreen({Key? key}) : super(key: key);

  @override
  _AboutAppScreenState createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  // final User? user = Auth().currentUser;

  @override
  Widget build(BuildContext context) {
    //  return MaterialApp(
      return Scaffold(
        appBar: AppBar(
        
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 0,
              child: Container(
                alignment: Alignment.topCenter,
                //color: Colors.blue,
                child: Text(
                  'ABOUT MYAPP',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    color: Colors.transparent,
                    shadows: [
                      Shadow(offset: Offset(0, -5), color: Colors.black),
                    ],
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black,
                    decorationThickness: 0.4,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.only(left: 15.0, top: 5),
                alignment: Alignment.topCenter,
                //color: Colors.yellow,
                child: Text(
                  'Welcome to AppName! Your go-to free tracking and safe-driving app.',
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: EdgeInsets.only(left: 15.0),
                      //color: Colors.purple,
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          Text(
                            'At AppName, we believe in promoting safe driving habits and empowering individuals to make informed decisions about their journeys.',
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 12.5),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            'Our app is designed to cater to a wide range of users, including those with specific needs such as glaucoma patients, ensuring a safe and reliable driving experience for everyone.',
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.asset(
                          'assets/images/road.png',
                          height: 165,
                          fit: BoxFit.contain,
                          color: const Color.fromARGB(255, 92, 117, 166),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              flex: 4,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Container(
                      //color: const Color.fromARGB(255, 243, 2, 2),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/screens.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      //color: Colors.blue,
                      alignment: Alignment.topLeft,
                      child: ListView(
                        children: <Widget>[
                          Text(
                            'Suitable For: ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(
                              '• Trip Log App \n'
                              '• Mileage Tracker App \n'
                              '• Location Tracking App \n'
                              '• Vehicle Logging App \n'
                              '• GPS Tracker App \n'
                              '• Etc. \n',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              flex: 0,
              child: Container(
                padding: EdgeInsets.all(8.0),
                //color: Color.fromARGB(255, 238, 105, 156),
                alignment: Alignment.topCenter,
                child: Text(
                  'Ready Tracking App',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.transparent,
                    shadows: [
                      Shadow(offset: Offset(0, -5), color: Colors.black),
                    ],
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black,
                    decorationThickness: 0.4,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.only(top: 10),
                      alignment: Alignment.center,
                      //color: Colors.blue,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/phone_icon.png',
                            height: 40,
                            width: 40,
                          ),
                          Expanded(
                            child: Text(
                              'Open-source mobile app',
                              style: TextStyle(fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.only(top: 10),
                      alignment: Alignment.center,
                      //color: Colors.amber,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/gear_icon.png',
                            height: 40,
                            width: 40,
                          ),
                          Expanded(
                            child: Text(
                              'Self-Service web-portal',
                              style: TextStyle(fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.only(top: 10),
                      alignment: Alignment.center,
                      //color: const Color.fromARGB(255, 7, 255, 119),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/telematics_icon.png',
                            height: 40,
                            width: 40,
                          ),
                          Expanded(
                            child: Text(
                              'Telematics infrastructure',
                              style: TextStyle(fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.only(top: 10),
                      alignment: Alignment.center,
                      //color: Color.fromARGB(255, 255, 57, 7),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/analytics_icon.png',
                            height: 40,
                            width: 40,
                          ),
                          Expanded(
                            child: Text(
                              'Analytics portal',
                              style: TextStyle(fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.only(top: 10),
                      alignment: Alignment.center,
                      //color: const Color.fromARGB(255, 247, 7, 255),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/firebase_icon.png',
                            height: 40,
                            width: 40,
                          ),
                          Expanded(
                            child: Text(
                              'Firebase Intergration',
                              style: TextStyle(fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  }
}
