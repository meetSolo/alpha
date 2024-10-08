import 'package:flutter/material.dart';
import 'package:fstore/services/audio/audio_manager.dart';
import 'package:fstore/services/dependency_injection.dart';

const _minValue = 0.5;
const _maxValue = 2.0;

class SpeedButton extends StatelessWidget {
  const SpeedButton({super.key});

  @override
  Widget build(BuildContext context) {
    final audioManager = injector<AudioManager>();
    return ValueListenableBuilder<double>(
      valueListenable: audioManager.speedNotifier,
      builder: (context, speed, child) {
        return InkWell(
          onTap: () {
            var currentSpeedValue = speed;
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, StateSetter setState) {
                      return SizedBox(
                        height: MediaQuery.of(context).copyWith().size.height *
                            (1 / 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Slider(
                              onChanged: (double value) {
                                setState(() {
                                  currentSpeedValue = value;
                                });
                              },
                              onChangeEnd: audioManager.setSpeed,
                              value: currentSpeedValue,
                              min: _minValue,
                              max: _maxValue,
                              divisions: 6,
                              label: '${currentSpeedValue.toStringAsFixed(2)}x',
                            ),
                            DefaultTextStyle(
                              style: Theme.of(context).textTheme.headlineSmall!,
                              textAlign: TextAlign.right,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Row(
                                  children: [
                                    Text('$_minValue'),
                                    Expanded(flex: 5, child: Text('1.0')),
                                    Expanded(
                                      flex: 10,
                                      child: Text('$_maxValue'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                });
          },
          child: Column(
            children: [
              TextButton(
                onPressed: null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(4.0),
                  backgroundColor: Colors.transparent,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      speed.toString(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'x',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Text('Speed'),
            ],
          ),
        );
      },
    );
  }
}
