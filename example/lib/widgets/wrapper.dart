import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:telematics_sdk_example/screens/patientUI/patient_home_screen.dart';
import 'package:telematics_sdk_example/screens/physicianUI/physician_home_screen.dart';
import 'package:telematics_sdk_example/screens/welcome_screen.dart';

class Wrapper extends StatelessWidget {
  Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error"));
          } else if (snapshot.data == null) {
            return WelcomeScreen();
          } else {
            return _buildHomeForUser(snapshot.data!.uid);
          }
        },
      ),
    );
  }

  Widget _buildHomeForUser(String uid) {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('patients/$uid').onValue,
      builder: (context, patientSnapshot) {
        if (patientSnapshot.hasError) {
          return const Center(child: Text('Could not retrieve user role.'));
        }

        if (patientSnapshot.data?.snapshot.exists == true) {
          return PatientHomeScreen();
        }

        return StreamBuilder<DatabaseEvent>(
          stream: FirebaseDatabase.instance.ref('physicians/$uid').onValue,
          builder: (context, physicianSnapshot) {
            if (physicianSnapshot.hasError) {
              return const Center(child: Text('Could not retrieve user role.'));
            }

            if (physicianSnapshot.data?.snapshot.exists == true) {
              return PhysicianHomeScreen();
            }

            if (patientSnapshot.connectionState == ConnectionState.waiting ||
                physicianSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return WelcomeScreen();
          },
        );
      },
    );
  }
}
