import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telematics_sdk_example/services/user.dart';
import 'package:telematics_sdk_example/services/telematics_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:telematics_sdk/telematics_sdk.dart';

class UnifiedAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TelematicsService _telematicsService = TelematicsService();
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final TrackingApi _trackingApi = TrackingApi();

  // final String instanceId = "5ad66859-5074-4a69-8593-5f46a0d1aa39";
  // final String instanceKey = "7327c2db-cde2-4400-b083-57fcc907f84c";

  // Converts Firebase User to custom AppUser
  AppUser? _userFromFirebaseUser(User? user) {
    return user != null ? AppUser(uid: user.uid) : null;
  }

  // Register with email, password, and user details for telematics
  Future<AppUser?> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String clientId,
    required String instanceId,
    required String instanceKey,
  }) async {
    try {
      // Firebase Authentication to create user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = result.user;

      // Register user in telematics system
      TokenResponse tokenResponse = await _telematicsService.registerUser(
        // firstName: firstName,
        // lastName: lastName,
        // phone: phone,
        email: email, instanceId: instanceId, instanceKey: instanceKey,
        // clientId: clientId,
      );

      // Store telematics tokens and username in Firebase database linked to the user's UID
      if (firebaseUser != null) {
        await _database.ref('userTokens/${firebaseUser.uid}').set({
          'deviceToken': tokenResponse.deviceToken,
          'accessToken': tokenResponse.accessToken,
          'refreshToken': tokenResponse.refreshToken,
        });
      }

      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register with email, password, and user details for telematics
  Future<AppUser?> registerPatient({
    required String email,
    required String password,
    required String gender,
    required String birthday,
    required String physician,
    required String physicianID,
    required String instanceId,
    required String instanceKey,
  }) async {
    try {
      // Firebase Authentication to create user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = result.user;

      // Register user in telematics system
      TokenResponse tokenResponse = await _telematicsService.registerUser(
        // firstName: "",
        email: email,
        instanceId: instanceId,
        instanceKey: instanceKey,
      );

      // Store telematics tokens and username in Firebase database linked to the user's UID
      if (firebaseUser != null) {
        await _database.ref('patients/${firebaseUser.uid}').set({
          'deviceToken': tokenResponse.deviceToken,
          'accessToken': tokenResponse.accessToken,
          'refreshToken': tokenResponse.refreshToken,
          'gender': gender,
          'birthday': birthday,
          'email': email,
          'physician': physician,
          'physicianID': physicianID
        });
      }

      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  late final String? selectedPhysicianUid;

  Future<List<DropdownMenuItem<String>>> getPhysicianDropdownItems() async {
    List<DropdownMenuItem<String>> items = [];
    DatabaseReference ref = FirebaseDatabase.instance.ref('physicians');

    // Only proceed if the user is authenticated
    // User? currentUser = FirebaseAuth.instance.currentUser;
    // if (currentUser != null) {
    try {
      DatabaseEvent event = await ref.once();
      Map<dynamic, dynamic> physicians =
          event.snapshot.value as Map<dynamic, dynamic>;
      physicians.forEach((key, value) {
        String fullName = '${value['firstName']} ${value['lastName']}';
        items.add(
          DropdownMenuItem(
            value: key,
            child: Text(fullName),
          ),
        );
      });
    } catch (e) {
      print(e.toString());
      // Handle errors or return an empty list
    }
    // } else {
    //   // Handle the case where the user is not authenticated
    // }
    return items;
  }

  Future<List<DropdownMenuItem<String>>> getPhysicianDropdownMenu(
      String currentPhysicianId) async {
    List<DropdownMenuItem<String>> items = [];
    DatabaseReference ref = FirebaseDatabase.instance.ref('physicians');

    // Only proceed if the user is authenticated
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DatabaseEvent event = await ref.once();
        Map<dynamic, dynamic> physicians =
            event.snapshot.value as Map<dynamic, dynamic>;
        physicians.forEach((key, value) {
          String firstName = value['firstName'] ?? '';
          String lastName = value['lastName'] ?? '';
          String fullName = '$firstName $lastName'.trim();
          items.add(
            DropdownMenuItem(
              value: key,
              child: Text(fullName),
            ),
          );
        });

        // Find the currently selected physician's UID and set it
        selectedPhysicianUid = currentPhysicianId;
      } catch (e) {
        print(e.toString());
      }
    } else {
      print('No authenticated user found.');
    }

    return items;
  }

  Future<AppUser?> registerPhysician({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String npi,
    required String organizationName,
    required String phone,
  }) async {
    try {
      // Firebase Authentication to create user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = result.user;

      // Store telematics tokens and username in Firebase database linked to the user's UID
      if (firebaseUser != null) {
        // isVerified attribute depends on NPI verificiation
        bool isVerified = await fetchNPPESData(npi, firstName, lastName);

        await _database.ref('physicians/${firebaseUser.uid}').set({
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'npi': npi,
          'organizationName': organizationName,
          'phone': phone,
          'isVerified': isVerified,
        });
      }
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<AppUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Get Device token (Firebase side)
  Future<String?> getDeviceTokenForUser(String? uid, bool isNewUser,
      {required String instanceId}) async {
    if (uid == null) {
      print("UID is null. Cannot retrieve device token.");
      return null;
    }

    DatabaseReference dbRef = FirebaseDatabase.instance.ref('patients/$uid');

    try {
      DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && data.containsKey('deviceToken')) {
          final String? deviceToken = data['deviceToken'];
          print("Device token for UID $uid is: $deviceToken");
          login(deviceToken, instanceId: instanceId);
          if (isNewUser) {
            _trackingApi.showPermissionWizard(
                enableAggressivePermissionsWizard: false,
                enableAggressivePermissionsWizardPage: true);
          } else {}
          initializeAndStartTracking(deviceToken!);
          return deviceToken;
        } else {
          print("Device token not found for UID $uid.");
        }
      } else {
        print("Snapshot does not exist for UID $uid.");
      }
    } catch (e) {
      print(
          "An error occurred while trying to fetch device token for UID $uid: $e");
    }

    return null;
  }

  Future<String?> getPhysician(String? uid) async {
    if (uid == null) {
      print("UID is null. Cannot retrieve Physician.");
      return null;
    }

    DatabaseReference dbRef = FirebaseDatabase.instance.ref('patients/$uid');

    try {
      DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && data.containsKey('physician')) {
          final String? physician = data['physician'];
          print("Physician for UID $uid is: $physician");
          return physician;
        } else {
          print("Physician not found for UID $uid.");
        }
      } else {
        print("Snapshot does not exist for UID $uid.");
      }
    } catch (e) {
      print(
          "An error occurred while trying to fetch physician for UID $uid: $e");
    }

    return null;
  }

  Future<String?> getGender(String? uid) async {
    if (uid == null) {
      print("UID is null. Cannot retrieve Patient Details.");
      return null;
    }

    DatabaseReference dbRef = FirebaseDatabase.instance.ref('patients/$uid');

    try {
      DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && data.containsKey('gender')) {
          final String? gender = data['gender'];
          print("Gender for UID $uid is: $gender");
          return gender;
        } else {
          print("Gender not found for UID $uid.");
        }
      } else {
        print("Snapshot does not exist for UID $uid.");
      }
    } catch (e) {
      print(
          "An error occurred while trying to fetch physician for UID $uid: $e");
    }

    return null;
  }

  Future<String?> getBirthday(String? uid) async {
    if (uid == null) {
      print("UID is null. Cannot retrieve Patient Details.");
      return null;
    }

    DatabaseReference dbRef = FirebaseDatabase.instance.ref('patients/$uid');

    try {
      DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && data.containsKey('birthday')) {
          final String? birthday = data['birthday'];
          print("Birthday for UID $uid is: $birthday");
          return birthday;
        } else {
          print("Birthday not found for UID $uid.");
        }
      } else {
        print("Snapshot does not exist for UID $uid.");
      }
    } catch (e) {
      print(
          "An error occurred while trying to fetch birthday for UID $uid: $e");
    }

    return null;
  }

  Future<bool?> getNPIVerification(String? uid) async {
    if (uid == null) {
      print("UID is null. Cannot retrieve Physician Details.");
      return null;
    }

    DatabaseReference dbRef = FirebaseDatabase.instance.ref('physicians/$uid');

    try {
      DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && data.containsKey('isVerified')) {
          final bool? isVerified = data['isVerified'];
          print("Verification for UID $uid is: $isVerified");
          return isVerified;
        } else {
          print("Gender not found for UID $uid.");
        }
      } else {
        print("Snapshot does not exist for UID $uid.");
      }
    } catch (e) {
      print(
          "An error occurred while trying to fetch physician for UID $uid: $e");
    }

    return null;
  }

  // Method to login to Damoov
  Future<void> login(String? userId, {required String instanceId}) async {
    print('aaaaaaaaaaaaaaaaaaaaaaaaaaaa login');
    var url = Uri.parse('https://user.telematicssdk.com/v1/Auth/Login');

    var headers = {
      'accept': 'application/json',
      'InstanceId': instanceId,
      'content-type': 'application/json',
    };

    var body = jsonEncode({
      'LoginFields': {"Devicetoken": userId},
      'Password': 'b0fafb2a-bd86-408e-87f5-cce93619be2c'
    });

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      // print('Response data: ${response.body}');
    } else {
      // If the server did not return a 200 OK response,
      // print(
      //     'Failed to login, status code: ${response.statusCode}, body: ${response.body}');
      throw Exception(
          'Failed to load data, status code: ${response.statusCode}');
    }
  }

  // Method to reset passsword (Firebase side)
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print("Password reset email sent to $email");
    } catch (e) {
      print("Failed to send password reset email: $e");
      // Handle the error appropriately
    }
  }

  // Method to change the current user's email
  Future<void> changeEmail(String newEmail) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updateEmail(newEmail);
        print("Email updated successfully to $newEmail");
      } catch (e) {
        print("Failed to update email: $e");
        // Handle the error appropriately
      }
    } else {
      print("No user is currently signed in.");
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  AppUser? getCurrentAppUser() {
    return _userFromFirebaseUser(_auth.currentUser);
  }

  Future<void> addPhysician(String physician) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _database
          .ref('patients/${user.uid}')
          .update({'physician': physician});
    }
  }

  Future<void> addBirthday(String birthday) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _database
          .ref('patients/${user.uid}')
          .update({'birthday': birthday});
    }
  }

  Future<void> addGender(String? gender) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _database.ref('patients/${user.uid}').update({'gender': gender});
    }
  }

  // Method to change the current user's password
  Future<void> changePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        print("Password updated successfully.");
      } catch (e) {
        print("Failed to update password: $e");
        // Handle the error appropriately
      }
    } else {
      print("No user is currently signed in.");
    }
  }

  // accumulated totals
  Future<List<String>> fetchStatistics(String authToken) async {
    var client = http.Client();

    List<String> statistics = [];
    String tripCount = "";
    String totalMiles = "";
    String drivingTime = "";
    try {
      var url = Uri.parse(
          'https://api.telematicssdk.com/indicators/v2/statistics?startDate=2024-01-31&endDate=2024-12-31');
      final response = await client.get(
        url,
        headers: {
          'accept': 'application/json',
          'authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data["Result"] != null) {
          tripCount = data["Result"]["DriverTripsCount"].toString();
          totalMiles = data["Result"]["MileageMile"].toString();
          double test = double.parse(totalMiles);
          totalMiles = test.toStringAsPrecision(4);

          drivingTime = data["Result"]["DrivingTime"].toString();
          test = double.parse(drivingTime);
          drivingTime = test.toStringAsPrecision(4);
        } else {
          tripCount = "n/a";
          totalMiles = "n/a";
          drivingTime = "n/a";
        }
        statistics.add(tripCount);
        statistics.add(totalMiles);
        statistics.add(drivingTime);
      } else {
        print(
            'Failed to fetch daily statistics, status code: ${response.statusCode}, response: ${response.body}');
      }
    } catch (e) {
      print('Error fetching daily statistics: $e');
    } finally {
      client.close();
    }
    return statistics;
  }

  // accumulated scores
  Future<List<String>> fetchScores(String authToken) async {
    var client = http.Client();
    List<String> scores = [];
    String accelerationScore = "";
    String brakingScore = "";
    String speedingScore = "";
    String corneringScore = "";
    String phoneScore = "";
    try {
      var url = Uri.parse(
          'https://api.telematicssdk.com/indicators/v2/Scores/safety?startDate=2024-01-31&endDate=2024-12-31');

      final response = await client.get(
        url,
        headers: {
          'accept': 'application/json',
          'authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data["Result"] != null) {
          accelerationScore = data["Result"]["AccelerationScore"].toString();
          brakingScore = data["Result"]["BrakingScore"].toString();
          speedingScore = data["Result"]["SpeedingScore"].toString();
          corneringScore = data["Result"]["CorneringScore"].toString();
          phoneScore = data["Result"]["PhoneUsageScore"].toString();
        } else {
          accelerationScore = "n/a";
          brakingScore = "n/a";
          speedingScore = "n/a";
          corneringScore = "n/a";
          phoneScore = "n/a";
        }
        scores.add(accelerationScore);
        scores.add(brakingScore);
        scores.add(speedingScore);
        scores.add(corneringScore);
        scores.add(phoneScore);
      } else {
        print(
            'Failed to fetch daily statistics, status code: ${response.statusCode}, response: ${response.body}');
      }
    } catch (e) {
      print('Error fetching daily statistics: $e');
    } finally {
      client.close();
    }
    return scores;
  }

  Future<bool> updateNPI(String npi, String firstName, String lastName) async {
    User? user = _auth.currentUser;
    if (user != null) {
      bool isVerified = await fetchNPPESData(npi, firstName, lastName);
      await _database
          .ref('physicians/${user.uid}')
          .update({'npi': npi, 'isVerified': isVerified});
      // print("here");
      return isVerified;
    }
    return false;
  }

  Future<String?> getPhysicianFirstName(String? uid) async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('physicians/$uid');

    try {
      DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && data.containsKey('firstName')) {
          final String? firstName = data['firstName'];
          print("First Name for UID $uid is: $firstName");
          return firstName;
        } else {
          print("First Name not found for UID $uid.");
        }
      } else {
        print("Snapshot does not exist for UID $uid.");
      }
    } catch (e) {
      print(
          "An error occurred while trying to fetch physician for UID $uid: $e");
    }

    return null;
  }

  Future<String?> getPhysicianLastName(String? uid) async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('physicians/$uid');

    try {
      DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && data.containsKey('lastName')) {
          final String? lastName = data['lastName'];
          print("Last Name for UID $uid is: $lastName");
          return lastName;
        } else {
          print("Last Name not found for UID $uid.");
        }
      } else {
        print("Snapshot does not exist for UID $uid.");
      }
    } catch (e) {
      print(
          "An error occurred while trying to fetch physician for UID $uid: $e");
    }

    return null;
  }

  Future<bool> fetchNPPESData(
      String npi, String firstName, String lastName) async {
    try {
      // NPPES API URL
      String apiUrl = 'https://npiregistry.cms.hhs.gov/api/';

      // Make GET request
      Uri uri = Uri.parse('$apiUrl?number=$npi&version=2.1');
      http.Response response = await http.get(uri);

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> data = json.decode(response.body);

        // Access the information you need from the response
        // Making all variables lowercase because it won't process any other way.
        String nppesFirstName = data['results'][0]['basic']['first_name']
            .toString()
            .toLowerCase()
            .trim();
        String nppesLastName = data['results'][0]['basic']['last_name']
            .toString()
            .toLowerCase()
            .trim();
        String userFirstName = firstName.toLowerCase().trim();
        String userLastName = lastName.toLowerCase().trim();

        // Validating that the information matches with the registry.
        if (nppesFirstName == userFirstName) {
          if (nppesLastName == userLastName) {
            return true;
          }
        }
        return false;
      } else {
        // Handle errors
        print('NPPES API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (error) {
      // Handle any exceptions
      print('Error fetching NPPES data: $error');
      return false;
    }
  }

  // Future<List<List<String>>> fetchTrips(String authToken, int tripCount) async {
  //   List<List<String>> trips = [];
  //   List<String> startDates = [];
  //   List<String> endDates = [];
  //   List<String> locations = [];
  //   List<String> driveDuration = [];
  //   List<String> accelerations = [];
  //   List<String> brakings = [];
  //   List<String> cornerings = [];
  //   List<String> mileages = [];
  //   List<String> phoneUsages = [];
  //   List<String> nightHours = [];
  //   List<String> avgSpeeds = [];
  //   List<String> sScores = [];
  //    List<String> aScores = [];
  //         List<String> bScores = [];
  //         List<String> cScores = [];
  //         List<String> spScores = [];
  //         List<String> pScores = [];
  //   String startTime = "";
  //   String endTime = "";

  //   try {
  //     final response = await http.post(
  //       Uri.parse('https://api.telematicssdk.com/trips/get/v1/'),
  //       headers: {
  //         'accept': 'application/json',
  //         'content-type': 'application/json',
  //         'authorization': 'Bearer $authToken'
  //       },
  //       body: jsonEncode({
  //         'StartDate': '2024-01-20T09:46:59.265Z',
  //         'EndDate': '2024-09-20T09:46:59.265Z',
  //         'IncludeDetails': true,
  //         'IncludeStatistics': true,
  //         'IncludeScores': true,
  //         'Locale': 'EN',
  //         'UnitSystem': 'Si',
  //         'SortBy': 'StartDateUtc',
  //         'Paging': {'Page': 1, 'Count': 10, 'IncludePagingInfo': true}
  //       }),
  //     );
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> data = jsonDecode(response.body);
  //       if (data["Result"] != null) {
  //         for (int i = 0; i < tripCount; i++) {
  //           List<String> rawStartDate = data["Result"]['Trips'][i]['Data']
  //                   ['StartDate']
  //               .toString()
  //               .split("T");
  //           List<String> t = rawStartDate[1].split("-");

  //           int startHour = int.parse(t[0].substring(0, 2));
  //           if (startHour > 12) {
  //             startHour = startHour - 12;
  //             startTime = rawStartDate[0].substring(5, 7) +
  //                 "-" +
  //                 rawStartDate[0].substring(8, 10) +
  //                 "-" +
  //                 rawStartDate[0].substring(0, 4) +
  //                 " " +
  //                 startHour.toString() +
  //                 t[0].substring(2, 8) +
  //                 " PM";
  //           } else {
  //             startTime = rawStartDate[0].substring(5, 7) +
  //                 "-" +
  //                 rawStartDate[0].substring(8, 10) +
  //                 "-" +
  //                 rawStartDate[0].substring(0, 4) +
  //                 " " +
  //                 startHour.toString() +
  //                 t[0].substring(2, 8) +
  //                 " AM";
  //           }

  //           startDates.add(startTime);

  //           endDates.add("End Date: " +
  //               data["Result"]['Trips'][i]['Data']['EndDate'].toString());

  //           locations.add(data["Result"]['Trips'][i]['Data']['Addresses']
  //                       ['Start']['Full']
  //                   .toString() +
  //               " to " +
  //               data["Result"]['Trips'][i]['Data']['Addresses']['End']['Full']
  //                   .toString());
  //           mileages.add(
  //               double.parse(data["Result"]['Trips'][i]['Statistics']['Mileage']
  //                       .toString())
  //                   .toStringAsPrecision(5) + " km");

  //           accelerations.add(
  //               data["Result"]['Trips'][i]['Statistics']['AccelerationsCount']
  //                   .toString()
  //                   .split(".")[0]);

  //           brakings.add(
  //               data["Result"]['Trips'][i]['Statistics']['BrakingsCount']
  //                   .toString()
  //                   .split(".")[0]);

  //           cornerings.add(
  //               data["Result"]['Trips'][i]['Statistics']['CorneringsCount']
  //                   .toString()
  //                   .split(".")[0]);
  //           phoneUsages.add(
  //               data["Result"]['Trips'][i]['Statistics']
  //                       ['PhoneUsageDurationMinutes']
  //                   .toString() + " min");
  //           nightHours.add(
  //               data["Result"]['Trips'][i]['Statistics']['NightHours']
  //                   .toString() + " hrs");
  //           driveDuration.add(
  //               double.parse(data["Result"]['Trips'][i]['Statistics']
  //                           ['DurationMinutes']
  //                       .toString())
  //                   .toStringAsPrecision(4) + " min");

  //           avgSpeeds.add(
  //               double.parse(data["Result"]['Trips'][i]['Statistics']
  //                           ['AverageSpeed']
  //                       .toString())
  //                   .toStringAsPrecision(5) + " km/hr");

  //           sScores.add(
  //              data["Result"]['Trips'][i]['Scores']['Safety'].toString().split(".")[0]);
  //             aScores.add(
  //              data["Result"]['Trips'][i]['Scores']['Acceleration'].toString().split(".")[0]);
  //           bScores.add(
  //             data["Result"]['Trips'][i]['Scores']['Braking'].toString().split(".")[0]);
  //           cScores.add(
  //              data["Result"]['Trips'][i]['Scores']['Cornering'].toString().split(".")[0]);
  //                 spScores.add(
  //               data["Result"]['Trips'][i]['Scores']['Speeding'].toString().split(".")[0]);
  //                 pScores.add(
  //              data["Result"]['Trips'][i]['Scores']['PhoneUsage'].toString().split(".")[0]);

  //         }
  //       }
  //       trips.add(startDates);
  //       trips.add(endDates);
  //       trips.add(locations);
  //       trips.add(mileages);
  //       trips.add(driveDuration);
  //       trips.add(accelerations);
  //       trips.add(brakings);
  //       trips.add(cornerings);
  //       trips.add(phoneUsages);
  //       trips.add(nightHours);
  //       trips.add(avgSpeeds);
  //       trips.add(sScores);
  //          trips.add(aScores);
  //             trips.add(bScores);
  //                trips.add(cScores);
  //                   trips.add(spScores);
  //                         trips.add(pScores);
  //     } else {
  //       print(
  //           'Failed to fetch daily statistics, status code: ${response.statusCode}, response: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error fetching daily statistics: $e');
  //   }

  //   // return scores;
  //   return trips;
  // }

  // Function to check the user's role
  Future<String> checkUserRole(String uid) async {
    // Check if UID exists under 'physicians' node
    final physicianRef = FirebaseDatabase.instance.ref('physicians/$uid');
    final physicianSnapshot = await physicianRef.get();

    if (physicianSnapshot.exists) {
      return 'Physician';
    }

    // Check if UID exists under 'patients' node
    final patientRef = FirebaseDatabase.instance.ref('patients/$uid');
    final patientSnapshot = await patientRef.get();

    if (patientSnapshot.exists) {
      return 'Patient';
    }

    // User is neither a physician nor a patient, or doesn't exist
    return 'Unknown';
  }

  // Method to initialize and start tracking with the given device token
  Future<void> initializeAndStartTracking(String deviceToken) async {
    try {
      // Set the device token
      await _trackingApi.setDeviceID(deviceId: deviceToken);
      // Enable sdk
      await _trackingApi.setEnableSdk(enable: true);
      // enable high frequency
      await _trackingApi.enableHF(value: true);
      // turn off disable tracking
      await _trackingApi.setDisableTracking(value: false);
    } catch (e) {
      print("Error initializing and starting tracking: $e");
    }
  }
}
