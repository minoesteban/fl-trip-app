import 'dart:async';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tripit/core/models/trip.model.dart';
import 'package:tripit/providers/download.provider.dart';
import 'package:tripit/providers/trip.provider.dart';
import 'package:tripit/ui/widgets/store-trip-map.dart';

class TripPlayer extends StatefulWidget {
  final Trip _trip;
  TripPlayer(this._trip);

  @override
  _TripPlayerState createState() => _TripPlayerState();
}

class _TripPlayerState extends State<TripPlayer> {
  AudioPlayer player = AudioPlayer();
  ConcatenatingAudioSource _playlist;
  // AudioPlayer player;
  Trip trip;

  @override
  void initState() {
    super.initState();
    trip = widget._trip;
    player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));

    _init();
  }

  _init() async {
    DownloadProvider downloads =
        Provider.of<DownloadProvider>(context, listen: false);
    TripProvider trips = Provider.of<TripProvider>(context, listen: false);

    _playlist = ConcatenatingAudioSource(
      children:
          await Future.wait(trip.places.map<Future<AudioSource>>((place) async {
        if (downloads.existsByPlace(place.id)) {
          //Load local audio file
          return AudioSource.uri(
            Uri.parse(
                'file://${downloads.getByPlace(place.id).first.filePath}'),
            tag: AudioMetadata(
                album: trip.name,
                title: '${place.order}. ${place.name}',
                artwork: place.imageUrl),
          );
        } else {
          //Load audio file from URL
          return AudioSource.uri(
            Uri.parse(
                await trips.getPlaceDownloadUrl(place.fullAudioUrl, true)),
            tag: AudioMetadata(
                album: trip.name,
                title: '${place.order}. ${place.name}',
                artwork: place.imageUrl),
          );
        }
      }).toList()),
    );

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    try {
      await player.load(_playlist);
    } catch (e) {
      // catch load errors: 404, invalid url ...
      print("An error occured $e");
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: Text(
          'tripit',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.red[800]),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.red[800]),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //trip map
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          border: Border.all(color: Colors.grey[400])),
                      child: TripMap(trip)),
                ),
              ),
            ),
            //trip & place name
            StreamBuilder<SequenceState>(
              stream: player.sequenceStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                if (state?.sequence?.isEmpty ?? true) return SizedBox();
                final metadata = state.currentSource.tag as AudioMetadata;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(metadata.album ?? '', style: _titleStyle),
                    Text(metadata.title ?? '', style: _subtitleStyle),
                  ],
                );
              },
            ),
            ControlButtons(player),
            StreamBuilder<Duration>(
              stream: player.durationStream,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snapshot) {
                    var position = snapshot.data ?? Duration.zero;
                    if (position > duration) {
                      position = duration;
                    }
                    return SeekBar(
                      duration: duration,
                      position: position,
                      onChangeEnd: (newPosition) {
                        player.seek(newPosition);
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                StreamBuilder<LoopMode>(
                  stream: player.loopModeStream,
                  builder: (context, snapshot) {
                    final loopMode = snapshot.data ?? LoopMode.off;
                    const icons = [
                      Icon(Icons.repeat, color: Colors.grey),
                      Icon(Icons.repeat, color: Colors.red),
                      Icon(Icons.repeat_one, color: Colors.red),
                    ];
                    const cycleModes = [
                      LoopMode.off,
                      LoopMode.all,
                      LoopMode.one,
                    ];
                    final index = cycleModes.indexOf(loopMode);
                    return IconButton(
                      icon: icons[index],
                      onPressed: () {
                        player.setLoopMode(cycleModes[
                            (cycleModes.indexOf(loopMode) + 1) %
                                cycleModes.length]);
                      },
                    );
                  },
                ),
                Expanded(
                  child: Text('places',
                      style: _titleBigStyle, textAlign: TextAlign.center),
                ),
                StreamBuilder<bool>(
                  stream: player.shuffleModeEnabledStream,
                  builder: (context, snapshot) {
                    final shuffleModeEnabled = snapshot.data ?? false;
                    return IconButton(
                      icon: shuffleModeEnabled
                          ? Icon(Icons.shuffle, color: Colors.red)
                          : Icon(Icons.shuffle, color: Colors.grey),
                      onPressed: () {
                        player.setShuffleModeEnabled(!shuffleModeEnabled);
                      },
                    );
                  },
                ),
              ],
            ),
            Container(
              height: 200.0,
              child: StreamBuilder<SequenceState>(
                stream: player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final sequence = state?.sequence ?? [];
                  return ListView.builder(
                    itemCount: sequence.length,
                    itemBuilder: (context, index) => Material(
                      color: index == state.currentIndex
                          ? Colors.grey.shade300
                          : null,
                      child: ListTile(
                        title: Text(
                          sequence[index].tag.title,
                          style: _itemStyle,
                        ),
                        onTap: () {
                          player.seek(Duration.zero, index: index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  ControlButtons(this.player);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          color: Colors.grey[800],
          icon: Icon(Icons.volume_up),
          onPressed: () {
            _showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),
        StreamBuilder<SequenceState>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            color: Colors.grey[800],
            icon: Icon(Icons.skip_previous),
            onPressed: player.hasPrevious ? player.seekToPrevious : null,
          ),
        ),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.grey[400]),
                ),
              );
            } else if (playing != true) {
              return IconButton(
                color: Colors.grey[800],
                icon: Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                color: Colors.grey[800],
                icon: Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                color: Colors.grey[800],
                icon: Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero, index: 0),
              );
            }
          },
        ),
        StreamBuilder<SequenceState>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            color: Colors.grey[800],
            icon: Icon(Icons.skip_next),
            onPressed: player.hasNext ? player.seekToNext : null,
          ),
        ),
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            color: Colors.grey[800],
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              _showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                stream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        ),
      ],
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
    return Stack(
      children: [
        Slider(
          min: 0.0,
          activeColor: Colors.red[700],
          // inactiveColor: Colors.red[300],
          max: widget.duration.inMilliseconds.toDouble(),
          value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
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
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch("$_remaining")
                      ?.group(1) ??
                  '$_remaining',
              style: Theme.of(context).textTheme.caption),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

_showSliderDialog({
  BuildContext context,
  String title,
  int divisions,
  double min,
  double max,
  String valueSuffix = '',
  Stream<double> stream,
  ValueChanged<double> onChanged,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => Container(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? 1.0,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class AudioMetadata {
  final String album;
  final String title;
  final String artwork;

  AudioMetadata({this.album, this.title, this.artwork});
}

final TextStyle _titleStyle =
    TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

final TextStyle _titleBigStyle = TextStyle(
    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[900]);

final TextStyle _itemStyle = TextStyle(
    fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.bold);

final TextStyle _subtitleStyle = TextStyle(
  fontSize: 16,
  color: Colors.black38,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.1,
);
