import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/devotional_post.dart';

class AudioState {
  final DevotionalPost? currentPost;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isFullPlayerVisible;

  const AudioState({
    this.currentPost,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = const Duration(minutes: 4, seconds: 15),
    this.isFullPlayerVisible = false,
  });

  AudioState copyWith({
    DevotionalPost? currentPost,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isFullPlayerVisible,
  }) {
    return AudioState(
      currentPost: currentPost ?? this.currentPost,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isFullPlayerVisible: isFullPlayerVisible ?? this.isFullPlayerVisible,
    );
  }
}

class AudioServiceNotifier extends StateNotifier<AudioState> {
  Timer? _timer;

  AudioServiceNotifier() : super(const AudioState());

  void playPost(DevotionalPost post) {
    if (state.currentPost?.id == post.id && state.isPlaying) {
      pause();
      return;
    }

    _timer?.cancel();

    // Parse mock duration text if available
    Duration trackDuration = const Duration(minutes: 4, seconds: 15);
    if (post.durationText != null) {
      final parts = post.durationText!.split(':');
      if (parts.length == 2) {
        final mins = int.tryParse(parts[0]) ?? 4;
        final secs = int.tryParse(parts[1]) ?? 15;
        trackDuration = Duration(minutes: mins, seconds: secs);
      }
    }

    state = state.copyWith(
      currentPost: post,
      isPlaying: true,
      position: Duration.zero,
      duration: trackDuration,
    );

    _startSimulatedProgress();
  }

  void play() {
    if (state.currentPost == null) return;
    state = state.copyWith(isPlaying: true);
    _startSimulatedProgress();
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isPlaying: false);
  }

  void seek(Duration newPosition) {
    state = state.copyWith(position: newPosition);
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void stop() {
    _timer?.cancel();
    state = const AudioState();
  }

  void showFullPlayer() {
    state = state.copyWith(isFullPlayerVisible: true);
  }

  void hideFullPlayer() {
    state = state.copyWith(isFullPlayerVisible: false);
  }

  void _startSimulatedProgress() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPlaying) {
        timer.cancel();
        return;
      }
      final newPos = state.position + const Duration(seconds: 1);
      if (newPos >= state.duration) {
        timer.cancel();
        state = state.copyWith(
          position: state.duration,
          isPlaying: false,
        );
      } else {
        state = state.copyWith(position: newPos);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final audioServiceProvider = StateNotifierProvider<AudioServiceNotifier, AudioState>((ref) {
  return AudioServiceNotifier();
});
