import 'package:flutter/material.dart';

const double aspectRatio = 1 / 1.1;
const edgeInsets = 12.0;

enum Bodies {
  setup,
  homePage,
  infoIcon,
  settingsPage,
  credentials,
  requestData,
  privacyPolicy,
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
            "This app will track and record your driving events "
                "automatically in the background.\n\n"
                "Please ensure that all permissions are granted "
                "and that your mobile device does not optimize "
                "this application.");
        break;
      case Bodies.homePage:
        body = tutorialBody(
          "Tutorial - Home Page",
          "Tap this icon at the bottom left corner "
              "to navigate to the Home Page "
              "where you can view the tracking status of the application.",
          Icons.home,
        );
        break;
      case Bodies.infoIcon:
        body = tutorialBody(
          "Tutorial - Home Page",
          "Tap this icon at the top right corner of the home page "
              "to navigate to this tutorial "
              "where you can review the application's functionalities.",
          Icons.info_outline,
        );
        break;
      case Bodies.settingsPage:
        body = tutorialBody(
          "Tutorial - Settings Page",
          "Tap this icon at the bottom right corner "
              "to navigate to the Settings Page "
              "where you can edit your profile, request your collected data, "
              "and view information about the application.",
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
      case Bodies.requestData:
        body = tutorialBody(
          "Tutorial - Settings Page",
          "Tap this icon in the settings page "
              "to navigate a form where you can "
              "request your collected driving data.",
          Icons.data_exploration_sharp,
        );
        break;
        case Bodies.privacyPolicy:
        body = tutorialBody(
          "Tutorial - Settings Page",
          "Tap this icon in the settings page "
              "view this application's privacy "
              "statements and policies with regard to collected data.",
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
                Icon(
                  icon,
                  size: icon != null ? 60 : 0,
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
