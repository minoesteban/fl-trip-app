import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/cart.provider.dart';
import 'package:tripit/providers/user.provider.dart';

class CartMain extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('cart',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.red[900])),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.red[900],
        ),
        elevation: 8,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'total amount',
                    style: TextStyle(
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      // color: Colors.white,
                    ),
                  ),
                  Consumer<CartProvider>(
                    builder: (context, cart, _) => Text(
                      '\$ ${cart.total}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red[900],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        // color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
                color: Colors.red[900],
                child: Text(
                  'CHECKOUT!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) => cart.items.isEmpty
            ? Container(
                child: Center(
                  child: Text(
                    'your cart is empty. add some trips!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: cart.items.length,
                itemBuilder: (context, i) => Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red[900],
                        radius: 30,
                        child: Text(
                          cart.items[i].price > 0
                              ? '\$ ${cart.items[i].price.toStringAsPrecision(2)}'
                              : 'free',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      title: Text(
                        '${cart.items[i].isTrip ? cart.items[i].trip.name : cart.items[i].place.name}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        '${cart.items[i].isTrip ? 'trip' : 'place'}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1.1),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              cart.items[i].isTrip
                                  ? Provider.of<UserProvider>(context,
                                          listen: false)
                                      .togglePurchasedTrip(
                                          cart.items[i].trip.id)
                                  : Provider.of<UserProvider>(context,
                                          listen: false)
                                      .togglePurchasedPlace(
                                          cart.items[i].place.id);
                              cart.removeItem(cart.items[i].id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
