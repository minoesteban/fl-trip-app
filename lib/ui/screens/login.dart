import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/country.provider.dart';
import 'package:tripit/providers/download.provider.dart';
import 'package:tripit/providers/language.provider.dart';
import 'package:tripit/providers/purchase.provider.dart';
import 'package:tripit/providers/trip.provider.dart';
import 'package:tripit/providers/user.provider.dart';
import 'package:tripit/ui/screens/tab-navigator.dart';

class LoginMain extends StatelessWidget {
  static const routeName = '/login';

  Future<void> init(BuildContext context) async {
    //TODO: hacer el get user dinamico segun login?
    print('getuser');
    await Provider.of<UserProvider>(context, listen: false).getUser(8, true);
    print('position');
    await Provider.of<UserProvider>(context, listen: false).getUserPosition();
    print('init');
    await Provider.of<DownloadProvider>(context, listen: false).init();
    print('loadtrips');
    await Provider.of<TripProvider>(context, listen: false).loadTrips();
    print('getcounts');
    await Provider.of<PurchaseProvider>(context, listen: false).getCounts();
    print('loadcountries');
    await Provider.of<CountryProvider>(context, listen: false).loadCountries();
    print('loadlanguages');
    await Provider.of<LanguageProvider>(context, listen: false).loadLanguages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red[800],
        child: Center(
          child: FutureBuilder(
            future: init(context),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.red[300]),
                  ),
                );
              return FlatButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, TabNavigator.routeName);
                  },
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1),
                  ));
            },
          ),
        ),
      ),
    );
  }
}
