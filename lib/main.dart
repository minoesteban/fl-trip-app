import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tripper/providers/credentials.provider.dart';
import 'package:tripper/ui/screens/login.dart';
import 'core/models/cart-item.model.dart';
import 'core/models/cart.model.dart';
import 'core/models/rating.model.dart';
import 'core/models/user.model.dart';
import 'core/models/download.model.dart';
import 'core/models/place.model.dart';
import 'core/models/trip.model.dart';
import 'core/utils/utils.dart';
import 'providers/download.provider.dart';
import 'providers/cart.provider.dart';
import 'providers/purchase.provider.dart';
import 'providers/language.provider.dart';
import 'providers/country.provider.dart';
import 'providers/user.provider.dart';
import 'providers/filters.provider.dart';
import 'providers/trip.provider.dart';
import 'ui/screens/trip-player.dart';
import 'ui/screens/cart-main.dart';
import 'ui/screens/login.dart';
import 'ui/screens/home-main.dart';
import 'ui/screens/map-main.dart';
import 'ui/screens/trip-new.dart';
import 'ui/screens/store-main.dart';
import 'ui/screens/profile-main.dart';
import 'ui/screens/tab-navigator.dart';
import 'ui/screens/place-dialog.dart';
import 'ui/screens/trip-main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TripAdapter());
  Hive.registerAdapter(PlaceAdapter());
  Hive.registerAdapter(CartAdapter());
  Hive.registerAdapter(RatingAdapter());
  Hive.registerAdapter(CartItemAdapter());
  Hive.registerAdapter(DownloadAdapter());
  Hive.registerAdapter(CoordinatesAdapter());
  Hive.registerAdapter(FileOriginAdapter());

  var _userProvider = UserProvider();
  var _trips = TripProvider();
  var _purchases = PurchaseProvider();
  var _countries = CountryProvider();
  var _languages = LanguageProvider();
  var _downloads = DownloadProvider();
  var _credentials = CredentialsProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CountryProvider>.value(
          value: _countries,
        ),
        ChangeNotifierProvider<TripProvider>.value(
          value: _trips,
        ),
        ChangeNotifierProvider<PurchaseProvider>.value(
          value: _purchases,
        ),
        ChangeNotifierProvider<UserProvider>.value(
          value: _userProvider,
        ),
        ChangeNotifierProvider<LanguageProvider>.value(
          value: _languages,
        ),
        ChangeNotifierProvider<DownloadProvider>.value(
          value: _downloads,
        ),
        ChangeNotifierProvider<CredentialsProvider>.value(
          value: _credentials,
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<Filters>(
          create: (_) => Filters(),
        ),
      ],
      child: MaterialApp(
        title: 'tripper',
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => AuthScreen(), //LoginMain(),
          TabNavigator.routeName: (context) => TabNavigator(),
          Home.routeName: (context) => Home(),
          MapMain.routeName: (context) => MapMain(),
          Store.routeName: (context) => Store(),
          PlaceDialog.routeName: (context) => PlaceDialog(new Place()),
          CartMain.routeName: (context) => CartMain(),
        },
        onGenerateRoute: (settings) {
          Map<dynamic, dynamic> args = settings.arguments ?? {};
          switch (settings.name) {
            case TripNew.routeName:
              return MaterialPageRoute<Map<String, dynamic>>(
                  builder: (context) {
                Trip trip = args['trip'] ??
                    Trip(
                        id: 0,
                        name: '',
                        countryId: '',
                        ownerId: _userProvider.user.id);
                return TripNew(trip);
              });
            case TripMain.routeName:
              return MaterialPageRoute<Map<String, dynamic>>(
                  builder: (context) {
                    Trip trip = args['trip'];
                    return TripMain(trip);
                  },
                  settings: settings);
            case TripPlayer.routeName:
              return MaterialPageRoute<Map<String, dynamic>>(
                  builder: (context) {
                    Trip trip = args['trip'];
                    return TripPlayer(trip);
                  },
                  settings: settings);
            case Profile.routeName:
              return MaterialPageRoute<Map<String, dynamic>>(
                  builder: (context) {
                    int userId = args['id'];
                    return Profile(userId);
                  },
                  settings: settings);
            default:
              return MaterialPageRoute<void>(
                  builder: (context) => AuthScreen());
          }
        },
        theme: ThemeData(
          sliderTheme: SliderThemeData(
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          fontFamily: 'Nunito',
          primarySwatch: Colors.red,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          }),
        ),
      ),
    ),
  );
}
