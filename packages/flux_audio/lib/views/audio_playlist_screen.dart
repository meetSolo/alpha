import 'package:flutter/material.dart';
import 'package:fstore/generated/l10n.dart';
import 'package:fstore/models/index.dart';
import 'package:fstore/services/audio/audio_manager.dart';
import 'package:fstore/widgets/common/index.dart' show FluxImage;

import '../mixins/audio_player_mixin.dart';
import 'widgets/audio_progress_bar.dart';

class AudioPlaylistScreen extends StatefulWidget {
  final AudioManager audioManager;

  const AudioPlaylistScreen({super.key, required this.audioManager});

  @override
  State<AudioPlaylistScreen> createState() => _AudioPlaylistScreenState();
}

class _AudioPlaylistScreenState extends State<AudioPlaylistScreen> {
  AudioManager get audioManager => widget.audioManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        // leading: IconButton(
        //   onPressed: Navigator.of(context).pop,
        //   icon: const Icon(Icons.close),
        // ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        // title: FluxImage(
        //   imageUrl:
        //       Provider.of<AppModel>(context, listen: false).themeConfig.logo,
        //   height: 40,
        // ),
        // centerTitle: true,
      ),
      body: ValueListenableBuilder<List<FluxMediaItem>>(
        valueListenable: audioManager.playlistNotifier,
        builder: (context, playlist, child) {
          return Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<FluxMediaItem?>(
                  valueListenable: audioManager.currentMediaItemNotifier,
                  builder: (context, mediaItemPlaying, child) {
                    return ListView.builder(
                      itemCount: playlist.length,
                      itemBuilder: (_, index) {
                        final mediaItem = playlist[index];
                        final isActive = mediaItemPlaying != null &&
                            mediaItem.id == mediaItemPlaying.id;
                        return Dismissible(
                          key: ValueKey(mediaItem.id),
                          direction: isActive
                              ? DismissDirection.none
                              : DismissDirection.endToStart,
                          onDismissed: (direction) {
                            // Remove the item from the data source.
                            audioManager.removeMediaItem(mediaItem);

                            // Then show a snackbar.
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${mediaItem.title} removed'),
                            ));
                          },
                          background: Container(
                            color: Theme.of(context).colorScheme.error,
                            padding: const EdgeInsets.only(right: 8),
                            alignment: Alignment.centerRight,
                            child: Text(
                              S.of(context).remove,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => isActive
                                ? null
                                : audioManager.playFromMediaId(mediaItem.id),
                            child: _AudioPlaylistItem(
                              mediaItem: mediaItem,
                              isActive: isActive,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 5),
                height: 160,
                child: const Card(
                  margin: EdgeInsets.zero,
                  child: _AudioControl(),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _AudioControl extends StatelessWidget with AudioPlayerWidgetMixin {
  const _AudioControl();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: AudioProgressBar(),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              prevButton(),
              playButton(),
              nextButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _AudioPlaylistItem extends StatelessWidget {
  const _AudioPlaylistItem({
    required this.mediaItem,
    this.isActive = false,
  });
  final FluxMediaItem mediaItem;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isActive
          ? Theme.of(context).scaffoldBackgroundColor
          : Theme.of(context).colorScheme.surface,
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (mediaItem.artUri != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: FluxImage(
                  imageUrl: mediaItem.artUri.toString(),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: Text(
              mediaItem.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
