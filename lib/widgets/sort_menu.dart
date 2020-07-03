import 'package:flutter/material.dart';
import 'package:tripit/models/sort_options.dart';

class SortMenu extends StatelessWidget {
  final Option currentOption;
  final Function(Option) handleChangeSortOption;
  SortMenu(this.currentOption, this.handleChangeSortOption);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: Icon(
          Icons.sort,
          color: Colors.black54,
        ),
        onSelected: (value) {
          if (value == OptionType.suggested)
            this.handleChangeSortOption(Option.Suggested);

          if (value == OptionType.rating) if (this.currentOption ==
              Option.RatingAsc)
            this.handleChangeSortOption(Option.RatingDsc);
          else
            this.handleChangeSortOption(Option.RatingAsc);

          if (value == OptionType.distance) if (this.currentOption ==
              Option.DistanceAsc)
            this.handleChangeSortOption(Option.DistanceDsc);
          else
            this.handleChangeSortOption(Option.DistanceAsc);
        },
        itemBuilder: (context) {
          Icon _arrowUp = Icon(
            Icons.arrow_upward,
            size: 15,
          );
          Icon _arrowDownSel = Icon(
            Icons.arrow_downward,
            size: 15,
            color: Colors.black87,
          );
          Icon _arrowUpSel = Icon(
            Icons.arrow_upward,
            size: 15,
            color: Colors.black87,
          );

          return [
            PopupMenuItem<OptionType>(
              value: OptionType.suggested,
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                dense: true,
                title: Text(
                  'suggested',
                  softWrap: false,
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Nunito',
                      fontWeight: this.currentOption == Option.Suggested
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
              ),
            ),
            PopupMenuItem<OptionType>(
              value: OptionType.rating,
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                dense: true,
                title: Text(
                  'rating',
                  softWrap: false,
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Nunito',
                      fontWeight: this.currentOption == Option.RatingAsc ||
                              this.currentOption == Option.RatingDsc
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
                trailing: this.currentOption == Option.RatingAsc
                    ? _arrowUpSel
                    : this.currentOption == Option.RatingDsc
                        ? _arrowDownSel
                        : _arrowUp,
              ),
            ),
            PopupMenuItem<OptionType>(
              value: OptionType.distance,
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                dense: true,
                title: Text(
                  'distance',
                  softWrap: false,
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Nunito',
                      fontWeight: this.currentOption == Option.DistanceAsc ||
                              this.currentOption == Option.DistanceDsc
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
                trailing: this.currentOption == Option.DistanceAsc
                    ? _arrowUpSel
                    : this.currentOption == Option.DistanceDsc
                        ? _arrowDownSel
                        : _arrowUp,
              ),
            ),
          ];
        });
  }
}

//class SortMenuStateful extends StatefulWidget {
//  final Option currentOption;
//  final Function(Option) handleChangeSortOption;
//  SoSortMenuStatefulrtMenu(this.currentOption, this.handleChangeSortOption);
//
//  @override
//  _SortMenuState createState() => _SortMenuState();
//}
//
//class _SortMenuState extends State<SortMenuStateful> {
//  final _options = SortOption.getSortOptions();
//
//  @override
//  Widget build(BuildContext context) {
//    return PopupMenuButton(
//        icon: Icon(Icons.sort),
//        onSelected: (value) {
//          if (value == OptionType.suggested)
//            widget.handleChangeSortOption(Option.Suggested);
//
//          if (value == OptionType.rating) if (widget.currentOption ==
//              Option.RatingAsc)
//            widget.handleChangeSortOption(Option.RatingDsc);
//          else
//            widget.handleChangeSortOption(Option.RatingAsc);
//
//          if (value == OptionType.distance) if (widget.currentOption ==
//              Option.DistanceAsc)
//            widget.handleChangeSortOption(Option.DistanceDsc);
//          else
//            widget.handleChangeSortOption(Option.DistanceAsc);
//        },
//        itemBuilder: (context) {
//          Icon _arrowDown = Icon(
//            Icons.arrow_downward,
//            size: 15,
//          );
//          Icon _arrowUp = Icon(
//            Icons.arrow_upward,
//            size: 15,
//          );
//
//          return [
//            PopupMenuItem<OptionType>(
//              value: OptionType.suggested,
//              child: ListTile(
//                contentPadding: EdgeInsets.all(0),
//                dense: true,
//                title: Text(
//                  'suggested',
//                  softWrap: false,
//                  style: TextStyle(
//                      fontSize: 14,
//                      fontFamily: 'Nunito',
//                      fontWeight: widget.currentOption == Option.Suggested
//                          ? FontWeight.bold
//                          : FontWeight.normal),
//                ),
//              ),
//            ),
//            PopupMenuItem<OptionType>(
//              value: OptionType.rating,
//              child: ListTile(
//                contentPadding: EdgeInsets.all(0),
//                dense: true,
//                title: Text(
//                  'rating',
//                  softWrap: false,
//                  style: TextStyle(
//                      fontSize: 14,
//                      fontFamily: 'Nunito',
//                      fontWeight: widget.currentOption == Option.RatingAsc ||
//                              widget.currentOption == Option.RatingDsc
//                          ? FontWeight.bold
//                          : FontWeight.normal),
//                ),
//                trailing: widget.currentOption == Option.RatingAsc
//                    ? _arrowUp
//                    : widget.currentOption == Option.RatingDsc
//                        ? _arrowDown
//                        : _arrowUp,
//              ),
//            ),
//            PopupMenuItem<OptionType>(
//              value: OptionType.distance,
//              child: ListTile(
//                contentPadding: EdgeInsets.all(0),
//                dense: true,
//                title: Text(
//                  'distance',
//                  softWrap: false,
//                  style: TextStyle(
//                      fontSize: 14,
//                      fontFamily: 'Nunito',
//                      fontWeight: widget.currentOption == Option.DistanceAsc ||
//                              widget.currentOption == Option.DistanceDsc
//                          ? FontWeight.bold
//                          : FontWeight.normal),
//                ),
//                trailing: widget.currentOption == Option.DistanceAsc
//                    ? _arrowUp
//                    : widget.currentOption == Option.DistanceDsc
//                        ? _arrowDown
//                        : _arrowUp,
//              ),
//            ),
//          ];
//        });
//  }
//}
