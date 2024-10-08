import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: MyAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.inspireui.fluxstore',
      androidNotificationChannelName: 'Audio Service',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  final _speed = ValueNotifier<double>(1.0);

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
    _listenForSpeedChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      printLog('Error: $e');
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      // final distinct = queue.distinct();
      // if (distinct.hasValue) {
      //   queue.add(distinct.);
      // }
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (!playlist.asMap().containsKey(index)) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      mediaItem.add(playlist[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  void _listenForSpeedChanges() {
    _speed.addListener(_speedListener);
  }

  void _speedListener() {
    EasyDebounce.debounce(
      'debounceSpeedChange',
      const Duration(milliseconds: 250),
      () =>
          playbackState.add(playbackState.value.copyWith(speed: _speed.value)),
    );
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    final audioSource = mediaItems.map(_createAudioSource);
    unawaited(_playlist.addAll(audioSource.toList()));

    // notify system
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // manage Just Audio
    final audioSource = _createAudioSource(mediaItem);
    await _playlist.add(audioSource);

    // notify system
    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url']),
      tag: mediaItem,
    );
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    // manage Just Audio
    unawaited(_playlist.removeAt(index));

    // notify system
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    // final isDeleteCurrentItemPlaying = mediaItem.id == this.mediaItem.value?.id;
    // if (isDeleteCurrentItemPlaying) {
    //   if (_player.playing) {
    //     await stop();
    //   }
    // }
    // manage Just Audio
    final index =
        queue.value.indexWhere((element) => element.id == mediaItem.id);
    final currentIndexPlaying = queue.value
        .indexWhere((element) => this.mediaItem.value?.id == element.id);

    // notify system
    final newQueue = queue.value..removeAt(index);
    await _playlist.removeAt(index);
    queue.add(newQueue);
    if (index < currentIndexPlaying) {
      final newMediaItem = queue.value[currentIndexPlaying - 1]
          .copyWith(duration: _player.duration);
      this.mediaItem.add(newMediaItem);
    }

    // Process delete item is playing
    // if (isDeleteCurrentItemPlaying) {
    //   if (newQueue.isNotEmpty) {
    //     await _player.seekToPrevious();
    //     await play();
    //     return;
    //   }
    //   await _player.seek(Duration.zero, index: 0);
    //   await play();
    // }
    // this.mediaItem.add(newQueue[index]);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() async {
    await _player.seekToNext();
    if (!_player.playing) {
      unawaited(_player.play());
    }
  }

  @override
  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
    if (!_player.playing) {
      unawaited(_player.play());
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        unawaited(_player.setLoopMode(LoopMode.off));
        break;
      case AudioServiceRepeatMode.one:
        unawaited(_player.setLoopMode(LoopMode.one));
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        unawaited(_player.setLoopMode(LoopMode.all));
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      unawaited(_player.setShuffleModeEnabled(false));
    } else {
      await _player.shuffle();
      unawaited(_player.setShuffleModeEnabled(true));
    }
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      _speed.removeListener(_speedListener);
      await _player.dispose();
      unawaited(super.stop());
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    // manage Just Audio
    if (_player.playing) {
      await _player.stop();
    }

    final audioSource = _createAudioSource(mediaItem);
    await _playlist.clear();
    await _playlist.add(audioSource);

    // notify system
    queue.add([mediaItem]);
    this.mediaItem.add(mediaItem);
    await _player.seek(Duration.zero, index: 0);

    await _player.play();
  }

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    final index = queue.value.indexWhere((element) => element.id == mediaId);
    await _player.seek(Duration.zero, index: index);
    if (!_player.playing) {
      await _player.play();
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    _speed.value = speed;
    await _player.setSpeed(speed);
  }

  @override
  Future<void> stop() async {
    unawaited(_player.seek(Duration.zero, index: 0));
    await _player.stop();
    await _playlist.clear();
    queue.add([]);
    return super.stop();
  }
}
