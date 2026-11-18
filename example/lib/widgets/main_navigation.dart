import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telematics_sdk_example/screens/onboarding_screen.dart';
import 'package:telematics_sdk_example/screens/patientUI/patient_home_screen.dart';
import 'package:telematics_sdk_example/screens/patientUI/settings_screen.dart'
    as patient;
import 'package:telematics_sdk_example/screens/physicianUI/physician_home_screen.dart';
import 'package:telematics_sdk_example/screens/physicianUI/physician_settings_screen.dart'
    as physician;
 
/// Bottom navigation shell that switches between Home and Settings in place.
class MainNavigation extends StatefulWidget {
  const MainNavigation(
      {super.key, required this.pages, this.isPhysician = false});
 
  MainNavigation.patient({Key? key})
      : this(key: key, pages: [PatientHomeScreen(), patient.SettingsScreen()]);
 
  MainNavigation.physician({Key? key})
      : this(
            key: key,
            pages: [const PhysicianHomeScreen(), physician.SettingsScreen()],
            isPhysician: true);
 
  final List<Widget> pages;
  final bool isPhysician;
 
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}
 
class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
 
  // Sign in can build MainNavigation twice (once from Wrapper and once from
  // the sign in screen), so this stops onboarding from opening twice.
  static bool _onboardingOpen = false;
 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOnboardingIfNew());
  }
 
  Future<void> _showOnboardingIfNew() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _onboardingOpen) return;
 
    final seen = await OnboardingScreen.hasSeen(user.uid);
    if (seen || !mounted || _onboardingOpen) return;
 
    _onboardingOpen = true;
    await Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => OnboardingScreen(
        userId: user.uid,
        isPhysician: widget.isPhysician,
      ),
    ));
    _onboardingOpen = false;
  }
 
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
