// import 'package:flutter/material.dart';
// import 'package:tripit/core/models/trip.model.dart';

// class RatingOverview extends StatefulWidget {
//   final Trip trip;

//   RatingOverview(this.trip);

//   @override
//   _RatingOverviewState createState() => _RatingOverviewState();
// }

// class _RatingOverviewState extends State<RatingOverview> {
//   @override
//   Widget build(BuildContext context) {
//     double rating =
//         widget.trip.places.map((e) => e.rating.rating).reduce((a, b) => a + b) /
//             widget.trip.places.length;

//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 '${rating.toStringAsPrecision(3)}',
//                 style: TextStyle(
//                     color: Colors.amber[500],
//                     fontWeight: FontWeight.bold,
//                     fontSize: 30),
//               ),
//               Icon(
//                 Icons.star,
//                 color: Colors.amber[500],
//                 size: 18,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
