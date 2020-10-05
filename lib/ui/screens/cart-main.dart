import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripper/core/utils/s3-auth-headers.dart';
import 'package:tripper/providers/cart.provider.dart';

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
                itemBuilder: (context, i) => Dismissible(
                  key: ValueKey(cart.items[i].id),
                  background: Container(
                    child: Icon(
                      Icons.delete,
                      color: Colors.red[900],
                      size: 40,
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    margin: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                  ),
                  confirmDismiss: (direction) {
                    return showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('are you sure?'),
                        content: Text(
                            'do you want to remove the item from the cart?'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('NO'),
                            onPressed: () => Navigator.of(ctx).pop(false),
                          ),
                          FlatButton(
                            child: Text('YES'),
                            onPressed: () => Navigator.of(ctx).pop(true),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) => cart.removeItem(cart.items[i].id),
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            httpHeaders: generateAuthHeaders(
                                cart.items[i].isTrip
                                    ? cart.items[i].trip.imageUrl
                                    : cart.items[i].place.imageUrl),
                            imageUrl: cart.items[i].isTrip
                                ? cart.items[i].trip.imageUrl
                                : cart.items[i].place.imageUrl,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 0.5,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.grey[100]),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
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
                        trailing: Text(
                          cart.items[i].price > 0
                              ? '\$ ${cart.items[i].price.toStringAsPrecision(3)}'
                              : 'free',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
