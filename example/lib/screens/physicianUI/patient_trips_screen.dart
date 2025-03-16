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
  int nightTimeDrivesCount = 0;
  int highSpeedTripsCount = 0;

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
    List<String> maxSpeedScores = [];
  List<Container> temp = [];
  @override
  void initState() {
    loadTrips();
    super.initState();
  }

  // Helper functions for unit conversion
  double kmToMiles(double km) {
    return km * 0.621371;
  }

  double kmhToMph(double kmh) {
    return kmh * 0.621371;
  }

  // Extract coordinates from address string
  (double, double)? extractCoordinates(String address) {
    try {
      print("\n=== Address Processing ===");
      print("Original address: $address");
      
      // First, check if coordinates are in the address
      RegExp coordRegex = RegExp(r'(\d+\.\d+),\s*(-?\d+\.\d+)');
      var match = coordRegex.firstMatch(address);
      if (match != null) {
        double lat = double.parse(match.group(1)!);
        double lon = double.parse(match.group(2)!);
        print("Extracted coordinates: ($lat, $lon)");
        return (lat, lon);
      }
      
      // If no coordinates found, use default LA coordinates
      print("No coordinates found, using default LA coordinates");
      return (34.0522, -118.2437); // Los Angeles coordinates
    } catch (e) {
      print('Error extracting coordinates: $e');
      return null;
    }
  }

  Future<bool> isNightDriving(DateTime tripTime, double latitude, double longitude) async {
    tripTime = tripTime.toLocal();
    
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.sunrise-sunset.org/json?lat=$latitude&lng=$longitude&date=${tripTime.year}-${tripTime.month}-${tripTime.day}&formatted=0'
        )
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          DateTime sunrise = DateTime.parse(data['results']['sunrise']).toLocal();
          DateTime sunset = DateTime.parse(data['results']['sunset']).toLocal();
          
          // Add 30 minutes to sunrise and subtract 30 minutes from sunset for civil twilight
          DateTime civilDawn = sunrise.add(Duration(minutes: 30));
          DateTime civilDusk = sunset.subtract(Duration(minutes: 30));
          
          print("\n=== Night Driving Check ===");
          print("Trip time: ${tripTime.toString()}");
          print("Civil dawn: ${civilDawn.toString()}");
          print("Civil dusk: ${civilDusk.toString()}");
          
          bool isNight = tripTime.isBefore(civilDawn) || tripTime.isAfter(civilDusk);
          print("Is night: $isNight");
          
          return isNight;
        }
      }
      
      print("Error getting sunrise/sunset times, falling back to default night hours (7 PM - 6 AM)");
      int hour = tripTime.hour;
      return hour >= 19 || hour < 6;
      
    } catch (e) {
      print("Error in isNightDriving: $e");
      // Fallback to default night hours if API call fails
      int hour = tripTime.hour;
      return hour >= 19 || hour < 6;
    }
  }

  Future<List<List<String>>> fetchTrips(String authToken, int tripCount) async {
    // Clear previous data
    trips.clear();
    startDates.clear();
    endDates.clear();
    locations.clear();
    mileages.clear();
    durations.clear();
    accelerations.clear();
    brakings.clear();
    cornerings.clear();
    phoneUsages.clear();
    nightHours.clear();
    avgSpeeds.clear();
    maxSpeedScores.clear();
    sScores.clear();
    aScores.clear();
    bScores.clear();
    cScores.clear();
    spScores.clear();
    pScores.clear();
    
    // Reset counters
    nightTimeDrivesCount = 0;
    highSpeedTripsCount = 0;

    // Get current date and time in UTC
    DateTime now = DateTime.now().toUtc();
    // Get date 2 weeks ago in UTC
    DateTime twoWeeksAgo = now.subtract(Duration(days: 14));
    
    // Format dates in ISO8601 format with UTC timezone
    String startDate = twoWeeksAgo.toIso8601String();
    String endDate = now.toIso8601String();

    print("Fetching trips from $startDate to $endDate");
    print("Requested trip count: $tripCount");

    // Limit the request to maximum 50 trips as per API limitation
    int requestCount = tripCount > 50 ? 50 : tripCount;
    print("Requesting $requestCount trips (API limit: 50)");

    try {
      final response = await http.post(
        Uri.parse('https://api.telematicssdk.com/trips/get/v1/'),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'authorization': 'Bearer $authToken'
        },
        body: jsonEncode({
          'StartDate': startDate,
          'EndDate': endDate,
          'IncludeDetails': true,
          'IncludeStatistics': true,
          'IncludeScores': true,
          'Locale': 'EN',
          'UnitSystem': 'Si',  // Keep as SI and convert manually for more precision
          'SortBy': 'StartDateUtc',
          'SortOrder': 'Desc',
          'Paging': {
            'Page': 1,
            'Count': requestCount,
            'IncludePagingInfo': true
          }
        }),
      );

      print("Response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data["Result"] != null && data["Result"]['Trips'] != null) {
          int actualTripCount = data["Result"]['Trips'].length;
          print("\n=== Processing $actualTripCount trips ===");
          
          for (int i = 0; i < actualTripCount; i++) {
            var trip = data["Result"]['Trips'][i];
            
            // Parse dates
            DateTime startDateTime = DateTime.parse(trip['Data']['StartDate']).toLocal();
            DateTime endDateTime = DateTime.parse(trip['Data']['EndDate']).toLocal();
            
            print("\n--- Trip ${i + 1} ---");
            print("Start time: ${startDateTime.toString()}");
            print("End time: ${endDateTime.toString()}");
            
            String startTime = _formatDateTime(startDateTime);
            String endTime = _formatDateTime(endDateTime);
            
            // Get trip location coordinates
            String startAddress = trip['Data']['Addresses']['Start']['Full'].toString();
            var coords = extractCoordinates(startAddress);
            
            // Update the night driving check to handle async
            bool isStartNight = false;
            bool isEndNight = false;
            
            if (coords != null) {
              isStartNight = await isNightDriving(startDateTime, coords.$1, coords.$2);
              isEndNight = await isNightDriving(endDateTime, coords.$1, coords.$2);
              
              print("Start night driving: $isStartNight");
              print("End night driving: $isEndNight");
              
              if (isStartNight || isEndNight) {
                nightTimeDrivesCount++;
                print("Trip counted as night driving");
              }
            }

            // Process speeds
            double maxSpeedKmh = double.parse(trip['Statistics']['MaxSpeed'].toString());
            double maxSpeedMph = kmhToMph(maxSpeedKmh);
            print("Max speed: $maxSpeedKmh km/h = $maxSpeedMph mph");
            
            // Check if this is a potential highway trip (max speed > 45 mph)
            if (maxSpeedMph > 45.0) {
                highSpeedTripsCount++;
                print("Trip counted as potential highway trip (max speed: $maxSpeedMph mph)");
            }

            startDates.add(startTime);
            endDates.add(endTime);
            
            // Add trip details with night driving info
            locations.add("${trip['Data']['Addresses']['Start']['Full']} to ${trip['Data']['Addresses']['End']['Full']}" +
                (isStartNight || isEndNight ? " (Night Drive)" : ""));

            // Convert mileage from km to miles
            double mileageKm = double.parse(trip['Statistics']['Mileage'].toString());
            double mileageMiles = kmToMiles(mileageKm);
            mileages.add(mileageMiles.toStringAsPrecision(5) + " mi");

            accelerations.add(trip['Statistics']['AccelerationsCount']
                .toString()
                .split(".")[0]);

            brakings.add(trip['Statistics']['BrakingsCount']
                .toString()
                .split(".")[0]);

            cornerings.add(trip['Statistics']['CorneringsCount']
                .toString()
                .split(".")[0]);
            phoneUsages.add(double.parse(trip['Statistics']['PhoneUsageDurationMinutes']
                        .toString()).toStringAsFixed(2) +
                " min");
            nightHours.add(double.parse(trip['Statistics']['NightHours']
                        .toString()).toStringAsFixed(2) +
                " min");
            durations.add(double.parse(trip['Statistics']['DurationMinutes']
                            .toString())
                    .toStringAsPrecision(2) +
                " min");

            // Convert speeds to mph
            double avgSpeedKmh = double.parse(trip['Statistics']['AverageSpeed'].toString());
            double avgSpeedMph = kmhToMph(avgSpeedKmh);
            avgSpeeds.add(avgSpeedMph.toStringAsPrecision(2) + " mph");
            maxSpeedScores.add(maxSpeedMph.toStringAsPrecision(2) + " mph");

            sScores.add(trip['Scores']['Safety']
                .toString()
                .split(".")[0]);
            aScores.add(trip['Scores']['Acceleration']
                .toString()
                .split(".")[0]);
            bScores.add(trip['Scores']['Braking']
                .toString()
                .split(".")[0]);
            cScores.add(trip['Scores']['Cornering']
                .toString()
                .split(".")[0]);
            spScores.add(trip['Scores']['Speeding']
                .toString()
                .split(".")[0]);
            pScores.add(trip['Scores']['PhoneUsage']
                .toString()
                .split(".")[0]);
          }
          
          print("Successfully processed $actualTripCount trips");
          print("Lists sizes - startDates: ${startDates.length}, endDates: ${endDates.length}, locations: ${locations.length}");
        } else {
          print("No trips found in the response");
          print("Response body: ${response.body}");
        }
      } else {
        print('Failed to fetch trips, status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching trips: $e');
      print('Stack trace: ${StackTrace.current}');
    }

    // Add all lists to trips in the correct order
    trips.add(startDates);
    trips.add(endDates);
    trips.add(locations);
    trips.add(mileages);
    trips.add(durations);
    trips.add(accelerations);
    trips.add(brakings);
    trips.add(cornerings);
    trips.add(phoneUsages);
    trips.add(maxSpeedScores);
    trips.add(avgSpeeds);
    trips.add(sScores);
    trips.add(aScores);
    trips.add(bScores);
    trips.add(cScores);
    trips.add(spScores);
    trips.add(pScores);

    print("Final trips list size: ${trips.length}");
    print("Each sublist size: ${trips.isNotEmpty ? trips[0].length : 0}");
    
    return trips;
  }

  // Helper method to format DateTime
  String _formatDateTime(DateTime dt) {
    String period = dt.hour >= 12 ? 'PM' : 'AM';
    int hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    hour = hour == 0 ? 12 : hour; // Convert 0 to 12 for 12 AM
    
    return '${dt.month.toString().padLeft(2, '0')}-'
           '${dt.day.toString().padLeft(2, '0')}-'
           '${dt.year} '
           '${hour.toString().padLeft(2, '0')}:'
           '${dt.minute.toString().padLeft(2, '0')}:'
           '${dt.second.toString().padLeft(2, '0')} '
           '$period';
  }

  // get the patient's accumulated totals
  void loadTrips() async {
    try {
      var items = await fetchTrips(this.token, this.tripCount);
      if (items.isNotEmpty) {
        trips = items;
        // Use the actual number of trips we have data for
        int actualTrips = trips[0].length; // since all lists should have same length
        print("Creating containers for $actualTrips trips");
        
        for (int i = 0; i < actualTrips; i++) {
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
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Text(
                  //         "Night Driving",
                  //         textAlign: TextAlign.left,
                  //         style: TextStyle(fontWeight: FontWeight.bold),
                  //       ),
                  //       Text(nightHours[i].toString(),
                  //           textAlign: TextAlign.right)
                  //     ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Max Speed",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(maxSpeedScores[i].toString(),
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
        }
        setState(() {
          containers = temp;
        });
      }
    } catch (e) {
      print("Error loading stats: $e");
      print("Stack trace: ${StackTrace.current}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(email),
      ),
      body: Column(
        children: [
          // Box displaying counts of night-time drives and trips with speed > 65 km/h
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: EdgeInsets.all(10),
              color: Color.fromARGB(255, 238, 235, 235),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary for Past 2 Weeks',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text('Number of Night-Time Trips: $nightTimeDrivesCount'),
                  Text('Number of Potential Highway Trips: $highSpeedTripsCount'),
                ],
              ),
            ),
          ),
          // List of trips
          Expanded(
            child: ListView(
              children: containers,
            ),
          ),
        ],
      ),
    );
  }
}
