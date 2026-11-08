// imports
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// creation of controller class for theme management
class ThemeController extends ChangeNotifier {
  
  // variable to identify the saved preference on user's device
  static const String _themeModeKey = 'theme_mode';

  // default them when fresh app install or no preference chosen
  // chooses system them as default
  ThemeMode _themeMode = ThemeMode.system;

  // points app to the current theme mode
  ThemeMode get themeMode => _themeMode;

  //function to load saved theme from local device storage
  Future<void> loadThemeMode() async {
    
    // grabs preferences
    final prefs = await SharedPreferences.getInstance();

    // grabs specific preference (dark/light mode) as string
    final savedTheme = prefs.getString(_themeModeKey);

    // dark/light mode specific
    // using `ThemMode` to set the app to the specific theme
    // and resets `_themeMode` to preference
    if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    }
    else if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    }
    else {
      _themeMode = ThemeMode.system;
    }

    // notifies app (or widgets that may be listening) that the specific value is ready
    notifyListeners();
  }

  // changes the theme and saves preference to local device
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    // notification to app/widgets that may be listening that it's ready
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    // saves the preference to local device storage
    if (mode == ThemeMode.light) {
      await prefs.setString(_themeModeKey, 'light');
    }
    else if (mode == ThemeMode.dark) {
      await prefs.setString(_themeModeKey, 'dark');
    }
    else {
      // restores to default system theme
      await prefs.remove(_themeModeKey);
    }



  }
}