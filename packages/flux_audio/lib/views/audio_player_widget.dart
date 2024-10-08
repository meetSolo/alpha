import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:fstore/models/audio/media_item.dart';
import 'package:fstore/screens/index.dart';
import 'package:fstore/services/audio/audio_manager.dart';
import 'package:fstore/widgets/common/index.dart' show FluxImage;
import 'package:inspireui/inspireui.dart';

import '../mixins/audio_player_mixin.dart';
import 'widgets/audio_progress_bar.dart';

class AudioPlayerWidget extends StatefulWidget {
  final AudioManager audioService;

  const AudioPlayerWidget({required this.audioService});

  @override
  BaseScreen<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends BaseScreen<AudioPlayerWidget>
    with AudioPlayerWidgetMixin {
  @override
  AudioManager get audioManager => widget.audioService;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ValueListenableBuilder<FluxMediaItem?>(
        valueListenable: audioManager.currentMediaItemNotifier,
        builder: (_, mediaItem, __) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: ClipRect(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: Stack(
                                alignment: Alignment.center,
                                fit: StackFit.expand,
                                children: [
                                  if (mediaItem != null)
                                    FluxImage(
                                      imageUrl: mediaItem.artUri.toString(),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  else
                                    const SizedBox(width: 10),
                                  IgnorePointer(
                                    ignoring: true,
                                    child: ValueListenableBuilder<ButtonState>(
                                      valueListenable:
                                          audioManager.playButtonNotifier,
                                      builder: (context, buttonState, child) {
                                        return AnimatedOpacity(
                                          opacity:
                                              buttonState == ButtonState.loading
                                                  ? 1
                                                  : 0,
                                          duration:
                                              const Duration(milliseconds: 100),
                                          child: Container(
                                            color: Colors.black45,
                                            child: Container(
                                              margin: const EdgeInsets.all(8.0),
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (mediaItem?.title.isEmpty ?? true)
                              const Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Skeleton(
                                      width: 500,
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Skeleton(
                                      width: 80,
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Skeleton(
                                      width: 100,
                                      height: 10,
                                    ),
                                  ],
                                ),
                              )
                            else
                              Flexible(
                                child: Text(
                                  mediaItem!.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          prevButton(size: 20),
                          playButton(size: 20),
                          nextButton(size: 20),
                          stopButton(size: 20),
                        ].map((e) => Expanded(child: e)).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              /* Seek Bar */
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: AudioProgressBar(
                  timeLabelLocation: TimeLabelLocation.sides,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
