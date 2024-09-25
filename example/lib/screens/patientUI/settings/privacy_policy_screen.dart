import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);
  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _customTileExpanded = false;

  Widget _header(){
    return  Container(
     padding: EdgeInsets.only(
      // left: 20,
       bottom: 5, // Space between underline and text
     ),
     decoration: BoxDecoration(
         border: Border(bottom: BorderSide(
         color: const Color.fromARGB(255, 0, 0, 0), 
         width: 1.0, // Underline thickness
        ))
      ),
     child: Text(
        "PRIVACY STATEMENT",
        textAlign: TextAlign.center,
        style: TextStyle(
        color: Colors.black,
        fontSize:25,
        fontWeight: FontWeight.bold,
        // align
        ),
       ),
      );
  }
  Widget _tile() {
    return ExpansionTile(
      title: const Text('1. Introduction'),
      // subtitle: const Text('Custom expansion arrow icon'),
      children: const <Widget>[
        ListTile(subtitle: Text('[app name] is intended for use as a glaucoma monitoring tool for individuals with mild to moderate glaucoma. [app name] is a clinical tool and, thus, is committed to the protection of user privacy. The following document contains a composite of information to help users—both patient and physician—understand both the data collected from them and the ways in which the data is utilized.')),
      ],
      onExpansionChanged: (bool expanded) {
        setState(() {
          _customTileExpanded = expanded;
        });
      },
    );
  }

   Widget _tile2() {
    return ExpansionTile(
      title: const Text('2. Types of Personal Data Collected'),
      // subtitle: const Text('Custom expansion arrow icon'),
      children: const <Widget>[
        ListTile(subtitle: Text("To provide the best service as a glaucoma monitoring and severity detection tool, [app name] collects the following information.")),
        ListTile(subtitle:Text("\nPersonal Information", style: TextStyle(fontWeight: FontWeight.bold))),
        ListTile(subtitle: Text("The following personal information is collected from patients:\n \n• Email\n\nAn email address provides a method of communication with the user in emergencies (i.e., the user should visit their clinician immediately due to a rapid progression of their symptoms) or the retrieval of forgotten credentials. An email address additionally provides a unique identifier associated with each account.")),
        ListTile(subtitle: Text("\nThe following personal information can optionally be provided by patients to further assist the detection algorithm:\n\n• Age\n• Sex\n\nThe literature on predictive factors of glaucoma has shown that elderly individuals and females are more likely to develop glaucoma.\n\nThe following personal information is collected from physicians:\n\n• Email \n• Full name \n• Clinic name \n• Physician credentials\n• Phone number\n\nAn email address provides a method of communication with the user and a unique identifier associated with each account. Full name, clinic name, and physician credentials are used to verify an individual’s identity as a physician.")),
        ListTile(subtitle:Text("\nDriving Statistics", style: TextStyle(fontWeight: FontWeight.bold))),
        ListTile(subtitle: Text("The following data is collected from a user’s smartphone during an automatically-detected driving event: \n\n• Triaxial accelerometer streams\n• Gyroscope streams \n\nThis data is used to quantify device acceleration and rotation, which will be fed into algorithms that subsequently determine driving events.")),
      ],
      onExpansionChanged: (bool expanded) {
        setState(() {
          _customTileExpanded = expanded;
        });
      },
    );
  }

   Widget _tile3() {
    return ExpansionTile(
      title: const Text('3. Policy on Collecting Sensitive Personal Information'),
      // subtitle: const Text('Custom expansion arrow icon'),
      children: const <Widget>[
        ListTile(subtitle: Text("Sensitive personal information—including the user’s social security number, driver's license number, race, ethnicity, or religion—is not collected.")),
      ],
      onExpansionChanged: (bool expanded) {
        setState(() {
          _customTileExpanded = expanded;
        });
      },
    );
  }

   Widget _tile4() {
    return ExpansionTile(
      title: const Text('4. How the Collected Information is Used'),
      // subtitle: const Text('Custom expansion arrow icon'),
      children: const <Widget>[
        ListTile(subtitle: Text("Personal contact information (i.e., email) is used for communication between [app name] and the patient. Optional personal information (i.e., age and sex) is used to provide more accurate monitoring of glaucoma progress. Raw smartphone sensor data is used to determine driving events that subsequently inform a user’s glaucoma severity.\n\nPersonal contact information (i.e., email) is used for communication between [app name] and the physician. Full name, clinic name, and physician credentials are used to verify that an individual is a physician.")),
      ],
      onExpansionChanged: (bool expanded) {
        setState(() {
          _customTileExpanded = expanded;
        });
      },
    );

  } 

  Widget _tile5() {
    return ExpansionTile(
      title: const Text('5. Length of Time Personal Information is Stored'),
      // subtitle: const Text('Custom expansion arrow icon'),
      children: const <Widget>[
        ListTile(subtitle: Text("The user’s email and optionally provided personal information will be stored as long as the user does not delete their account. Raw sensor data will be stored for three months.")),
      ],
      onExpansionChanged: (bool expanded) {
        setState(() {
          _customTileExpanded = expanded;
        });
      },
    );
  }

Widget _tile6() {
    return ExpansionTile(
      title: const Text('6. Who the Information is Shared With'),
      children: const <Widget>[
        ListTile(subtitle: Text("Personal and sensor data are not shared with third parties.")),
      ],
      onExpansionChanged: (bool expanded) {
        setState(() {
          _customTileExpanded = expanded;
        });
      },
    );
  }

  Widget _tile7() {
    return ExpansionTile(
      title: const Text('7. Data Security'),
      children: const <Widget>[
        ListTile(subtitle: Text("User data is encrypted, double-blinded, and stored on HIPPA-compliant servers. Users should be aware, however, that while many safeguards are in place, malicious actors and data leaks may occur.")),
        ListTile(subtitle: Text("\nAbility to decline to provide personal information", style: TextStyle(fontWeight: FontWeight.bold))), 
       ListTile(subtitle: Text("Users may decline to provide personal information, including sensor data. However, declining to provide data—including one’s email and sensor data—may lead to the complete or partial non-functionality of the application (i.e., inability to create an account or potentially inaccurate calculations).")), 
       ListTile(subtitle: Text("Ability to request personal information",  style: TextStyle(fontWeight: FontWeight.bold))), 
       ListTile(subtitle: Text("Users may request to view their collected sensor data in compliance with the California Consumer Privacy Act.")), 
       ListTile(subtitle: Text("\nAbility to request deletion of personal information", style: TextStyle(fontWeight: FontWeight.bold))),
       ListTile(subtitle: Text("Users may decline to delete collected data in compliance with the California Consumer Privacy Act. However, users should be aware that deleting the email data is akin to deleting the account, as the email acts as a unique identification key for each account.")),
      ],
      onExpansionChanged: (bool expanded) {
        setState(() {
          _customTileExpanded = expanded;
        });
      },
    );
  }

  Widget _tile8() {
    return ExpansionTile(
      title: const Text('8. Additional Questions'),
      children: const <Widget>[
        ListTile(subtitle: Text("Please contact cscsulaseniordesign@gmail.com with any questions regarding this privacy policy. A representative from [app name] will address your inquiries within 48 hours.")),
      ],
      onExpansionChanged: (bool expanded) {
        setState(() {
          _customTileExpanded = expanded;
        });
      },
    );
  }

   Widget _tile9() {
    return ExpansionTile(
      title: const Text('9. Policy Update'),
      children: const <Widget>[
        ListTile(subtitle: Text("This privacy policy was last updated on February 26th, 2024. Should any updates occur to the privacy policy, all users will be notified of the change through the email associated with their account. This privacy policy is effective immediately upon publishment.")),
      ],
      onExpansionChanged: (bool expanded) {
        setState(() {
          _customTileExpanded = expanded;
        });
      },
    );
  }

  Widget _disclaimer(){
    return Text("\nBy signing up for an account and using [appName], you acknowledge and agree to our use of the collected data.", textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.bold));
    // return Text("\nBy signing up for an account and using [appName], you agree to our use of the collected data.", );
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: 
        // CustomScrollView()
        ListView(
          // padding:, 
          children:  <Widget>[
          _header(),
            
            Padding(padding: EdgeInsets.only(bottom:30)),
            _tile(),
            _tile2(),
            _tile3(),
            _tile4(),
            _tile5(),
            _tile6(),
            _tile7(),
            _tile8(),
            _tile9(),
            _disclaimer(),
            // _lastUpdated()
            //  Container(child: Text("t"),)
          ]
        ),
       
        );
    // );
    // return Column(
  }
}
