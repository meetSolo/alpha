import 'package:flutter/material.dart';
import 'package:fstore/services/audio/audio_manager.dart';
import 'package:fstore/services/dependency_injection.dart';

class PlayButton extends StatefulWidget {
  const PlayButton({super.key, this.size = 40});
  final double size;

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  double get size => widget.size;
  @override
  Widget build(BuildContext context) {
    final audioManger = injector<AudioManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: audioManger.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: size,
              height: size,
              child: const CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: size,
              padding: const EdgeInsets.all(8.0),
              onPressed: audioManger.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: size,
              padding: const EdgeInsets.all(8.0),
              onPressed: audioManger.pause,
            );
        }
      },
    );
  }
}
