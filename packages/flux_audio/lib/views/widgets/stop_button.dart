import 'package:flutter/material.dart';
import 'package:fstore/services/audio/audio_manager.dart';
import 'package:fstore/services/dependency_injection.dart';

// create StopButton widget
class StopButton extends StatelessWidget {
  // define StopButton constructor
  const StopButton({super.key, this.size = 30});
  final double size;

  // define build method
  @override
  Widget build(BuildContext context) {
    final audioManager = injector<AudioManager>();
    return IconButton(
      icon: const Icon(Icons.stop),
      iconSize: size,
      onPressed: audioManager.stop,
      padding: const EdgeInsets.all(8.0),
      constraints: const BoxConstraints(),
    );
  }
}
