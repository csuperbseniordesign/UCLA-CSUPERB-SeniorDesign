import 'package:flutter/material.dart';
import 'package:telematics_sdk_example/widgets/pop_up.dart';

class AlertUser {
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopUp();
      },
    );
  }
}
