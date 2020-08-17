import 'package:flutter/material.dart';
import 'package:tripit/ui/screens/tab-navigator.dart';

class LoginMain extends StatelessWidget {
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red[800],
        child: Center(
          child: FlatButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, TabNavigator.routeName);
              },
              child: Text(
                'LOGIN',
                style: TextStyle(fontSize: 50),
              )),
        ),
      ),
    );
  }
}
