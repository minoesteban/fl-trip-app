import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/filters-provider.dart';

class FiltersScreen extends StatefulWidget {
  @override
  _FiltersScreenState createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  Widget _buildSwitch(
      String title, String subtitle, bool currentValue, Function handleChange) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: currentValue,
      onChanged: handleChange,
    );
  }

  @override
  Widget build(BuildContext context) {
    var _filters = Provider.of<Filters>(context);
    return AlertDialog(
      title: Text('filter trips and places'),
      actions: [
        FlatButton(
            child: Text(
              'save',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
            })
      ],
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildSwitch('nearest', 'only nearest', _filters.nearest, (val) {
              _filters.nearest = val;
            }),
            _buildSwitch(
                'downloaded', 'only downloaded', _filters.onlyDownloaded,
                (val) {
              _filters.onlyDownloaded = val;
            }),
            _buildSwitch('purchased', 'only purchased', _filters.onlyPurchased,
                (val) {
              _filters.onlyPurchased = val;
            }),
            _buildSwitch(
                'favourites', 'only favourite', _filters.onlyFavourites, (val) {
              _filters.onlyFavourites = val;
            }),
            _buildSwitch('free', 'only free', _filters.onlyFree, (val) {
              _filters.onlyFree = val;
            }),
          ],
        ),
      ),
    );
  }
}
