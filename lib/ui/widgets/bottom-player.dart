import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripper/core/utils/s3-auth-headers.dart';
import 'package:tripper/providers/trip.provider.dart';
import 'package:tripper/ui/screens/trip-player.dart';
import 'package:tripper/ui/utils/brackground-audio-player.dart';

class BottomPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ScreenState>(
      stream: screenStateStream.asBroadcastStream(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final ScreenState screenState = snapshot.data;
        final List<MediaItem> queue = screenState?.queue;
        final MediaItem mediaItem = screenState?.mediaItem;
        final PlaybackState state = screenState?.playbackState;

        if ((state?.processingState == AudioProcessingState.none ||
                state == null) ||
            !AudioService.running)
          return Container(
            height: 0,
            width: 0,
            color: Colors.transparent,
          );
        else
          return Container(
            height: 60,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(TripPlayer.routeName, arguments: {
                      'trip': Provider.of<TripProvider>(context, listen: false)
                          .findById(queue[0].extras['tripId'])
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: mediaItem?.artUri ?? queue[0].artUri,
                              fit: BoxFit.cover,
                              httpHeaders: generateAuthHeaders(
                                  mediaItem?.artUri ?? queue[0].artUri,
                                  context),
                              placeholder: (context, url) => Center(
                                child: Opacity(
                                  opacity: 0.5,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 0.5,
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.grey[100]),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Theme.of(context)
                                        .scaffoldBackgroundColor
                                        .withOpacity(0.7),
                                    Theme.of(context).scaffoldBackgroundColor
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(TripPlayer.routeName, arguments: {
                          'trip':
                              Provider.of<TripProvider>(context, listen: false)
                                  .findById(queue[0].extras['tripId'])
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mediaItem?.displayTitle?.toLowerCase() ??
                                queue[0].displayTitle.toLowerCase() ??
                                '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                              letterSpacing: 0.5,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            mediaItem?.displaySubtitle ??
                                queue[0].displaySubtitle ??
                                '',
                            style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.5,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: Icon(
                        Icons.stop,
                        size: 40,
                        color: Colors.grey[800],
                      ),
                      onPressed: AudioService.stop,
                    ),
                    const SizedBox(width: 5),
                    if (state.processingState ==
                            AudioProcessingState.connecting ||
                        state.processingState == AudioProcessingState.buffering)
                      Container(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.grey[400]),
                        ),
                      )
                    else if (AudioService.playbackState.playing != true)
                      IconButton(
                        padding: const EdgeInsets.all(0),
                        color: Colors.grey[800],
                        icon: Icon(Icons.play_arrow),
                        iconSize: 40,
                        onPressed: AudioService.play,
                      )
                    else if (state.processingState !=
                        AudioProcessingState.completed)
                      IconButton(
                        padding: const EdgeInsets.all(0),
                        color: Colors.grey[800],
                        icon: Icon(Icons.pause),
                        iconSize: 40,
                        onPressed: AudioService.pause,
                      )
                    else
                      IconButton(
                        padding: const EdgeInsets.all(0),
                        color: Colors.grey[800],
                        icon: Icon(Icons.replay),
                        iconSize: 40,
                        onPressed: () => AudioService.seekTo(Duration.zero),
                      ),
                    const SizedBox(width: 15),
                  ],
                ),
              ],
            ),
          );
      },
    );
  }
}
