import 'package:flutter/material.dart';

const double aspectRatio = 1 / 1.1;
const edgeInsets = 12.0;

enum Bodies {
  setup,
  homePage,
  userStats,
  acceleration,
  braking,
  speeding,
  cornering,
  phoneUsage,
  tripDetails,
  settingsPage,
  credentials,
  tutorial,
  aboutApp,
  privacyStatement,
}

class Tutorial extends StatefulWidget {
  const Tutorial({super.key});

  @override
  State<StatefulWidget> createState() => TutorialState();
}

class TutorialState extends State<Tutorial> {
  int index = 0;
  var page = Bodies.values.first;
  late Widget body;
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case Bodies.setup:
        body = tutorialStart(
            "Tutorial - Setup",
            "This app will track & collect your patients' driving events "
                "unobtrusively.\n\n"
                "You will be able to view their drives & aggregated driving scores.");
        break;
      case Bodies.homePage:
        body = tutorialBody(
          "Tutorial - Home Page",
          "This page contains a clickable list of patients with their emails and calculated Safety Score.\n\n"
              "The list is sorted alphabetically but may also be sorted by their score. Click on a patient for more drive details.",
          Icons.home_outlined,
        );
        break;
             case Bodies.tutorial:
        body = tutorialBody(
          "Tutorial - Home Page",
          "Tap this icon in the settings page "
              "to navigate to the tutorial "
              "where you can view and get a brief explanation how the UI works.",
          Icons.menu_book,
        );
        break;
      case Bodies.userStats:
        body = tutorialBody(
          "Tutorial - Home Page",
          "Patient Summary\n\n"
          "Clicking a patient allows you to view a breakdown of their summary scores, " 
          "with aggregated scores for acceleration, braking, cornering, phone usage, " 
          "and speeding, as well as their total mileage, hours driven, and number of trips.",
              
          null,
        );
        break;
      case Bodies.acceleration:
        body = tutorialBody(
          "Tutorial - Patient Statistics",
          "Acceleration\n\n"
              "Aggregated score over 2 weeks where patient's accelerations were faster than 9ft/s^2.",
          Icons.track_changes_outlined,
        );
        break;
      case Bodies.braking:
        body = tutorialBody(
          "Tutorial - Patient Statistics",
          "Braking\n\n"
              "Aggregated score over 2 weeks where patient's decelerations were faster than 9ft/s^2.",
          Icons.traffic,
        );
        break;
      case Bodies.speeding:
        body = tutorialBody(
          "Tutorial - Patient Statistics",
          "Speeding\n\n"
              "Aggregated score over 2 weeks where patient's speed is greater than that of the speed limit.",
          Icons.speed,
        );
        break;
      case Bodies.cornering:
        body = tutorialBody(
          "Tutorial - Patient Statistics",
          "Cornering\n\n"
              "Aggregated score over 2 weeks where patient's cornering were faster than 13ft/s^2.",
          Icons.turn_slight_right,
        );
        break;
      case Bodies.phoneUsage:
        body = tutorialBody(
          "Tutorial - Patient Statistics",
          "Phone Usage\n\n"
              "Aggregated score over 2 weeks were patient had phone activity while driving.",
          Icons.system_security_update,
        );
        break;

      case Bodies.tripDetails:
        body = tutorialBody(
          "Tutorial - Trip Details",
          "This page displays detailed data for each of the patient's trips,"
              "including location and scores for acceleration, braking, speeding,"
              "cornering, phone usage, and collision.",
          null,
        );
        break;
      case Bodies.settingsPage:
        body = tutorialBody(
          "Tutorial - Settings Page",
          "Tap this icon at the bottom right corner "
              "to navigate to the Settings Page "
              "where you can edit your profile, "
              "read background on the app, "
              "and view the app's privacy statement.",
          Icons.settings_outlined,
        );
        break;
      case Bodies.credentials:
        body = tutorialBody(
          "Tutorial - Settings Page",
          "Tap this icon in the settings page "
              "to navigate to your profile page "
              "where you can view and manage your credentials.",
          Icons.person_2_outlined,
        );
        break;
      case Bodies.aboutApp:
        body = tutorialBody(
          "Tutorial - Settings Page",
          "Tap this icon in the settings page "
              "to navigate to the About App page "
              "where you can get to know the app's objectives and goals.",
          Icons.info_outline,
        );
        break;
      case Bodies.privacyStatement:
        body = tutorialBody(
          "Tutorial - Settings Page",
          "Tap this icon in the settings page "
              "to review the privacy statement document.",
          Icons.security,
        );
        break;
      default:
        break;
    }
    return body;
  }

  Widget tutorialStart(String title, String body) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(edgeInsets),
      children: [
        AppBar(
          leading: CloseButton(
            color: Color(0xff627CB2),
          ),
          backgroundColor: Colors.transparent,
          title: Text(
            textAlign: TextAlign.center,
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        DefaultTextStyle(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(body),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: const Row(
                        children: [
                          Text(
                            "Next",
                            style: TextStyle(
                              color: Color(0xff627CB2),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Color(0xff627CB2),
                          ),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          page = Bodies.values.indexed.elementAt(++index).$2;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget tutorialBody(String title, String body, IconData? icon) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(edgeInsets),
      title: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      children: [
        DefaultTextStyle(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(body),
                if (icon != null)
                  Icon(
                    icon,
                    size: 60,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Color(0xff627CB2),
                          ),
                          Text(
                            "Previous",
                            style: TextStyle(
                              color: Color(0xff627CB2),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          try {
                            page = Bodies.values.indexed.elementAt(--index).$2;
                          } catch (e) {
                            Navigator.pop(context);
                          }
                        });
                      },
                    ),
                    TextButton(
                      child: const Row(
                        children: [
                          Text(
                            "Next",
                            style: TextStyle(
                              color: Color(0xff627CB2),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Color(0xff627CB2),
                          ),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          try {
                            page = Bodies.values.indexed.elementAt(++index).$2;
                          } catch (e) {
                            Navigator.pop(context);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}