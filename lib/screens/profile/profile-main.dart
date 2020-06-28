import 'package:flutter/material.dart';
import 'package:tripit/components/app_bar.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar, 
      body: SafeArea(
              child: Center(
          child: Text('profile'),
        ),
      ),
    );
  }
}
