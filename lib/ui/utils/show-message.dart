import 'package:flutter/material.dart';

void showMessage(BuildContext context, dynamic e, bool isDialog) {
  print(e.toString());
  if (isDialog)
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('error!'),
          content: Text('${e.toString()}'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'REPORT...',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  else
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('error! $e'),
        action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              Scaffold.of(context).hideCurrentSnackBar();
            }),
      ),
    );
}
