import 'package:flutter/material.dart';
import 'package:telematics_sdk_example/screens/physicianUI/patient_trips_screen.dart';
import 'package:telematics_sdk_example/services/UnifiedAuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientDisplayScreen extends StatefulWidget {
  final String email;
  final String token;
  PatientDisplayScreen(this.email, this.token);

  @override
  State<StatefulWidget> createState() {
    return _PatientDisplayScreenState(this.email, this.token);
  }
}

class _PatientDisplayScreenState extends State<PatientDisplayScreen> {
  String email;
  String token;
  _PatientDisplayScreenState(this.email, this.token);

  User? currentUser = FirebaseAuth.instance.currentUser;
  final UnifiedAuthService _auth = UnifiedAuthService();
  List<String> stats = [];

  List<Container> totals = [];
  int tripCount = 0;
  List<Padding> scores = [];


  @override
  void initState() {
    super.initState();
    loadStats();
    loadScores();
  }

  void loadStats() async {
    try {
      var items = await _auth.fetchStatistics(this.token);
      if (items.isNotEmpty) {
        setState(() {
          stats = items;
          Container totalTrips = new Container(
            margin: const EdgeInsets.only(left: 20, right: 5),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 66, 63, 63).withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              stats[0] + "\nTotal Trips\n(quantity)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          );
          tripCount = int.parse(stats[0]);
          Container totalMiles = new Container(
            margin: const EdgeInsets.all(5.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 66, 63, 63).withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              stats[1] + "\nTotal Mileage\n(mi)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          );
          Container totalTime = new Container(
            margin: const EdgeInsets.all(5.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              stats[2] + "\nTime Driven\n(min)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          );
          totals.add(totalTrips);
          totals.add(totalMiles);
          totals.add(totalTime);
        });
      }
    } catch (e) {
      print("Error loading stats: $e");
    }
  }

  // get the patient's accumulated scores
  void loadScores() async {
      List<Padding> tempScores = [];
    try {
      var items = await _auth.fetchScores(this.token);
      if (items.isNotEmpty) {
        // setState(() {
          List<Icon> icons = [
            Icon(Icons.track_changes),
            Icon(Icons.traffic),
            Icon(Icons.speed),
            Icon(Icons.turn_slight_right),
            Icon(Icons.system_security_update)
          ];
          List<String> score = [
            "Acceleration\t\t",
            "Braking\t\t\t\t\t\t\t\t\t\t",
            "Speeding\t\t\t\t\t\t\t",
            "Cornering\t\t\t\t\t\t",
            "Phone Usage "
          ];
          for (int i = 0; i < items.length; i++) {
            Padding pad = new Padding(
                padding: EdgeInsets.only(top: 10),
                child: new ListTile(
                  leading: icons[i],
                  title: Text(score[i] +
                      "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t" +
                      items[i]),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Color.fromARGB(255, 63, 60, 60), width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ));
            // scores.add(pad);
            tempScores.add(pad);
          }
        // });

          setState(() {
            scores = tempScores;
          });
      }
    } catch (e) {
      print("Error loading stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(email),
        flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color.fromARGB(255, 255, 255, 255),Color.fromARGB(255, 51, 110, 159)]),
      ),
    ),
      ),
      body: ListView(
        children: [
          Column(children: [
            Padding(padding: EdgeInsets.only(bottom: 50)),
            Row(
              children: totals,
            ),
            Padding(padding: EdgeInsets.only(bottom: 50))
          ]),
          Text(
            "Summary Scores",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          Container(
            child: Column(children: scores),
            margin: EdgeInsets.only(left: 10, right: 10),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 70),
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 50, right: 10, left: 10),
              child: TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 51, 110, 159)),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          PatientTripsScreen(email, token, tripCount)));
                },
                child: Text(
                  "View More Drive Analytics",
                ),
              )),
        ],
      ),
    );
  }
}
