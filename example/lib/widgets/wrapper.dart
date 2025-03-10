import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telematics_sdk_example/screens/patientUI/patient_home_screen.dart';
import 'package:telematics_sdk_example/screens/physicianUI/physician_home_screen.dart';
import 'package:telematics_sdk_example/screens/welcome_screen.dart';
import 'package:telematics_sdk_example/services/UnifiedAuthService.dart';

class Wrapper extends StatelessWidget {
  final UnifiedAuthService _auth = UnifiedAuthService();

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
            return FutureBuilder<String?>(
              future: _auth.checkUserRole(snapshot.data!.uid),  
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (roleSnapshot.hasError || roleSnapshot.data == null || roleSnapshot.data!.isEmpty) {
                  print("Could not retrieve role.");
                  return WelcomeScreen(); 
                } else {
                  String role = roleSnapshot.data!;
                  print('User role: $role');

                  if (role == 'Patient') {
                    return PatientHomeScreen();
                  } else if (role == 'Physician') {
                    return PhysicianHomeScreen();
                  } else {
                    print("Unknown role: $role");
                    return WelcomeScreen();
                  }
                }
              },
            );
          }
        },
      ),
    );
  }
}
