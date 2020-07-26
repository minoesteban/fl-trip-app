import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/filters.provider.dart';
import 'package:tripit/providers/trip.provider.dart';
import '../widgets/home-search.dart';
import 'filters.dart';

class Store extends StatefulWidget {
  static const routeName = '/store';

  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> {
  @override
  Widget build(BuildContext context) {
    var _filters = Provider.of<Filters>(context, listen: false);
    var _trips = Provider.of<TripProvider>(context).trips;
    return Scaffold(
      appBar: AppBar(
        title: Text('tripit',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () async {
            await showSearch(context: context, delegate: HomeSearch(_trips));
          },
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.tune),
              onPressed: () async {
                await showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (_) {
                      return ChangeNotifierProvider.value(
                          value: _filters, child: FiltersScreen());
                    });
              }),
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {})
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Text('store'),
        ),
      ),
    );
  }
}
