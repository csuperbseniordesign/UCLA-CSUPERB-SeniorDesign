import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientTripsScreen extends StatefulWidget {
  final String email;
  final String token;
  final int tripCount;
  PatientTripsScreen(this.email, this.token, this.tripCount);
  // final UnifiedAuthService _auth = UnifiedAuthService();

  @override
  State<StatefulWidget> createState() {
    return _PatientTripsScreenState(this.email, this.token, this.tripCount);
  }
}

class _PatientTripsScreenState extends State<PatientTripsScreen> {
  String email;
  String token;
  int tripCount;
  _PatientTripsScreenState(this.email, this.token, this.tripCount);
  User? currentUser = FirebaseAuth.instance.currentUser;
  // final UnifiedAuthService _auth = UnifiedAuthService();

  List<List<String>> trips = [];

  List<Container> containers = [];
  List<String> startDates = [];
  List<String> endDates = [];
  List<String> locations = [];
  List<String> mileages = [];
  List<String> durations = [];
  List<String> accelerations = [];
  List<String> brakings = [];
  List<String> cornerings = [];
  List<String> phoneUsages = [];
  List<String> nightHours = [];
  List<String> avgSpeeds = [];
  List<String> aScores = [];
  List<String> bScores = [];
  List<String> cScores = [];
  List<String> sScores = [];
  List<String> pScores = [];
  List<String> spScores = [];
  List<Container> temp = [];
  @override
  void initState() {
    loadTrips();
    super.initState();
  }

  Future<List<List<String>>> fetchTrips(String authToken, int tripCount) async {
    String startTime = "";
    String endTime = "";

    try {
      final response = await http.post(
        Uri.parse('https://api.telematicssdk.com/trips/get/v1/'),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'authorization': 'Bearer $authToken'
        },
        body: jsonEncode({
          'StartDate': '2024-01-20T09:46:59.265Z',
          'EndDate': '2024-09-20T09:46:59.265Z',
          'IncludeDetails': true,
          'IncludeStatistics': true,
          'IncludeScores': true,
          'Locale': 'EN',
          'UnitSystem': 'Si',
          'SortBy': 'StartDateUtc',
          'Paging': {'Page': 1, 'Count': 10, 'IncludePagingInfo': true}
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data["Result"] != null) {
          for (int i = 0; i < tripCount; i++) {
            List<String> rawStartDate = data["Result"]['Trips'][i]['Data']
                    ['StartDate']
                .toString()
                .split("T");
            List<String> t = rawStartDate[1].split("-");

            int startHour = int.parse(t[0].substring(0, 2));
            if (startHour > 12) {
              startHour = startHour - 12;
              startTime = rawStartDate[0].substring(5, 7) +
                  "-" +
                  rawStartDate[0].substring(8, 10) +
                  "-" +
                  rawStartDate[0].substring(0, 4) +
                  " " +
                  startHour.toString() +
                  t[0].substring(2, 8) +
                  " PM";
            } else {
              startTime = rawStartDate[0].substring(5, 7) +
                  "-" +
                  rawStartDate[0].substring(8, 10) +
                  "-" +
                  rawStartDate[0].substring(0, 4) +
                  " " +
                  startHour.toString() +
                  t[0].substring(2, 8) +
                  " AM";
            }

            startDates.add(startTime);

            List<String> rawEndDate = data["Result"]['Trips'][i]['Data']
                    ['EndDate']
                .toString()
                .split("T");

            List<String> endT = rawEndDate[1].split("-");
            int endHour = int.parse(endT[0].substring(0, 2));

            if (endHour > 12) {
              endHour = endHour - 12;

              endTime = rawEndDate[0].substring(5, 7) +
                  "-" +
                  rawEndDate[0].substring(8, 10) +
                  "-" +
                  rawEndDate[0].substring(0, 4) +
                  " " +
                  endHour.toString() +
                  endT[0].substring(2, 8) +
                  " PM";
            } else {
              endTime = rawEndDate[0].substring(5, 7) +
                  "-" +
                  rawEndDate[0].substring(8, 10) +
                  "-" +
                  rawEndDate[0].substring(0, 4) +
                  " " +
                  endHour.toString() +
                  endT[0].substring(2, 8) +
                  " AM";
            }

            endDates.add(endTime);

            locations.add(data["Result"]['Trips'][i]['Data']['Addresses']
                        ['Start']['Full']
                    .toString() +
                " to " +
                data["Result"]['Trips'][i]['Data']['Addresses']['End']['Full']
                    .toString());
            mileages.add(double.parse(data["Result"]['Trips'][i]['Statistics']
                            ['Mileage']
                        .toString())
                    .toStringAsPrecision(5) +
                " km");

            accelerations.add(data["Result"]['Trips'][i]['Statistics']
                    ['AccelerationsCount']
                .toString()
                .split(".")[0]);

            brakings.add(data["Result"]['Trips'][i]['Statistics']
                    ['BrakingsCount']
                .toString()
                .split(".")[0]);

            cornerings.add(data["Result"]['Trips'][i]['Statistics']
                    ['CorneringsCount']
                .toString()
                .split(".")[0]);
            phoneUsages.add(data["Result"]['Trips'][i]['Statistics']
                        ['PhoneUsageDurationMinutes']
                    .toString() +
                " min");
            nightHours.add(data["Result"]['Trips'][i]['Statistics']
                        ['NightHours']
                    .toString() +
                " hrs");
            durations.add(double.parse(data["Result"]['Trips'][i]['Statistics']
                            ['DurationMinutes']
                        .toString())
                    .toStringAsPrecision(4) +
                " min");

            avgSpeeds.add(double.parse(data["Result"]['Trips'][i]['Statistics']
                            ['AverageSpeed']
                        .toString())
                    .toStringAsPrecision(5) +
                " km/hr");

            sScores.add(data["Result"]['Trips'][i]['Scores']['Safety']
                .toString()
                .split(".")[0]);
            aScores.add(data["Result"]['Trips'][i]['Scores']['Acceleration']
                .toString()
                .split(".")[0]);
            bScores.add(data["Result"]['Trips'][i]['Scores']['Braking']
                .toString()
                .split(".")[0]);
            cScores.add(data["Result"]['Trips'][i]['Scores']['Cornering']
                .toString()
                .split(".")[0]);
            spScores.add(data["Result"]['Trips'][i]['Scores']['Speeding']
                .toString()
                .split(".")[0]);
            pScores.add(data["Result"]['Trips'][i]['Scores']['PhoneUsage']
                .toString()
                .split(".")[0]);
          }
        }
        trips.add(startDates);
        trips.add(endDates);
        trips.add(locations);
        trips.add(mileages);
        trips.add(durations);
        trips.add(accelerations);
        trips.add(brakings);
        trips.add(cornerings);
        trips.add(phoneUsages);
        trips.add(nightHours);
        trips.add(avgSpeeds);
        trips.add(sScores);
        trips.add(aScores);
        trips.add(bScores);
        trips.add(cScores);
        trips.add(spScores);
        trips.add(pScores);
      } else {
        print(
            'Failed to fetch daily statistics, status code: ${response.statusCode}, response: ${response.body}');
      }
    } catch (e) {
      print('Error fetching daily statistics: $e');
    }
    // setState(() {});
    return trips;
  }

  // get the patient's accumulated totals
  void loadTrips() async {
    try {
      var items = await fetchTrips(this.token, this.tripCount);
      if (items.isNotEmpty) {
        // setState(() {
        trips = items;
        for (int i = 0; i < tripCount; i++) {
          // setState(() {
          // containers.add(Container(
          temp.add(Container(
            color: Color.fromARGB(255, 238, 235, 235),
            margin: EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: <Widget>[
                    Expanded(
                      child: Text(
                        locations[i].toString() + "\n",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ]),
                  Row(children: <Widget>[
                    Text(
                      startDates[i].toString() +
                          " to " +
                          // "\n" +
                          endDates[i].toString() +
                          "\n",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )
                  ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Drive Duration",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          durations[i].toString(),
                          textAlign: TextAlign.right,
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Mileage",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          mileages[i].toString(),
                          textAlign: TextAlign.right,
                        )
                      ]),
                  Divider(
                    color: Colors.black,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Average Speed",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          avgSpeeds[i].toString(),
                          textAlign: TextAlign.right,
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Acceleration Count",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(accelerations[i].toString(),
                            textAlign: TextAlign.right)
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Braking Count",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(brakings[i].toString(), textAlign: TextAlign.right)
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Cornering Count",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(cornerings[i].toString(),
                            textAlign: TextAlign.right)
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Phone Usage",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(phoneUsages[i].toString(),
                            textAlign: TextAlign.right)
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Night Driving",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(nightHours[i].toString(),
                            textAlign: TextAlign.right)
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Safety Score",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(sScores[i].toString(), textAlign: TextAlign.right)
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Acceleration Score",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(aScores[i].toString(), textAlign: TextAlign.right)
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Braking Score",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(bScores[i].toString(), textAlign: TextAlign.right)
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Cornering Score",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(cScores[i].toString(), textAlign: TextAlign.right)
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Speeding Score",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(spScores[i].toString(), textAlign: TextAlign.right)
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Phone Usage Score",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(pScores[i].toString(), textAlign: TextAlign.right)
                      ]),
                ]),
          ));
          // });
        }
        setState(() {
          containers = temp;
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
                colors: <Color>[
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 51, 110, 159)
                ]),
          ),
        ),
      ),
      body: ListView(
        children: containers,
      ),
    );
  }
}
