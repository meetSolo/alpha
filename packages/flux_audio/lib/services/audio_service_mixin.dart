import 'package:flutter/material.dart';

import 'package:fstore/common/config.dart';
import 'package:fstore/common/constants.dart';
import 'package:fstore/common/tools/flash.dart';
import 'package:fstore/models/audio/media_item.dart';
import 'package:fstore/models/entities/blog.dart';
import 'package:fstore/services/index.dart';
import '../views/audio_playlist_screen.dart';
import '../views/widgets/audio_blog_card.dart';
import '../views/widgets/audio_dialog.dart';
import '../views/widgets/audio_sticky.dart';

import 'audio_manager_impl.dart';

mixin FluxAudioHandlerMixin {
  AudioManager get audioManager => injector<AudioManager>();

  AudioManager getAudioService() {
    if (!(kBlogDetail['enableAudioSupport'] ?? false)) {
      return AudioServiceEmpty();
    }
    return AudioManagerImpl();
  }

  Widget getAudioWidget() => AudioStickyWidget(audioManager: audioManager);

  Widget renderAudioPlaylistScreen() =>
      AudioPlaylistScreen(audioManager: audioManager);

  Widget getAudioBlogCard(
    Blog blog, {
    ValueChanged<Blog>? addAll,
    ValueChanged<FluxMediaItem>? addItem,
    ValueChanged<FluxMediaItem>? playItem,
  }) =>
      AudioBlogCard(
        blog: blog,
        addAll: addAll,
        addItem: addItem,
        playItem: playItem,
      );

  void playMediaItem(BuildContext context, FluxMediaItem mediaItem) async {
    if (!audioManager.isStickyAudioWidgetActive) {
      await _requestOpenStickyAudio(context);
    }
    audioManager.playMediaItem(mediaItem);
  }

  void addMediaItemToPlaylist(
      BuildContext context, FluxMediaItem mediaItem) async {
    if (!audioManager.isStickyAudioWidgetActive) {
      await _requestOpenStickyAudio(context);
    }
    await audioManager.addMediaItem(mediaItem);
    if (audioManager.playlistNotifier.value.length == 1) {
      audioManager.play();
    }
    _showFlashMessage(context, 'Add media to playlist success.');
  }

  Future<void> addBlogAudioToPlaylist(BuildContext context, Blog blog) async {
    var audioUrls = blog.audioUrls;
    if (audioUrls.isNotEmpty) {
      try {
        var mediaList = <FluxMediaItem>[];
        for (var i = 0; i < audioUrls.length; i++) {
          final item = audioUrls[i];
          var mediaItem = FluxMediaItem(
            id: item,
            album: '',
            title: '${blog.title}${audioUrls.length > 1 ? ' (P${i + 1})' : ''}',
            artUri: blog.imageFeature.toUri(),
            urlSource: item,
            // duration: duration,
          );
          mediaList.add(mediaItem);
        }

        await audioManager.addListMediaItem(mediaList);

        _showFlashMessage(context,
            'Add media to playlist success. Add new ${mediaList.length} item');

        if (!audioManager.isStickyAudioWidgetActive) {
          await _requestOpenStickyAudio(context);
          audioManager.play();
        }

        // if (audioPlayerService.state.isPlaying == false) {
        //   audioPlayerService.playList();
        // }
      } catch (e) {
        printLog('[audio_components] Fail to load audio');
        _showFlashMessage(context, 'Add media to playlist fail',
            isSuccess: false);
      }
    }
  }

  void _showFlashMessage(context, String message, {bool isSuccess = true}) {
    FlashHelper.message(
      context,
      title: 'ADD MEDIA TO PLAYLIST',
      message: message,
      isError: !isSuccess,
    );
  }

  Future<void> _requestOpenStickyAudio(BuildContext context) async {
    if (kBlogDetail['enableAudioSupport']) {
      var isAccept = audioManager.autoPlay;
      if (isAccept == null) {
        isAccept = await showDialog(
          context: context,
          builder: (context) => const AudioDialog(),
        );
        audioManager.setAutoPlay(isAccept!);
      }
      if (isAccept) {
        audioManager.showStickyAudioWidget();
      }
    } else {
      audioManager.hideStickyAudioWidget();
    }
  }
}
