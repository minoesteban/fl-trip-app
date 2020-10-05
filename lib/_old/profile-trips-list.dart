// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tripper/providers/user-position.provider.dart';
// import 'package:tripper/core/models/trip.model.dart';
// import 'package:tripper/ui/screens/trip-main.dart';

// class ProfileTripsList extends StatelessWidget {
//   final List<Trip> _trips;

//   ProfileTripsList(this._trips);

//   @override
//   Widget build(BuildContext context) {
//     var _userPosition =
//         Provider.of<UserPosition>(context, listen: false).getPosition;
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       child: ListView.builder(
//           physics: ClampingScrollPhysics(),
//           shrinkWrap: true,
//           itemCount: _trips.length,
//           itemBuilder: (ctx, i) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.all(Radius.circular(10)),
//                 child: Container(
//                   height: 200,
//                   child: InkWell(
//                     onTap: () => Navigator.pushNamed(
//                         context, TripMain.routeName,
//                         arguments: {
//                           'trip': _trips[i],
//                           'userPosition': _userPosition,
//                         }),
//                     child: GridTile(
//                       footer: GridTileBar(
//                         title: Text(
//                           _trips[i].name,
//                           softWrap: true,
//                           overflow: TextOverflow.fade,
//                         ),
//                       ),
//                       child: CachedNetworkImage(
//                         imageUrl: '${_trips[i].imageUrl}',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }),
//     );
//   }
// }
