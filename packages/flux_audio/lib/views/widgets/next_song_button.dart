import 'package:flutter/material.dart';
import 'package:fstore/services/audio/audio_manager.dart';
import 'package:fstore/services/dependency_injection.dart';

class NextSongButton extends StatelessWidget {
  const NextSongButton({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) {
    final audioManager = injector<AudioManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: audioManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: size,
          padding: const EdgeInsets.all(8.0),
          onPressed: (isLast) ? null : audioManager.next,
        );
      },
    );
  }
}
