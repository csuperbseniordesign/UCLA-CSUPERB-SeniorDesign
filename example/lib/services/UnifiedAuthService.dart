import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telematics_sdk_example/services/user.dart';
import 'package:telematics_sdk_example/services/telematics_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:telematics_sdk/telematics_sdk.dart';
import 'fire_fetch.dart';

class UnifiedAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TelematicsService _telematicsService = TelematicsService();
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final TrackingApi _trackingApi = TrackingApi();

  // Add these at the top of the class with other static variables
  static DateTime? _lastLoginAttempt;
  static const Duration _minLoginInterval =
      Duration(seconds: 30); // More conservative rate limit
  static Map<String, dynamic> _loginCache = {};

  // helper function to convert Damoov's duration (in seconds) to UTC timestamp
  String accessTokenExpiresAt(int expiresIn) {
    return DateTime.now()
        .toUtc()
        .add(Duration(seconds: expiresIn))
        .toIso8601String();
  }

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
          // Store expiration inside firebase record
          'accessTokenExpiresAt': accessTokenExpiresAt(tokenResponse.expiresIn),
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
          // Store expiration inside firebase record
          'accessTokenExpiresAt': accessTokenExpiresAt(tokenResponse.expiresIn),
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

    try {
      DatabaseEvent event = await ref.once();

      // Debugging: Check if data exists
      if (!event.snapshot.exists) {
        print("No data found at 'physicians' node.");
        return items;
      }

      print("Raw snapshot value: ${event.snapshot.value}");

      Map<dynamic, dynamic> physicians =
          event.snapshot.value as Map<dynamic, dynamic>;

      physicians.forEach((key, value) {
        // Debugging: Check each entry
        print("Processing physician: $key -> $value");

        // Ensure value contains expected fields
        if (value is Map &&
            value.containsKey('firstName') &&
            value.containsKey('lastName')) {
          String fullName = '${value['firstName']} ${value['lastName']}';
          items.add(
            DropdownMenuItem(
              value: key,
              child: Text(fullName),
            ),
          );
        } else {
          print("Skipping invalid physician entry: $key -> $value");
        }
      });
    } catch (e) {
      print("Error fetching physicians: $e");
    }

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


  // Update the getDeviceTokenForUser method
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
          // Try to login and get access token
          var loginResponse = await login(deviceToken, instanceId: instanceId);

          if (loginResponse != null) {
            if (isNewUser) {
              _trackingApi.showPermissionWizard(
                  enableAggressivePermissionsWizard: false,
                  enableAggressivePermissionsWizardPage: true);
            }

            // Update tokens in Firebase if they were returned
            if (loginResponse['Result'] != null) {
              String newAccessToken =
                  loginResponse['Result']['AccessToken']['Token'];
              String newRefreshToken = loginResponse['Result']['RefreshToken'];
              // include expiresIn if returned
              int expiresIn = int.parse(
                loginResponse['Result']['AccessToken']['ExpiresIn'].toString(),
              );

              await FirebaseDatabase.instance.ref('patients/$uid').update({
                'accessToken': newAccessToken,
                'refreshToken': newRefreshToken,
                'accessTokenExpiresAt': accessTokenExpiresAt(expiresIn),
              });
            }

            await initializeAndStartTracking(deviceToken!);
            return deviceToken;
          } else {
            print("Failed to login with device token");
            return null;
          }
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

  // Method to login to Damoov with proper headers and rate limiting
  Future<Map<String, dynamic>?> login(String? userId,
      {required String instanceId}) async {
    String? instanceKey = await fireFetch('InstanceKey');

    if (userId == null) {
      print("User ID is null. Cannot login.");
      return null;
    }

    // Check cache first
    String cacheKey = '${userId}_${instanceId}';
    if (_loginCache.containsKey(cacheKey)) {
      print("Using cached login response");
      return _loginCache[cacheKey];
    }

    // Check if we've attempted a login recently
    if (_lastLoginAttempt != null) {
      final timeSinceLastLogin = DateTime.now().difference(_lastLoginAttempt!);
      if (timeSinceLastLogin < _minLoginInterval) {
        print(
            'Too many login attempts. Please wait ${_minLoginInterval.inSeconds} seconds.');
        return null;
      }
    }

    try {
      _lastLoginAttempt = DateTime.now();
      var url = Uri.parse('https://user.telematicssdk.com/v1/Auth/Login');

      // Get the instance key

      if (instanceKey == null || instanceKey.isEmpty) {
        print("Failed to get instance key in auth login");
        return null;
      }

      var headers = {
        'accept': 'application/json',
        'content-type': 'application/json',
        'InstanceId': instanceId,
      };

      var body = jsonEncode({
        'LoginFields': {"Devicetoken": userId},
        'Password': instanceKey // Use the instance key from Firestore
      });

      var response = await http.post(url, headers: headers, body: body).timeout(
        Duration(seconds: 10), // Add timeout
        onTimeout: () {
          print("Login request timed out");
          throw TimeoutException('Login request timed out');
        },
      );

      if (response.statusCode == 200) {
        print("Login successful");
        Map<String, dynamic> data = jsonDecode(response.body);

        // Cache the successful response
        _loginCache[cacheKey] = data;

        return data;
      } else {
        print('Failed to login, status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // Method to clear login cache (use when needed)
  static void clearLoginCache() {
    _loginCache.clear();
    _lastLoginAttempt = null;
    print("Login cache cleared");
  }

  // Method to reset passsword (Firebase side)
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print("Password reset email sent to $email");
    } catch (e) {
      print("Failed to send password reset email: $e");
      rethrow;
      // Handle the error appropriately
    }
  }

  // Method to change the current user's email
  Future<void> changeEmail(String newEmail) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.verifyBeforeUpdateEmail(newEmail);
        print("Email verification sent to $newEmail");
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

  // Loads the patient's current Damoov access token and refreshes it when it
  // is missing, inside the 12-hour safety window, or explicitly expired.
  // Keeping this here means screens do not need to manage token lifetimes.
  Future<String?> getValidAccessToken(String patientId,
      {bool forceRefresh = false}) async {
    final snapshot = await _database.ref('patients/$patientId').get();
    final data = snapshot.value as Map<dynamic, dynamic>?;

    final currentAccessToken = data?['accessToken']?.toString();
    final currentRefreshToken = data?['refreshToken']?.toString();
    final expiresAtValue = data?['accessTokenExpiresAt']?.toString();

    if (currentAccessToken == null || currentAccessToken.isEmpty) {
      return null;
    }

    final expiresAt = expiresAtValue == null
        ? null
        : DateTime.tryParse(expiresAtValue)?.toUtc();
    final refreshThreshold =
        DateTime.now().toUtc().add(const Duration(hours: 12));
    final shouldRefresh = forceRefresh ||
        expiresAt == null ||
        !expiresAt.isAfter(refreshThreshold);

    // The existing access token is still usable when it is outside the
    // refresh window, so avoid making an unnecessary network request.
    if (!shouldRefresh || currentRefreshToken == null) {
      return currentAccessToken;
    }

    final instanceId = await fireFetch('InstanceId');
    if (instanceId == null || instanceId.isEmpty) {
      return currentAccessToken;
    }

    final refreshResponse = await refreshToken(
      currentAccessToken,
      currentRefreshToken,
      instanceId,
    );

    final result = refreshResponse?['Result'];
    final accessTokenResult = result?['AccessToken'];
    if (accessTokenResult == null || result?['RefreshToken'] == null) {
      return currentAccessToken;
    }

    final newAccessToken = accessTokenResult['Token']?.toString();
    final newRefreshToken = result['RefreshToken']?.toString();
    final expiresIn = int.tryParse(accessTokenResult['ExpiresIn'].toString());

    if (newAccessToken == null ||
        newRefreshToken == null ||
        expiresIn == null) {
      return currentAccessToken;
    }

    await updateTokensInFirebase(
      patientId,
      newAccessToken,
      newRefreshToken,
      expiresIn,
    );
    return newAccessToken;
  }

  // accumulated totals
  Future<List<String>> fetchStatistics(String patientId) async {
    var client = http.Client();
    List<String> statistics = ['0', '0', '0']; // Default values

    try {
      // Get current date for the date range
      DateTime now = DateTime.now();
      DateTime thirtyDaysAgo = now.subtract(Duration(days: 30));

      String startDate = thirtyDaysAgo.toIso8601String().split('T')[0];
      String endDate = now.toIso8601String().split('T')[0];

      print("Fetching statistics from $startDate to $endDate");

      var url =
          Uri.parse('https://api.telematicssdk.com/indicators/v2/statistics')
              .replace(queryParameters: {
        'startDate': startDate,
        'endDate': endDate
      });

      final authToken = await getValidAccessToken(patientId);
      if (authToken == null) {
        print("No Damoov access token found for patient $patientId");
        return statistics;
      }

      Future<http.Response> request(String token) {
        return client.get(
          url,
          headers: {
            'accept': 'application/json',
            'authorization': 'Bearer $token',
          },
        );
      }

      print("Making request to: $url");
      var response = await request(authToken);

      // If the token was rejected despite the expiration check, force one
      // refresh and retry the original request once.
      if (response.statusCode == 401) {
        final refreshedToken = await getValidAccessToken(
          patientId,
          forceRefresh: true,
        );
        if (refreshedToken != null) {
          response = await request(refreshedToken);
        }
      }

      print("Statistics response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data["Result"] != null) {
          String tripCount =
              (data["Result"]["DriverTripsCount"] ?? 0).toString();

          double mileage = (data["Result"]["MileageMile"] ?? 0).toDouble();
          String totalMiles = mileage.toStringAsPrecision(4);

          double time = (data["Result"]["DrivingTime"] ?? 0).toDouble();
          String drivingTime = time.toStringAsPrecision(4);

          statistics = [tripCount, totalMiles, drivingTime];
          print("Successfully fetched statistics: $statistics");
        } else {
          print("No result data in response");
        }
      } else {
        print(
            'Failed to fetch statistics, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching statistics: $e');
    } finally {
      client.close();
    }
    return statistics;
  }

  // accumulated scores
  Future<List<String>> fetchScores(String patientId) async {
    var client = http.Client();
    List<String> scores = [];
    String accelerationScore = "";
    String brakingScore = "";
    String speedingScore = "";
    String corneringScore = "";
    String phoneScore = "";
    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 365));
      var url =
          Uri.parse('https://api.telematicssdk.com/indicators/v2/Scores/safety')
              .replace(queryParameters: {
        'startDate': start.toIso8601String().split('T')[0],
        'endDate': now.toIso8601String().split('T')[0],
      });

      final authToken = await getValidAccessToken(patientId);
      if (authToken == null) {
        print("No Damoov access token found for patient $patientId");
        return scores;
      }

      Future<http.Response> request(String token) {
        return client.get(
          url,
          headers: {
            'accept': 'application/json',
            'authorization': 'Bearer $token',
          },
        );
      }

      var response = await request(authToken);

      // Use the same one-refresh, one-retry behavior as statistics.
      if (response.statusCode == 401) {
        final refreshedToken = await getValidAccessToken(
          patientId,
          forceRefresh: true,
        );
        if (refreshedToken != null) {
          response = await request(refreshedToken);
        }
      }
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data["Result"] != null) {
          accelerationScore =
              double.parse(data["Result"]["AccelerationScore"].toString())
                  .round()
                  .toString();
          brakingScore = double.parse(data["Result"]["BrakingScore"].toString())
              .round()
              .toString();
          speedingScore =
              double.parse(data["Result"]["SpeedingScore"].toString())
                  .round()
                  .toString();
          corneringScore =
              double.parse(data["Result"]["CorneringScore"].toString())
                  .round()
                  .toString();
          phoneScore =
              double.parse(data["Result"]["PhoneUsageScore"].toString())
                  .round()
                  .toString();
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
            'Failed to fetch daily statistics in auth service, status code: ${response.statusCode}');
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

  static Future<Map<String, String>?> refreshAccessToken(
      String refreshToken) async {
    var client = http.Client();
    try {
      var url = Uri.parse('https://api.telematicssdk.com/auth/refresh');

      final response = await client.post(
        url,
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'access_token': data['access_token'] ?? '',
          'refresh_token': data['refresh_token'] ??
              refreshToken, // Keep old refreshToken if new one is not provided
        };
      } else {
        print('Failed to refresh token: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    } finally {
      client.close();
    }
  }

  static Future<void> updateTokensInFirebase(String patientId,
      String newAccessToken, String newRefreshToken, int expiresIn) async {
    final accessTokenExpiresAt = DateTime.now()
        .toUtc()
        .add(Duration(seconds: expiresIn))
        .toIso8601String();

    await FirebaseDatabase.instance.ref('patients/$patientId').update({
      'accessToken': newAccessToken,
      'refreshToken': newRefreshToken,
      'accessTokenExpiresAt': accessTokenExpiresAt,
    });
  }

  Future<Map<String, dynamic>?> refreshToken(
      String accessToken, String refreshToken, String instanceId) async {
    try {
      var url =
          Uri.parse('https://user.telematicssdk.com/v1/Auth/RefreshToken');

      var headers = {
        'accept': 'application/json',
        'content-type': 'application/json',
        'InstanceId': instanceId,
      };

      var body = jsonEncode({
        'AccessToken': accessToken,
        'RefreshToken': refreshToken,
      });

      var response = await http.post(url, headers: headers, body: body).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print("Damoov token refresh request timed out");
          throw TimeoutException('Refresh token request timed out');
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        // Damoov returns a new access token, refresh token, and expiration.
        if (data['Result'] != null &&
            data['Result']['AccessToken'] != null &&
            data['Result']['RefreshToken'] != null &&
            data['Result']['AccessToken']['ExpiresIn'] != null) {
          print("Token refresh successful!");
          print(
              "New access token will expire in: ${data['Result']['AccessToken']['ExpiresIn']} seconds");
          return data;
        } else {
          print("Unexpected response format");
          print("Response data structure is invalid");
          return null;
        }
      } else if (response.statusCode == 400) {
        print('Invalid refresh token');
        return null;
      } else if (response.statusCode == 401) {
        print('Unauthorized - refresh token may be expired');
        return null;
      } else {
        print('Failed to refresh token, status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during token refresh: $e');
      return null;
    }
  }
}
