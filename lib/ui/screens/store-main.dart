import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart.provider.dart';
import '../widgets/home-search.dart';
import 'cart-main.dart';

class Store extends StatelessWidget {
  static const routeName = '/store';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tripper',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () async {
            await showSearch(context: context, delegate: HomeSearch());
          },
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartData, _) => Center(
              child: Badge(
                showBadge: cartData.items.length > 0,
                badgeContent: Text(
                  '${cartData.items.length}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                animationDuration: Duration(milliseconds: 300),
                animationType: BadgeAnimationType.scale,
                position: BadgePosition.topEnd(top: 2, end: 2),
                badgeColor: Colors.white,
                child: IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, CartMain.routeName);
                    }),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Text('acá va el store'),
        ),
      ),
    );
  }
}
