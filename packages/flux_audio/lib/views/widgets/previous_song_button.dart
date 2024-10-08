import 'package:flutter/material.dart';
import 'package:fstore/services/audio/audio_manager.dart';
import 'package:fstore/services/dependency_injection.dart';

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) {
    final audioManager = injector<AudioManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: audioManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: const Icon(Icons.skip_previous),
          padding: const EdgeInsets.all(8.0),
          iconSize: size,
          onPressed: (isFirst) ? null : audioManager.prev,
        );
      },
    );
  }
}
