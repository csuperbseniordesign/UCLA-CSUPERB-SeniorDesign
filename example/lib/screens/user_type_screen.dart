import 'package:flutter/material.dart';
import 'package:telematics_sdk_example/screens/patientUI/sign_in_screen.dart';
import 'package:telematics_sdk_example/screens/patientUI/patient_home_screen.dart';
import 'package:telematics_sdk_example/screens/physicianUI/physician_sign_in_screen.dart';

const _sizedBoxSpace = SizedBox(height: 50);

class UserTypePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(30.0), // here the desired height
          child: AppBar(
              // ...
              ),
        ),
        body: Stack(
          children: [
            Center(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  Icon(Icons.medical_information, size: 100),
                  new SizedBox(
                    width: 200.0,
                    height: 150.0,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PhysicianSignInScreen()));
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: (Color.fromARGB(255, 4, 27, 63)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                      ),
                      child: const Text(
                        'PHYSICIAN PORTAL',
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  _sizedBoxSpace,
                  Icon(Icons.person, size: 100),
                  new SizedBox(
                    width: 200.0,
                    height: 150.0,
                    child: FilledButton(
                      onPressed: () {
                         Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PatientSignInScreen()));
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 103, 139, 183),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                      ),
                      child: const Text(
                        'PATIENT PORTAL',
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
