import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenResponse {
  final String deviceToken;
  final String accessToken;
  final String refreshToken;

  TokenResponse(
      {this.deviceToken = '', this.accessToken = '', this.refreshToken = ''});
}

class TelematicsService {
  Future<TokenResponse> registerUser({
    // required String firstName,
    // required String lastName,
    // required String phone,
    required String email,
    required String instanceId,
    required String instanceKey,
    // required String clientId,
  }) async {
    const String url = "https://user.telematicssdk.com/v1/Registration/create";

    var body = jsonEncode({
      // "FirstName": firstName,
      // "LastName": lastName,
      // "Phone": phone,
      "Email": email,
      // "UserFields": {"ClientId": clientId},
    });
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "accept": "application/json",
          "InstanceId": instanceId,
          "InstanceKey": instanceKey,
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print("Registration successful");

        var responseData = json.decode(response.body);

        print(responseData['Result']['DeviceToken']);

        return TokenResponse(
          deviceToken: responseData['Result']['DeviceToken'],
          accessToken: responseData['Result']['AccessToken']['Token'],
          refreshToken: responseData['Result']['RefreshToken'],
        );
      } else {
        // Handle error
        throw Exception('Failed to register user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception occurred during registration: $e');
    }
  }

  Future<Map<String, dynamic>> loginWithDeviceToken(String deviceToken,
      {required String instanceKey, required instanceId}) async {
    var body = jsonEncode({
      "LoginFields": "{\"DeviceToken\":\"$deviceToken\"}",
      "Password": instanceKey,
    });

    var response = await http.post(
      Uri.parse('https://user.telematicssdk.com/v1/Auth/Login'),
      headers: {
        "accept": "application/json",
        "InstanceId": instanceId,
        "content-type": "application/json",
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      var data = json.decode(response.body);
      return {
        'accessToken': data['accessToken'],
        'refreshToken': data['refreshToken'],
      };
    } else {
      // Handle error or invalid response
      print("Login failed: ${response.body}");
      throw Exception(
          'Failed to login with device token: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getUserProfile({
    required String instanceId,
    required String instanceKey,
    required String accessToken,
  }) async {
    var url = Uri.parse(
        'https://user.telematicssdk.com/v1/path-to-user-profile-endpoint'); // Replace with actual endpoint URL
    var headers = {
      'accept': 'application/json',
      'InstanceId': instanceId,
      'InstanceKey': instanceKey,
      'Authorization': 'Bearer $accessToken',
      'content-type': 'application/json',
    };

    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var user = json.decode(response.body);
        return user; // Assuming the response is a JSON object representing the user
      } else {
        throw Exception('Failed to get user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }
}
