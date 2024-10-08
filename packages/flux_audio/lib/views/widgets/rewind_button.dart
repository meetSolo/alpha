import 'package:flutter/material.dart';
import 'package:fstore/services/audio/audio_manager.dart';
import 'package:fstore/services/dependency_injection.dart';

class RewindButton extends StatelessWidget {
  const RewindButton({super.key, this.size = 30});
  final double size;
  @override
  Widget build(BuildContext context) {
    final audioManager = injector.get<AudioManager>();
    return IconButton(
      icon: const Icon(Icons.replay_10),
      iconSize: size,
      onPressed: audioManager.rewind,
      padding: const EdgeInsets.all(8.0),
      constraints: const BoxConstraints(),
    );
  }
}
