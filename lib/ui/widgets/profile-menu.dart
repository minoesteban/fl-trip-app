import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripper/providers/user.provider.dart';
import 'package:tripper/ui/screens/login.dart';

enum Options { Logout }

class ProfileMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: Icon(
          Icons.more_vert,
        ),
        onSelected: (value) {
          switch (value) {
            case Options.Logout:
              Provider.of<UserProvider>(context, listen: false).logout();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AuthScreen.routeName, (_) => false);
              break;
            default:
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem<void>(
              value: Options.Logout,
              child: Row(
                children: [
                  const Text('logout', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.exit_to_app,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ];
        });
  }
}
