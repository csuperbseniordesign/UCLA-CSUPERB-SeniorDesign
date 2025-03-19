import 'package:flutter/material.dart';
import 'package:telematics_sdk_example/widgets/generic_dismiss_popup.dart';

class AlertUser {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return GenericDismissPopup(title: title, description: description);
      },
    );
  }
}

//  final String title;
//   final String description;

//   const AlertUser({required this.title, required this.description});