import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../core/models/place.model.dart';
import '../../core/models/trip.model.dart';
import '../../providers/trip.provider.dart';

AudioPlayer _player = AudioPlayer();

void submitTrip(Trip trip, BuildContext context) async {
  List<String> tripMessages = [];
  List<Map<String, List<String>>> placeMessages = [];
  bool hasErrors = false;
  bool hasWarnings = false;

  //trip errors
  if (trip.imageUrl == null || !trip.imageUrl.contains('/'))
    tripMessages.add('1;trip cover image file is not loaded');
  else {
    File image = File(trip.imageUrl);
    if (!await image.exists())
      tripMessages.add('1;trip cover image file does not exist');
  }

  if (trip.price == null)
    tripMessages.add('1;trip price is not valid');
  else if (trip.price == 0 && trip.places.where((p) => p.price > 0) != null)
    tripMessages
        .add('1;this trip is set as free but some of its places are not');

  if (trip.previewAudioUrl == null || !trip.previewAudioUrl.contains('/'))
    tripMessages.add('1;trip preview audio file is not loaded');
  else {
    File audio = File(trip.previewAudioUrl);
    if (!await audio.exists())
      tripMessages.add('1;trip preview audio file does not exist');
    else if ((await _player.setFilePath(audio.path)).inSeconds > 125)
      tripMessages
          .add('1;trip preview audio file length is greater than 2 minutes');
  }

  if (trip.languageNameId.length < 1 || trip.languageFlagId.length < 1)
    tripMessages.add('1;select a valid language and flag');

  if (trip.places.length < 1) tripMessages.add('1;the trip has no places!');

  //trip warnings
  if (trip.name.length < 5) tripMessages.add('2;trip name is too short');

  if (trip.about.length < 15)
    tripMessages.add('2;trip description is too short');

  if (trip.places.length > 0)
    for (Place place in trip.places) {
      Map<String, List<String>> messages = {'name': [], 'messages': []};

      //place errors
      if (place.imageUrl == null || !place.imageUrl.contains('/'))
        messages['messages'].add('1;place picture file is not loaded');
      else {
        File image = File(place.imageUrl);
        if (!await image.exists())
          messages['messages'].add('1;place picture file does not exist');
      }

      if (place.price == null)
        messages['messages'].add('1;place price not valid');
      else if (place.price > 0 && trip.price == 0)
        messages['messages'].add(
            '1;this place has a price (${place.price.toStringAsPrecision(3)}) but its trip is set as free');

      if (place.fullAudioUrl == null || !place.fullAudioUrl.contains('/'))
        messages['messages'].add('1;main audio file is not loaded');
      else {
        File audio = File(place.fullAudioUrl);
        if (!await audio.exists())
          messages['messages'].add('1;main audio file does not exist');
        else if ((await _player.setFilePath(audio.path)).inSeconds > 3600)
          messages['messages']
              .add('1;main audio file length is greater than 1 hour');
      }

      //place warnings
      if (place.previewAudioUrl == null || !place.previewAudioUrl.contains('/'))
        messages['messages'].add('2;preview audio file is not loaded');
      else {
        File audio = File(place.previewAudioUrl);
        if (!await audio.exists())
          messages['messages'].add('1;preview audio file does not exist');
        else if ((await _player.setFilePath(audio.path)).inSeconds > 65)
          messages['messages']
              .add('1;preview audio file length is greater than 1 minute');
      }

      if (place.name.length < 5)
        messages['messages'].add('2;place name is too short');

      if (place.about.length < 15)
        messages['messages'].add('2;place description is too short');

      if (messages['messages'].length > 0) {
        messages['name'].add(place.name);
        placeMessages.add(messages);
      }
    }

  if (tripMessages.where((e) => e.split(';')[0] == '1').length > 0)
    hasErrors = true;

  if (placeMessages
          .where((e) =>
              e['messages'].where((p) => p.split(';')[0] == '1').length > 0)
          .length >
      0) hasErrors = true;

  if (tripMessages.length > 0 || placeMessages.length > 0) hasWarnings = true;

  showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
      title: RichText(
          text: TextSpan(
              text: 'submitting ',
              style: TextStyle(fontSize: 18, color: Colors.black),
              children: [
            TextSpan(
                text: '${trip.name}',
                style: TextStyle(fontWeight: FontWeight.bold))
          ])),
      content: Container(
        width: MediaQuery.of(context).size.width - 50,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tripMessages.length > 0)
                ListView.builder(
                  padding: const EdgeInsets.only(bottom: 15),
                  shrinkWrap: true,
                  itemCount: tripMessages.length,
                  itemBuilder: (_, i) => listItem(tripMessages[i].split(';')[0],
                      tripMessages[i].split(';')[1]),
                ),
              if (placeMessages.length > 0)
                ...buildPlacesMessages(placeMessages).expand((e) => e),
              if (!hasErrors && !hasWarnings)
                Text(
                  'after you submit the trip, its content will be uploaded and reviewed by our team for its publication. \n\n you will not be able to change the trip\'s main content after it is published. \n\n are you sure you want to continue?',
                  style: _item,
                )
            ],
          ),
        ),
      ),
      actions: [
        if (hasWarnings && !hasErrors)
          FlatButton(
            child: Text('SUBMIT ANYWAY'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        FlatButton(
          child: Text('CLOSE', style: TextStyle(color: Colors.grey)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        if (!hasErrors && !hasWarnings)
          FlatButton(
            child: Text('SUBMIT'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
      ],
    ),
  ).then((res) async {
    if (res) {
      await Provider.of<TripProvider>(context, listen: false).submit(trip);
      Navigator.of(context).pop();
    }
  });
}

TextStyle _title = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
TextStyle _item = TextStyle(fontSize: 15);

Widget listItem(String type, String text) {
  return ListTile(
      dense: true,
      title: Text(text, style: _item),
      contentPadding: const EdgeInsets.all(0),
      leading: type == '1' //error
          ? Icon(
              Icons.cancel,
              color: Colors.red[800],
            )
          : type == '2' //warning
              ? Icon(
                  Icons.warning,
                  color: Colors.yellow[800],
                )
              : Icon(
                  Icons.info_outline,
                  color: Colors.blue[400],
                ));
}

List<List<Widget>> buildPlacesMessages(
    List<Map<String, List<String>>> placeMessages) {
  return placeMessages.map((messages) {
    return [
      Text('${messages['name'].first}', style: _title),
      ListView.builder(
        padding: EdgeInsets.only(bottom: 10),
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: messages['messages'].length,
        itemBuilder: (_, i) => listItem(messages['messages'][i].split(';')[0],
            messages['messages'][i].split(';')[1]),
      ),
    ];
  }).toList();
}
