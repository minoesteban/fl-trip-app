import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tripit/core/services/trip.service.dart';
import 'package:tripit/ui/utils/show-message.dart';
import 'package:tripit/core/services/place.service.dart';

class Player extends StatefulWidget {
  final String url;
  final bool withSlider;
  final bool isTrip; //if not, it is Place

  Player(this.url, this.withSlider, this.isTrip);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  AudioPlayer _player;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _loadAudio();
  }

  _loadAudio() async {
    try {
      widget.isTrip
          ? await _player.setUrl(await TripService().getDownloadUrl(widget.url))
          : await _player
              .setUrl(await PlaceService().getDownloadUrl(widget.url, false));
    } catch (e) {
      showMessage(context, e, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        PlayPause(_player),
        if (widget.withSlider)
          StreamBuilder<Duration>(
            stream: _player.durationStream,
            builder: (context, snapshot) {
              final duration = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  var position = snapshot.data ?? Duration.zero;
                  if (position > duration) {
                    position = duration;
                  }
                  return SeekBar(
                    duration: duration,
                    position: position,
                    onChangeEnd: (newPosition) {
                      _player.seek(newPosition);
                    },
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class PlayPause extends StatelessWidget {
  final AudioPlayer player;

  PlayPause(this.player);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            padding: const EdgeInsets.all(8),
            width: 45,
            height: 45,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey[200]),
            ),
          );
        } else if (playing != true) {
          return IconButton(
            padding: const EdgeInsets.all(0),
            icon: Icon(
              Icons.play_arrow,
              color: Colors.green,
            ),
            iconSize: 50,
            onPressed: player.play,
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            padding: const EdgeInsets.all(0),
            icon: Icon(
              Icons.pause,
              color: Colors.green,
            ),
            iconSize: 50,
            onPressed: player.pause,
          );
        } else {
          return IconButton(
            icon: Icon(
              Icons.replay,
              color: Colors.green,
            ),
            iconSize: 50,
            onPressed: () => player.seek(Duration.zero, index: 0),
          );
        }
      },
    );
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              activeColor: Colors.green,
              inactiveColor: Colors.grey[300],
              value: min(
                  _dragValue ?? widget.position.inMilliseconds.toDouble(),
                  widget.duration.inMilliseconds.toDouble()),
              onChanged: (value) {
                setState(() {
                  _dragValue = value;
                });
                if (widget.onChanged != null) {
                  widget.onChanged(Duration(milliseconds: value.round()));
                }
              },
              onChangeEnd: (value) {
                if (widget.onChangeEnd != null) {
                  widget.onChangeEnd(Duration(milliseconds: value.round()));
                }
                _dragValue = null;
              },
            ),
          ),
          Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch("$_remaining")
                      ?.group(1) ??
                  '$_remaining',
              style: Theme.of(context).textTheme.caption),
        ],
      ),
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}
