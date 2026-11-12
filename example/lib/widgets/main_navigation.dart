import 'package:flutter/material.dart';
import 'package:telematics_sdk_example/screens/patientUI/patient_home_screen.dart';
import 'package:telematics_sdk_example/screens/patientUI/settings_screen.dart'
    as patient;
import 'package:telematics_sdk_example/screens/physicianUI/physician_home_screen.dart';
import 'package:telematics_sdk_example/screens/physicianUI/physician_settings_screen.dart'
    as physician;

/// Bottom navigation shell that switches between Home and Settings in place.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, required this.pages});

  MainNavigation.patient({Key? key})
      : this(key: key, pages: [PatientHomeScreen(), patient.SettingsScreen()]);

  MainNavigation.physician({Key? key})
      : this(
            key: key,
            pages: [const PhysicianHomeScreen(), physician.SettingsScreen()]);

  final List<Widget> pages;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: widget.pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 103, 139, 183),
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
