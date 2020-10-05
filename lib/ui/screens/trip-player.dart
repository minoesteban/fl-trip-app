import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripper/core/models/trip.model.dart';
import 'package:tripper/ui/utils/brackground-audio-player.dart';
import 'package:tripper/ui/widgets/store-trip-map.dart';

class TripPlayer extends StatefulWidget {
  static const routeName = '/trip/player';
  final Trip _trip;
  TripPlayer(this._trip);

  @override
  _TripPlayerState createState() => _TripPlayerState();
}

class _TripPlayerState extends State<TripPlayer> {
  double availableHeight = 0;
  Trip trip;

  @override
  void initState() {
    super.initState();
    trip = widget._trip;
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.black,
    // ));

    init(context, trip);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildMap([int selectedPlaceId = 0]) {
    return Container(
      height: availableHeight * 0.4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.grey[400])),
              child: TripMap(trip, selectedPlaceId)),
        ),
      ),
    );
  }

  Widget buildSeekBar(MediaItem mediaItem, PlaybackState state) {
    return StreamBuilder(
      stream: Stream.periodic(Duration(seconds: 1)),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          child: SeekBar(
            duration: mediaItem?.duration ?? Duration(seconds: 0),
            position: state?.currentPosition ?? Duration(seconds: 0),
            onChangeEnd: (newPosition) {
              AudioService.seekTo(newPosition);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.black,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'tripper',
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
          child: StreamBuilder<ScreenState>(
            stream: screenStateStream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              final ScreenState screenState = snapshot.data;
              final List<MediaItem> queue = screenState?.queue;
              final MediaItem mediaItem = screenState?.mediaItem;
              final PlaybackState state = screenState?.playbackState;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //trip map
                  buildMap(
                      mediaItem?.extras != null ? mediaItem.extras['id'] : 0),
                  Container(
                    height: availableHeight * 0.6,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Column(
                          children: [
                            //trip & place name
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 8.0),
                                Text(mediaItem?.album ?? trip.name,
                                    style: _titleStyle),
                                Text(mediaItem?.displayTitle ?? '',
                                    style: _subtitleStyle),
                                const SizedBox(height: 8.0),
                                buildSeekBar(mediaItem, state),
                                ControlButtons(screenState, init, trip),
                              ],
                            ),

                            //seek bar
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text('places',
                                      style: _titleBigStyle,
                                      textAlign: TextAlign.center),
                                ),
                                ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: queue != null && queue.length > 0
                                      ? queue?.length
                                      : trip.places.length,
                                  itemBuilder: (context, index) =>
                                      queue != null && queue.length > 0
                                          ? Material(
                                              color: index ==
                                                      queue.indexOf(mediaItem)
                                                  ? Colors.grey.shade300
                                                  : null,
                                              child: ListTile(
                                                title: Text(queue[index].title,
                                                    style: _itemStyle),
                                                onTap: () {
                                                  AudioService.skipToQueueItem(
                                                      queue[index].id);
                                                },
                                              ),
                                            )
                                          : Material(
                                              child: ListTile(
                                                title: Text(
                                                    '${trip.places[index].order} . ${trip.places[index].name}',
                                                    style: _itemDisabledStyle),
                                              ),
                                            ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final Trip trip;
  final ScreenState screenState;
  final Function init;
  ControlButtons(this.screenState, this.init, this.trip);

  void initAndPlay(BuildContext context) async {
    await init(context, trip);
    AudioService.play();
  }

  @override
  Widget build(BuildContext context) {
    final queue = screenState?.queue ?? [];
    final mediaItem = screenState?.mediaItem;

    return StreamBuilder<PlaybackState>(
      stream: AudioService.playbackStateStream,
      builder: (context, snapshot) {
        final PlaybackState playerState = snapshot.data;
        final AudioProcessingState processingState =
            playerState?.processingState;
        final bool playing = playerState?.playing;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              color: Colors.grey[800],
              iconSize: 34.0,
              icon: Icon(Icons.skip_previous),
              onPressed:
                  // mediaItem == queue?.first ? null : AudioService.skipToPrevious,
                  !(queue != null && queue.isNotEmpty) ||
                          mediaItem == queue?.first
                      ? null
                      : AudioService.skipToPrevious,
            ),
            if (processingState == AudioProcessingState.connecting ||
                processingState == AudioProcessingState.buffering)
              Container(
                // margin: EdgeInsets.all(8.0),
                width: 74.0,
                height: 74.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.grey[400]),
                ),
              )
            else if (playing != true)
              IconButton(
                padding: const EdgeInsets.all(0),
                color: Colors.grey[800],
                icon: Icon(Icons.play_arrow),
                iconSize: 74.0,
                onPressed: () => processingState == null ||
                        processingState == AudioProcessingState.none
                    ? initAndPlay(context)
                    : AudioService.play(),
              )
            else if (processingState != AudioProcessingState.completed)
              IconButton(
                padding: const EdgeInsets.all(0),
                color: Colors.grey[800],
                icon: Icon(Icons.pause),
                iconSize: 74.0,
                onPressed: AudioService.pause,
              )
            else
              IconButton(
                padding: const EdgeInsets.all(0),
                color: Colors.grey[800],
                icon: Icon(Icons.replay),
                iconSize: 74.0,
                // onPressed: () => player.seek(Duration.zero, index: 0),
                onPressed: () => AudioService.seekTo(Duration.zero),
              ),
            IconButton(
              color: Colors.grey[800],
              icon: Icon(Icons.skip_next),
              iconSize: 34.0,
              onPressed: //mediaItem == queue?.last ? null : AudioService.skipToNext,
                  !(queue != null && queue.isNotEmpty) ||
                          mediaItem == queue?.last
                      ? null
                      : AudioService.skipToNext,
            ),
          ],
        );
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
    return Stack(
      children: [
        Slider(
          min: 0.0,
          activeColor: Colors.red[700],
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
        if (_remaining.inSeconds > 0)
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

final TextStyle _titleStyle =
    TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

final TextStyle _titleBigStyle = TextStyle(
    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[900]);

final TextStyle _itemStyle = TextStyle(
    fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.bold);

final TextStyle _itemDisabledStyle = TextStyle(
    fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold);

final TextStyle _subtitleStyle = TextStyle(
  fontSize: 16,
  color: Colors.black38,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.1,
);
