import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telematics_sdk_example/screens/welcome_screen.dart';
import 'package:telematics_sdk_example/services/auth.dart';
import 'package:telematics_sdk_example/screens/patientUI/settings/patient_profile_screen.dart';
import 'package:telematics_sdk_example/screens/patientUI/patient_home_screen.dart';
import 'package:telematics_sdk_example/screens/patientUI/settings/about_app_screen.dart';
import 'package:telematics_sdk_example/screens/patientUI/settings/privacy_policy_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:telematics_sdk/telematics_sdk.dart';

final User? user = Auth().currentUser;
var uid;
var deviceToken;
final _trackingApi = TrackingApi();

final _form = Uri.parse(
    "https://docs.google.com/forms/d/e/1FAIpQLSclhBb5DnICnhiNHHUN4dH29fQDj1qmsDD9t74RzsKiE19bzg/viewform?usp=header");

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PatientHomeScreen()));
        // context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    });
  }

  Future<void> updatePassword(String password) async {
    try {
      await user?.updatePassword(password);
    } on FirebaseAuthException catch (e) {
      setState(() {
        print(e.message);
      });
    }
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_form)) {
      throw Exception('Could not launch $_form');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        //  Expanded(
        ListView(children: [
          const SizedBox(height: 20),
          Text(
            "Settings",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          const ListTile(
            title: Text(
              'Account',
              style: TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 2, 80, 168)),
            ),
            dense: true,
          ),
          ListTile(
            leading: Icon(Icons.person_2_outlined),
            title: Text('Edit Profile'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PatientProfileScreen()));
            },
          ),
          const SizedBox(height: 30),
          const ListTile(
            title: Text(
              'Information',
              style: TextStyle(
                color: Color.fromARGB(255, 2, 80, 168),
                fontSize: 16,
              ),
            ),
            dense: true,
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About App'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutAppScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Privacy Statement'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrivacyPolicyScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.data_exploration_sharp),
            title: Text('Request My Data'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () async {
              _launchUrl();
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.only(top: 100, left: 150),
            title: Text('Sign Out',
                style: TextStyle(color: Colors.red, fontSize: 18)),
            onTap: () async {
              await _trackingApi.clearDeviceID();

              // new
              _trackingApi.setEnableSdk(enable: false);
              print('sdk disabled');
              _trackingApi.setDisableTracking(value: true);
              print('tracking disabled');

              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => WelcomeScreen()));

              print('Logout');
            },
          ),
        ]),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 103, 139, 183),
        onTap: _onItemTapped,
      ),
    );
  }
}
