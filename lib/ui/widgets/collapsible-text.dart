import 'package:flutter/material.dart';

class CollapsibleText extends StatefulWidget {
  final String text;

  CollapsibleText(this.text);

  @override
  _CollapsibleTextState createState() => _CollapsibleTextState();
}

class _CollapsibleTextState extends State<CollapsibleText> {
  TextOverflow _overflow = TextOverflow.ellipsis;
  int _maxLines = 5;

  void _toggleShowDescription() {
    setState(() {
      _maxLines = _maxLines == null ? 5 : null;
      _overflow = _overflow == null ? TextOverflow.ellipsis : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleShowDescription,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          '${widget.text}',
          maxLines: _maxLines,
          textAlign: TextAlign.justify,
          overflow: _overflow,
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
