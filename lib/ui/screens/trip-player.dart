import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tripit/core/models/trip.model.dart';
import 'package:tripit/providers/download.provider.dart';
import 'package:tripit/providers/trip.provider.dart';
import 'package:tripit/ui/widgets/store-trip-map.dart';
import 'package:rxdart/rxdart.dart';

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

    var _items = await Future.wait(
        trip.places.map<Future<Map<String, String>>>((place) async {
      String id = '';
      if (downloads.existsByPlace(place.id)) {
        //Load local audio file
        id = 'file://${downloads.getByPlace(place.id).first.filePath}';
      } else {
        id = await trips.getPlaceDownloadUrl(place.fullAudioUrl, true);
      }
      return {
        'id': id,
        'album': trip.name,
        'title': '${place.order}. ${place.name}',
        'artUri': place.imageUrl
      };
    }).toList());

    AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'tripit',
      params: {'items': json.encode(_items)},
      // Enable this if you want the Android service to exit the foreground state on pause.
      //androidStopForegroundOnPause: true,
      androidNotificationColor: 0xFF2196f3,
      // androidNotificationIcon: 'mipmap/ic_launcher',
      androidEnableQueue: true,
    );

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
                // onPressed: player.play,
                onPressed: AudioService.play,
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

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

Stream<ScreenState> get _screenStateStream =>
    Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
        AudioService.queueStream,
        AudioService.currentMediaItemStream,
        AudioService.playbackStateStream,
        (queue, mediaItem, playbackState) =>
            ScreenState(queue, mediaItem, playbackState));

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

class AudioPlayerTask extends BackgroundAudioTask {
  MediaLibrary _mediaLibrary;
  AudioPlayer _player = new AudioPlayer();
  AudioProcessingState _skipState;
  Seeker _seeker;
  StreamSubscription<PlaybackEvent> _eventSubscription;

  List<MediaItem> get queue => _mediaLibrary.items;
  int get index => _player.currentIndex;
  MediaItem get mediaItem => index == null ? null : queue[index];

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

    var itemsJson = json.decode(params['items']);
    var _items =
        itemsJson.map<MediaItem>((i) => MediaItem.fromJson(i)).toList();
    _mediaLibrary = MediaLibrary(_items);

    // Broadcast media item changes.
    _player.currentIndexStream.listen((index) {
      if (index != null) AudioServiceBackground.setMediaItem(queue[index]);
    });

    // Propagate all events from the audio player to AudioService clients.
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });

    // Special processing for state transitions.
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          // In this example, the service stops when reaching the end.
          onStop();
          break;
        case ProcessingState.ready:
          // If we just came from skipping between tracks, clear the skip
          // state now that we're ready to play.
          _skipState = null;
          break;
        default:
          break;
      }
    });

    // Load and broadcast the queue
    AudioServiceBackground.setQueue(queue);
    try {
      await _player.load(ConcatenatingAudioSource(
        children:
            queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
      ));
      // In this example, we automatically start playing on start.
      onPlay();
    } catch (e) {
      print("Error: $e");
      onStop();
    }
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    // Then default implementations of onSkipToNext and onSkipToPrevious will
    // delegate to this method.
    final newIndex = queue.indexWhere((item) => item.id == mediaId);
    if (newIndex == -1) return;
    // During a skip, the player may enter the buffering state. We could just
    // propagate that state directly to AudioService clients but AudioService
    // has some more specific states we could use for skipping to next and
    // previous. This variable holds the preferred state to send instead of
    // buffering during a skip, and it is cleared as soon as the player exits
    // buffering (see the listener in onStart).
    _skipState = newIndex > index
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;
    // This jumps to the beginning of the queue item at newIndex.
    _player.seek(Duration.zero, index: newIndex);
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  @override
  Future<void> onFastForward() => _seekRelative(fastForwardInterval);

  @override
  Future<void> onRewind() => _seekRelative(-rewindInterval);

  @override
  Future<void> onSeekForward(bool begin) async => _seekContinuously(begin, 1);

  @override
  Future<void> onSeekBackward(bool begin) async => _seekContinuously(begin, -1);

  @override
  Future<void> onStop() async {
    await _player.pause();
    await _player.dispose();
    _eventSubscription.cancel();
    // It is important to wait for this state to be broadcast before we shut
    // down the task. If we don't, the background task will be destroyed before
    // the message gets sent to the UI.
    await _broadcastState();
    // Shut down this task
    await super.onStop();
  }

  /// Jumps away from the current position by [offset].
  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    // Make sure we don't jump out of bounds.
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
    // Perform the jump via a seek.
    await _player.seek(newPosition);
  }

  /// Begins or stops a continuous seek in [direction]. After it begins it will
  /// continue seeking forward or backward by 10 seconds within the audio, at
  /// intervals of 1 second in app time.
  void _seekContinuously(bool begin, int direction) {
    _seeker?.stop();
    if (begin) {
      _seeker = Seeker(_player, Duration(seconds: 10 * direction),
          Duration(seconds: 1), mediaItem)
        ..start();
    }
  }

  /// Broadcasts the current state to all clients.
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      processingState: _getProcessingState(),
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  /// Maps just_audio's processing state into into audio_service's playing
  /// state. If we are in the middle of a skip, we use [_skipState] instead.
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (_player.processingState) {
      case ProcessingState.none:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }
}

class Seeker {
  final AudioPlayer player;
  final Duration positionInterval;
  final Duration stepInterval;
  final MediaItem mediaItem;
  bool _running = false;

  Seeker(
    this.player,
    this.positionInterval,
    this.stepInterval,
    this.mediaItem,
  );

  start() async {
    _running = true;
    while (_running) {
      Duration newPosition = player.position + positionInterval;
      if (newPosition < Duration.zero) newPosition = Duration.zero;
      if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
      player.seek(newPosition);
      await Future.delayed(stepInterval);
    }
  }

  stop() {
    _running = false;
  }
}

class MediaLibrary {
  var _items = <MediaItem>[];
  MediaLibrary(this._items);
  List<MediaItem> get items => _items;
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
