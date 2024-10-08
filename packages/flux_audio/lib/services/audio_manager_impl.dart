import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'package:fstore/data/boxes.dart';
import 'package:fstore/models/audio/media_item.dart';
import 'package:fstore/models/audio/playlist_audio.dart';
import 'package:fstore/services/audio/audio_manager.dart';
import 'package:fstore/services/dependency_injection.dart';

class AudioManagerImpl extends AudioManager {
  late ValueNotifier<PlaylistAudio> _data;
  final _isStickyAudioWidgetActive = ValueNotifier(false);
  final _isFirstSongNotifier = ValueNotifier<bool>(true);
  final _isLastSongNotifier = ValueNotifier<bool>(true);
  final _progressNotifier = ProgressNotifier();
  final _playButtonNotifier = PlayButtonNotifier();

  // final _isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final _audioHandler = injector<AudioHandler>();
  final _playlistNotifier = ValueNotifier<List<FluxMediaItem>>([]);
  final _currentMediaItemNotifier = ValueNotifier<FluxMediaItem?>(null);
  final _speedNotifier = ValueNotifier<double>(1.0);

  bool? _autoPlay;

  @override
  bool? get autoPlay => _autoPlay;

  @override
  ValueNotifier<PlaylistAudio> get data => _data;

  @override
  ValueNotifier<bool> get stateStickyAudioWidget => _isStickyAudioWidgetActive;

  @override
  bool get isStickyAudioWidgetActive => _isStickyAudioWidgetActive.value;

  AudioManagerImpl() {
    timeCreate = '${DateTime.now()}';
    _autoPlay = true;
    // _loadDataPlaylistFromStorage();
    init();
  }

  // void _loadDataPlaylistFromStorage() {
  //   final dataPlaylist = _storage.getString(listAudioQueueKey);
  //   var playlist = PlaylistAudio(
  //     name: 'Queue Audio',
  //     createdAt: '${DateTime.now()}',
  //     playlist: <FluxMediaItem>[],
  //   );
  //
  //   try {
  //     if (dataPlaylist?.isNotEmpty ?? false) {
  //       playlist = PlaylistAudio.fromJson(jsonDecode(dataPlaylist!));
  //     }
  //   } catch (e) {
  //     debugPrint('--->Error load playlist: $e');
  //   }
  //
  //   _data = ValueNotifier(playlist);
  // }

  void init() {
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
    _listenToSpeedChange();
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.distinct().listen((playlist) {
      if (playlist.isEmpty) {
        _playlistNotifier.value = [];
        _currentMediaItemNotifier.value = null;
      } else {
        final newList = playlist.map(_convertMediaItemToFluxMediaItem).toList();
        _playlistNotifier.value = newList;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? oldState.total,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      _currentMediaItemNotifier.value = mediaItem == null
          ? null
          : _convertMediaItemToFluxMediaItem(mediaItem);
      _updateSkipButtons();
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToSpeedChange() {
    _audioHandler.playbackState.listen((playbackState) {
      _speedNotifier.value = playbackState.speed;
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  @override
  void playMediaItem(FluxMediaItem item, [bool isStart = false]) {
    _audioHandler.playMediaItem(item.toMediaItem());
  }

  @override
  void play() => _audioHandler.play();

  @override
  void next() => _audioHandler.skipToNext();

  @override
  void prev() {
    _audioHandler.skipToPrevious();
  }

  @override
  void replay() {}

  @override
  void seek(Duration duration) => _audioHandler.seek(duration);

  @override
  void setRepeat(bool isRepeat) {}

  @override
  void setAutoNext(bool autoNextEnabled) {}

  @override
  void stop() {
    _audioHandler.stop();
    _isStickyAudioWidgetActive.value = false;
    _audioHandler.seek(Duration.zero);
  }

  @override
  void pause() => _audioHandler.pause();

  @override
  void dispose() {
    stop();
    _data.dispose();
  }

  Duration cachePosition = Duration.zero;

  @override
  void setAutoPlay(bool isAutoPlay) {
    _autoPlay = isAutoPlay;
    SettingsBox().autoPlayAudio = isAutoPlay;
  }

  @override
  void savePlaylist() {
    // _storage.setString(listAudioQueueKey, data.value.toString());
  }

  @override
  void removeMediaItem(FluxMediaItem mediaItem) {
    _audioHandler.removeQueueItem(mediaItem.toMediaItem());
  }

  @override
  ValueNotifier<bool> get isFirstSongNotifier => _isFirstSongNotifier;

  @override
  ValueNotifier<bool> get isLastSongNotifier => _isLastSongNotifier;

  @override
  ValueNotifier<ButtonState> get playButtonNotifier => _playButtonNotifier;

  @override
  ValueNotifier<ProgressBarState> get progressNotifier => _progressNotifier;

  @override
  ValueNotifier<List<FluxMediaItem>> get playlistNotifier => _playlistNotifier;

  @override
  ValueNotifier<FluxMediaItem?> get currentMediaItemNotifier =>
      _currentMediaItemNotifier;

  @override
  void hideStickyAudioWidget() {
    _isStickyAudioWidgetActive.value = false;
  }

  @override
  void showStickyAudioWidget() {
    _isStickyAudioWidgetActive.value = true;
  }

  FluxMediaItem _convertMediaItemToFluxMediaItem(MediaItem mediaItem) {
    return FluxMediaItem(
      id: mediaItem.id,
      title: mediaItem.title,
      album: mediaItem.album,
      artist: mediaItem.artist,
      artUri: mediaItem.artUri,
      displayDescription: mediaItem.displayDescription,
      displaySubtitle: mediaItem.displaySubtitle,
      displayTitle: mediaItem.displayTitle,
      duration: mediaItem.duration,
      extras: mediaItem.extras,
      genre: mediaItem.genre,
      playable: mediaItem.playable,
    );
  }

  @override
  Future<void> addMediaItem(FluxMediaItem mediaItem) async {
    final isContain = _audioHandler.queue.value
            .indexWhere((element) => element.id == mediaItem.id) !=
        -1;
    if (!isContain) {
      await _audioHandler.addQueueItem(mediaItem.toMediaItem());
    }
  }

  @override
  Future<void> addListMediaItem(List<FluxMediaItem> listMediaItem) async {
    final newList = <FluxMediaItem>[];

    /// Check duplicate item
    for (final item in listMediaItem) {
      final isContain = _audioHandler.queue.value
              .indexWhere((element) => element.id == item.id) !=
          -1;
      if (!isContain) newList.add(item);
    }

    if (newList.isNotEmpty) {
      await _audioHandler
          .addQueueItems(newList.map((e) => e.toMediaItem()).toList());
    }
    // if (listMediaItem.length == listMediaItem.length &&
    //     !_audioHandler.playbackState.value.playing) {
    //   await _audioHandler.play();
    // }
  }

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    await _audioHandler.playFromMediaId(mediaId, extras);
  }

  @override
  Future<void> fastForward() async => _audioHandler.fastForward();

  @override
  Future<void> rewind() async => _audioHandler.rewind();

  @override
  ValueNotifier<double> get speedNotifier => _speedNotifier;

  @override
  Future<void> setSpeed(double speed) async {
    await _audioHandler.setSpeed(speed);
  }
}

extension FluxMediaExtension on FluxMediaItem {
  MediaItem toMediaItem() {
    return MediaItem(
        id: id,
        title: title,
        album: album,
        artist: artist,
        artUri: artUri,
        displayDescription: displayDescription,
        displaySubtitle: displaySubtitle,
        displayTitle: displayTitle,
        duration: duration,
        genre: genre,
        playable: playable,
        extras: {
          ...?extras,
          'url': urlSource,
        });
  }
}
