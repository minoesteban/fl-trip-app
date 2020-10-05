import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
    await Provider.of<UserProvider>(context, listen: false).init();
    print('inituser');
    await Provider.of<DownloadProvider>(context, listen: false).init();
    print('initdownloads');
    await Provider.of<TripProvider>(context, listen: false).loadTrips();
    print('loadtrips');
    await Provider.of<CountryProvider>(context, listen: false).loadCountries();
    await Provider.of<LanguageProvider>(context, listen: false).loadLanguages();
    Provider.of<PurchaseProvider>(context, listen: false).getCounts();

    if (Provider.of<UserProvider>(context, listen: false).user.id > 0) {
      await Provider.of<UserProvider>(context, listen: false).getUserPosition();
      Navigator.pushReplacementNamed(context, TabNavigator.routeName);
    }
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
                  onPressed: () async {
                    print('getuser');
                    await Provider.of<UserProvider>(context, listen: false)
                        .getUser(8, true);
                    await Provider.of<UserProvider>(context, listen: false)
                        .getUserPosition();
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
