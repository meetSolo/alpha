import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:fstore/services/audio/audio_manager.dart';
import 'package:fstore/services/dependency_injection.dart';

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({super.key, this.timeLabelLocation});
  final TimeLabelLocation? timeLabelLocation;

  @override
  Widget build(BuildContext context) {
    final audioManager = injector<AudioManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: audioManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: audioManager.seek,
          timeLabelLocation: timeLabelLocation,
        );
      },
    );
  }
}
