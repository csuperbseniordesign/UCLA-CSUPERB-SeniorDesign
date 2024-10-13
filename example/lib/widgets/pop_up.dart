import 'package:flutter/material.dart';

class PopUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Unable to connect to firebase'),
      content: Text('Please check your network connection'),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Text('Dismiss'),
            )),
      ],
    );
  }
}
