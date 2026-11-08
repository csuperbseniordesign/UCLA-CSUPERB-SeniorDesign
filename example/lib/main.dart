import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'package:telematics_sdk_example/screens/title_screen.dart';
import 'package:telematics_sdk_example/widgets/wrapper.dart';

// import new shared preferences package
import 'package:telematics_sdk_example/services/theme_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Added shared preferences call
  final themeController = ThemeController();

  // load saved preferences (dark/light mode) before the app is displayed
  await themeController.loadThemeMode();

  // run the app with the loaded preferences
  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  // updated to add the theme controller to the app
  final ThemeController themeController;

  const MyApp({
    Key? key,
    required this.themeController,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    // returns `AnimatedBuilder` to allow for it to listen for changes (notifyListener())
  
    return AnimatedBuilder(

      // listens for changes through `notifyListeners()` from ThemeController
      // when the theme changes, it rebuilds MaterialApp
      animation: themeController,

      builder: (context, child) {

        return ThemeScope(
          // Passes existing controller into widget tree
          // Does NOT create a _new_ controller
          controller: themeController,

          // Every screen below can access the controller
          child: MaterialApp(
        
            title: 'TelematicsSDK Example',

            // light mode
            theme: ThemeData.light(),

            // dark mode
            darkTheme: ThemeData.dark(),
            
            // reads value from controller
            themeMode: themeController.themeMode,

            home: Wrapper(),
          ),
        );
      },
    );
  }
}
