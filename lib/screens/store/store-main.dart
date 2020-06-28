import 'package:flutter/material.dart';
import 'package:tripit/components/app_bar.dart';

class Store extends StatefulWidget {
  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar, 
      body: SafeArea(
              child: Center(
          child: Text('store'),
        ),
      ),
    );
  }
}
