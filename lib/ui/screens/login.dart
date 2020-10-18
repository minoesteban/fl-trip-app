import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:provider/provider.dart';
import '../../core/models/user.model.dart';
import '../../providers/credentials.provider.dart';
import '../../providers/purchase.provider.dart';
import '../../providers/trip.provider.dart';
import '../../providers/user.provider.dart';
import '../screens/tab-navigator.dart';
import '../utils/show-message.dart';
import '../utils/validator.dart';

enum AuthMode { Signup, Login }

PageController _pc;
// FocusNode _focusPIN = FocusNode();
bool waiting = false;
Map<String, String> authData = {
  'id': '0',
  'email': '',
  'password': '',
  'firstName': '',
  'lastName': '',
  'isGuide': false.toString(),
};

Future<void> init(BuildContext context) async {
  _pc = PageController();
  await Provider.of<UserProvider>(context, listen: false).init();
  int userId = Provider.of<UserProvider>(context, listen: false).user.id;
  // userId = 0;
  if (userId > 0) {
    await loginStep2(context, userId);
  }
}

Future<void> loginStep1(BuildContext context, bool update) async {
  try {
    int userId = await Provider.of<UserProvider>(context, listen: false).login(
      authData['email'],
      authData['password'],
    );
    if (userId > 0) {
      if (update)
        await Provider.of<UserProvider>(context, listen: false).update(User(
            id: userId,
            firstName: authData['firstName'],
            lastName: authData['lastName']));
      await loginStep2(context, userId);
    } else
      _pc.nextPage(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
  } catch (err) {
    showMessage(context, err, true);
  }
}

Future<void> loginStep2(BuildContext context, int userId) async {
  try {
    await Provider.of<TripProvider>(context, listen: false).loadTrips();
    print('loadtrips');
    Provider.of<PurchaseProvider>(context, listen: false).getCounts();
    Provider.of<UserProvider>(context, listen: false).getUser(userId, true);
    // _focusPIN.dispose();
    _pc.dispose();

    OneSignal.shared.setLogLevel(OSLogLevel.none, OSLogLevel.none);
    OneSignal.shared.init(getKey('oi'), iOSSettings: {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.inAppLaunchUrl: false
    });
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt.
    // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
    await OneSignal.shared.setExternalUserId(
        Provider.of<UserProvider>(context, listen: false).user.username);

    Navigator.pushReplacementNamed(context, TabNavigator.routeName);
  } catch (err) {
    showMessage(context, err, true);
  }
}

class AuthScreen extends StatelessWidget {
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.red[800],
        width: deviceSize.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 1),
                    Text(
                      'tripper',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 6,
              child: PageView(
                  controller: _pc,
                  physics: NeverScrollableScrollPhysics(),
                  children: [AuthCard(), ActivateCard(), ProfileCard()]),
            ),
            Expanded(child: const SizedBox()),
          ],
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;

  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;
  Future futureInit;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    futureInit = init(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await loginStep1(context, false);
      } else {
        try {
          if (await Provider.of<UserProvider>(context, listen: false).signup(
            authData['email'],
            authData['password'],
          )) {
            // FocusScope.of(context).requestFocus(_focusPIN);
            _pc.nextPage(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
            );
          }
        } catch (err) {
          showMessage(context, err, true);
        }
      }
    } catch (error) {
      showMessage(context, error, true);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureInit,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.red[300]),
            ),
          );
        return Card(
          color: Colors.red[800],
          elevation: 0,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
            // width: deviceSize.width * 0.75,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 60),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    style: TextStyle(
                      color: Colors.white,
                      decorationColor: Colors.grey[300],
                    ),
                    decoration: InputDecoration(
                      labelText: 'email',
                      labelStyle: TextStyle(color: Colors.white),
                      errorStyle: TextStyle(color: Colors.grey[300]),
                      enabledBorder: _border,
                      errorBorder: _border,
                      focusedBorder: _border,
                      focusedErrorBorder: _border,
                    ),
                    cursorColor: Colors.grey[300],
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (!validateEmail(value)) {
                        return 'invalid email!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      authData['email'] = value;
                    },
                  ),
                  TextFormField(
                    cursorColor: Colors.grey[300],
                    style: TextStyle(
                      color: Colors.white,
                      decorationColor: Colors.grey[300],
                    ),
                    decoration: InputDecoration(
                        labelText: 'password',
                        labelStyle: TextStyle(color: Colors.white),
                        errorStyle: TextStyle(color: Colors.grey[300]),
                        errorMaxLines: 2,
                        enabledBorder: _border,
                        errorBorder: _border,
                        focusedBorder: _border,
                        focusedErrorBorder: _border,
                        helperMaxLines: 2,
                        helperStyle: TextStyle(color: Colors.white60),
                        helperText: _authMode == AuthMode.Signup
                            ? 'at least one Uppercase, one d1git and one special character!'
                            : null),
                    obscureText: true,
                    textInputAction: _authMode == AuthMode.Signup
                        ? TextInputAction.next
                        : TextInputAction.done,
                    controller: _passwordController,
                    validator: (value) {
                      if ((_authMode == AuthMode.Signup &&
                              !validatePassword(value)) ||
                          _authMode == AuthMode.Login && value.isEmpty) {
                        return _authMode == AuthMode.Login
                            ? 'invalid password!'
                            : 'at least one Uppercase, one d1git and one special character!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      authData['password'] = value;
                    },
                  ),
                  AnimatedContainer(
                    constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                    ),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: TextFormField(
                          style: TextStyle(
                            color: Colors.white,
                            decorationColor: Colors.grey[300],
                          ),
                          cursorColor: Colors.grey[300],
                          enabled: _authMode == AuthMode.Signup,
                          decoration: InputDecoration(
                            labelText: 'confirm password',
                            labelStyle: TextStyle(color: Colors.white),
                            errorStyle: TextStyle(color: Colors.grey[300]),
                            enabledBorder: _border,
                            errorBorder: _border,
                            focusedBorder: _border,
                            focusedErrorBorder: _border,
                          ),
                          obscureText: true,
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return 'passwords do not match!';
                                  }
                                  return null;
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.red[300]),
                    )
                  else
                    RaisedButton(
                      child: Text(
                        _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      onPressed: _submit,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                      textColor: Colors.red[800],
                    ),
                  const SizedBox(height: 5),
                  FlatButton(
                    child: Text(
                        _authMode == AuthMode.Login ? 'SIGN UP' : 'LOGIN',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, letterSpacing: 1)),
                    onPressed: _switchAuthMode,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    // textColor: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ActivateCard extends StatefulWidget {
  @override
  _ActivateCardState createState() => _ActivateCardState();
}

class _ActivateCardState extends State<ActivateCard> {
  TextEditingController controller = TextEditingController(text: "");
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[800],
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'we sent a code to',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              authData['email'],
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'type it below to activate your account',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 30),
            waiting
                ? CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.red[300]),
                  )
                : PinCodeTextField(
                    // focusNode: _focusPIN,
                    autofocus: true,
                    controller: controller,
                    highlight: true,
                    highlightColor: Colors.white,
                    defaultBorderColor: Colors.white60,
                    hasTextBorderColor: Colors.white60,
                    maxLength: 6,
                    hasError: hasError,
                    onTextChanged: (text) {},
                    onDone: (text) async {
                      setState(() {
                        waiting = true;
                      });
                      try {
                        if (await Provider.of<UserProvider>(context,
                                listen: false)
                            .activate(
                          authData['email'],
                          text,
                        )) {
                          setState(() {
                            waiting = false;
                          });
                          _pc.nextPage(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeIn,
                          );
                        }
                      } catch (err) {
                        setState(() {
                          waiting = false;
                        });
                        showMessage(context, err, true);
                      }
                    },
                    pinBoxWidth: 40,
                    pinBoxHeight: 64,
                    pinBoxDecoration:
                        ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                    pinTextStyle: TextStyle(color: Colors.white, fontSize: 24),
                    keyboardType: TextInputType.number,
                  ),
            const SizedBox(
              height: 20,
            ),
            FlatButton(
              child: Text(
                'GO BACK',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              onPressed: () => _pc.previousPage(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
              ),
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final GlobalKey<FormState> _profileFormKey = GlobalKey();
  bool tourist = true;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[800],
      elevation: 0,
      child: Form(
        key: _profileFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'complete your profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                style: TextStyle(
                  color: Colors.white,
                  decorationColor: Colors.grey[300],
                ),
                decoration: InputDecoration(
                  labelText: 'first name',
                  labelStyle: TextStyle(color: Colors.white),
                  errorStyle: TextStyle(color: Colors.grey[200]),
                  enabledBorder: _border,
                  errorBorder: _border,
                  focusedBorder: _border,
                  focusedErrorBorder: _border,
                ),
                cursorColor: Colors.grey[300],
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'type in your first name';
                  }
                  return null;
                },
                onSaved: (value) {
                  authData['firstName'] = value.trim();
                },
              ),
              TextFormField(
                style: TextStyle(
                  color: Colors.white,
                  decorationColor: Colors.grey[300],
                ),
                decoration: InputDecoration(
                  labelText: 'last name',
                  labelStyle: TextStyle(color: Colors.white),
                  errorStyle: TextStyle(color: Colors.grey[300]),
                  enabledBorder: _border,
                  errorBorder: _border,
                  focusedBorder: _border,
                  focusedErrorBorder: _border,
                ),
                cursorColor: Colors.grey[300],
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'type in your last name';
                  }
                  return null;
                },
                onSaved: (value) {
                  authData['lastName'] = value.trim();
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  tourist
                      ? RaisedButton(
                          child: Text(
                            "I'M A TOURIST",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {},
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          textColor: Colors.red[800],
                        )
                      : FlatButton(
                          child: Text(
                            "I'M A TOURIST",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => setState(() {
                            tourist = true;
                            authData['isGuide'] = true.toString();
                          }),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          textColor: Colors.white,
                        ),
                  tourist
                      ? FlatButton(
                          child: Text(
                            "I'M A TOUR GUIDE",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => setState(() {
                            tourist = false;
                            authData['isGuide'] = false.toString();
                          }),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          textColor: Colors.white,
                        )
                      : RaisedButton(
                          child: Text(
                            "I'M A TOUR GUIDE",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {},
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          textColor: Colors.red[800],
                        )
                ],
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    child: Text(
                      'NOT NOW',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _pc.previousPage(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      );
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textColor: Colors.white,
                  ),
                  waiting
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.red[300]),
                          ),
                        )
                      : RaisedButton(
                          child: Text(
                            'DONE',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            setState(() {
                              waiting = true;
                            });
                            try {
                              _profileFormKey.currentState.save();
                              await loginStep1(context, true);
                            } catch (err) {
                              showMessage(context, err, true);
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          textColor: Colors.red[800],
                        )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

var _border = UnderlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
    borderSide: BorderSide(color: Colors.grey[500]));
