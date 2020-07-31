import 'package:flutter/material.dart';
import 'package:tripit/ui/screens/tab-navigator.dart';

class LoginMain extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginMainState createState() => _LoginMainState();
}

class _LoginMainState extends State<LoginMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red[800],
        child: Center(
          child: FlatButton(
              onPressed: () {
                Navigator.pushNamed(context, TabNavigator.routeName);
              },
              child: Text('LOGIN')),
        ),
      ),
    );
  }
}
