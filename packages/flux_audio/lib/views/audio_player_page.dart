import 'package:flutter/material.dart';
import 'package:fstore/common/constants.dart';
import 'package:fstore/generated/l10n.dart';
import 'package:fstore/menu/index.dart';
import 'package:fstore/models/audio/media_item.dart';
import 'package:fstore/services/audio/audio_manager.dart';
import 'package:fstore/widgets/common/index.dart' show FluxImage;
import 'package:fstore/widgets/overlay/custom_overlay_state.dart';

import '../mixins/audio_player_mixin.dart';
import 'widgets/audio_progress_bar.dart';
import 'widgets/speed_button.dart';

class AudioPlayerPage extends StatefulWidget {
  final AudioManager audioManager;

  const AudioPlayerPage({super.key, required this.audioManager});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage>
    with AudioPlayerWidgetMixin {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FluxMediaItem?>(
      valueListenable: audioManager.currentMediaItemNotifier,
      builder: (_, mediaItem, __) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          iconSize: 32,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context, true);
                          audioManager
                            ..stop()
                            ..hideStickyAudioWidget();
                        },
                        child: Text(S.of(context).stop),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 6,
                      child: mediaItem?.artUri != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                left: 30,
                                right: 30,
                                bottom: 20,
                                top: 10,
                              ),
                              child: Card(
                                elevation: 20,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: FluxImage(
                                    imageUrl: mediaItem!.artUri.toString(),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.disc_full,
                              size: 60,
                            ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                mediaItem?.title ?? '',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleLarge!
                                    .copyWith(fontWeight: FontWeight.w800),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const AudioProgressBar(),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // openPlaylistButton(),
                                prevButton(),
                                rewindButton(),
                                playButton(),
                                fastForwardButton(),
                                nextButton(),
                                // replayButton(),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                openPlaylistButton(),
                                const SpeedButton(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget openPlaylistButton() => Column(
        children: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            iconSize: 30,
            padding: const EdgeInsets.all(8.0),
            onPressed: () async {
              await Navigator.of(context).pushNamed(RouteList.audioPlaylist);

              OverlayControlDelegate().emitTab?.call(
                    MainTabControlDelegate.getInstance().currentTabName(),
                  );
            },
            constraints: const BoxConstraints(),
          ),
          const Text('Playlist'),
        ],
      );
}
