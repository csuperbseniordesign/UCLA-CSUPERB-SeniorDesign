import 'package:flutter/material.dart';

class GenericDismissPopup extends StatelessWidget {
  final String title;
  final String description;
  const GenericDismissPopup({required this.title, required this.description});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
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
