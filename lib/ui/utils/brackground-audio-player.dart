import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tripper/core/models/trip.model.dart';
import 'package:tripper/providers/download.provider.dart';
import 'package:tripper/providers/trip.provider.dart';

void audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

init(BuildContext context, Trip trip) async {
  DownloadProvider downloads =
      Provider.of<DownloadProvider>(context, listen: false);
  TripProvider trips = Provider.of<TripProvider>(context, listen: false);

  print(AudioService.playbackState?.processingState);

  if (AudioService.playbackState?.processingState != null &&
      AudioService.playbackState?.processingState !=
          AudioProcessingState.none &&
      AudioService.queue?.first?.album != trip.name) {
    await AudioService.stop();
  }

  var _items = await Future.wait(
      trip.places.map<Future<Map<String, dynamic>>>((place) async {
    String id = '';
    if (downloads.existsByPlace(place.id)) {
      //Load local audio file
      id = 'file://${downloads.getByPlace(place.id).first.filePath}';
    } else {
      id = await trips.getPlaceDownloadUrl(place.fullAudioUrl, true);
    }

    // var p = AudioPlayer();
    // Duration duration =
    //     await AudioPlayer().load(AudioSource.uri(Uri.parse(id)));
    // await p.dispose();

    return {
      'id': id,
      'album': trip.name.toLowerCase(),
      'title': '${place.order} . ${place.name}',
      'displayTitle': place.name.toLowerCase(),
      'displaySubtitle': trip.name.toLowerCase(),
      'artUri': place.imageUrl,
      // 'duration': duration.inMilliseconds,
      'duration': place.fullAudioLength.round() * 1000,
      'extras': {'id': place.id, 'tripId': place.tripId}
    };
  }).toList());

  AudioService.start(
    backgroundTaskEntrypoint: audioPlayerTaskEntrypoint,
    androidNotificationChannelName: 'tripper',
    params: {'items': json.encode(_items)},
    // Enable this if you want the Android service to exit the foreground state on pause.
    androidStopForegroundOnPause: true,
    androidNotificationColor: 0xFF2196f3,
    androidEnableQueue: true,
  );
}

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer player = new AudioPlayer();
  MediaLibrary _mediaLibrary;
  AudioProcessingState _skipState;
  StreamSubscription<PlaybackEvent> _eventSubscription;

  List<MediaItem> get queue => _mediaLibrary.items;
  int get index => player.currentIndex;
  MediaItem get mediaItem => index == null ? null : queue[index];
  Stream<Duration> get durationStream => player.durationStream;
  Duration get duration => player.duration;

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    final session = await AudioSession.instance;
    // await session.configure(AudioSessionConfiguration.speech());
    await session.setActive(true);

    var itemsJson = json.decode(params['items']);
    var _items =
        itemsJson.map<MediaItem>((i) => MediaItem.fromJson(i)).toList();
    _mediaLibrary = MediaLibrary(_items);

    // Broadcast media item changes.
    player.currentIndexStream.listen((index) {
      if (index != null) AudioServiceBackground.setMediaItem(queue[index]);
    });

    // Propagate all events from the audio player to AudioService clients.
    _eventSubscription = player.playbackEventStream.listen((event) {
      _broadcastState();
    });

    // Special processing for state transitions.
    player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          // In this example, the service stops when reaching the end.
          // onStop();
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
      await player.load(ConcatenatingAudioSource(
        children:
            queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
      ));

      // In this example, we automatically start playing on start.
      // onPlay();
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
    player.seek(Duration.zero, index: newIndex);
  }

  @override
  Future<void> onPlay() {
    player.play();
    return null;
  }

  @override
  Future<void> onPause() => player.pause();

  @override
  Future<void> onSeekTo(Duration position) => player.seek(position);

  @override
  Future<void> onStop() async {
    await player.pause();
    await player.dispose();
    _eventSubscription.cancel();
    // It is important to wait for this state to be broadcast before we shut
    // down the task. If we don't, the background task will be destroyed before
    // the message gets sent to the UI.
    await _broadcastState();
    final session = await AudioSession.instance;
    await session.setActive(false);
    // Shut down this task
    await super.onStop();
  }

  /// Broadcasts the current state to all clients.
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      processingState: _getProcessingState(),
      playing: player.playing,
      position: player.position ?? Duration.zero,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
    );
  }

  /// Maps just_audio's processing state into into audio_service's playing
  /// state. If we are in the middle of a skip, we use [_skipState] instead.
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (player.processingState) {
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
        throw Exception("Invalid state: ${player.processingState}");
    }
  }
}

class MediaLibrary {
  var _items = <MediaItem>[];
  MediaLibrary(this._items);
  List<MediaItem> get items => _items;
}

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

Stream<ScreenState> get screenStateStream =>
    Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
        AudioService.queueStream,
        AudioService.currentMediaItemStream,
        AudioService.playbackStateStream,
        (queue, mediaItem, playbackState) =>
            ScreenState(queue, mediaItem, playbackState));
