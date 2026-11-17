import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Sets the default text size and notifies when changed, 1.0 equals 100% scale
final ValueNotifier<double> textScale = ValueNotifier<double>(1.0);

// Function to load saved text scale from local device storage
Future<void> loadTextScale() async {
  
  // Grabs preferences
  final prefs = await SharedPreferences.getInstance();

  // Grabs specific preference (text scale) as double
  final savedTextScale = prefs.getDouble('text_scale');

  // Applies saved size
  // If there isn't a saved preference then it defaults to 100%
  // Assures that the value stays between 80% - 120%, anything below 80% becomes 80% and anything beyond 120% becomes 120%
  textScale.value = (savedTextScale ?? 1.0).clamp(0.8, 1.2).toDouble();

}

// Changes text scale and saves preference to local device
Future<void> setTextScale(double scaleValue) async {
  textScale.value = scaleValue;
  
  // Grabs preferences
  final prefs = await SharedPreferences.getInstance();

  // Saves preference to local device storage
  await prefs.setDouble('text_scale', scaleValue);
}