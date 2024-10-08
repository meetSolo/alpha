import 'package:flutter/material.dart';

import 'package:fstore/services/audio/audio_manager.dart';
import 'package:fstore/services/dependency_injection.dart';
import '../views/widgets/fast_forward_button.dart';
import '../views/widgets/next_song_button.dart';
import '../views/widgets/play_button.dart';
import '../views/widgets/previous_song_button.dart';
import '../views/widgets/rewind_button.dart';
import '../views/widgets/stop_button.dart';

mixin AudioPlayerWidgetMixin {
  AudioManager get audioManager => injector<AudioManager>();

  IconButton replayButton({double size = 20}) => IconButton(
        icon: const Icon(Icons.replay),
        iconSize: size,
        onPressed: () => audioManager.seek(const Duration(seconds: 1)),
        padding: const EdgeInsets.all(10.0),
        constraints: const BoxConstraints(),
      );

  Widget playButton({double size = 70}) => PlayButton(size: size);

  Widget nextButton({double size = 30}) => NextSongButton(size: size);

  Widget prevButton({double size = 30}) => PreviousSongButton(size: size);

  Widget rewindButton({double size = 30}) => RewindButton(size: size);

  Widget fastForwardButton({double size = 30}) => FastForwardButton(size: size);

  Widget stopButton({double size = 40}) => StopButton(size: size);
}
