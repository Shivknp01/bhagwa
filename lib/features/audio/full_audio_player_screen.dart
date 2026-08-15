import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/number_formatter.dart';
import '../../core/utils/share_helper.dart';
import '../../core/widgets/network_image_placeholder.dart';
import '../../data/repositories/mock_content_repository.dart';
import '../../services/audio_service.dart';

class FullAudioPlayerScreen extends ConsumerWidget {
  const FullAudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioServiceProvider);
    final post = audioState.currentPost;
    final theme = Theme.of(context);

    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Audio Player')),
        body: const Center(child: Text('No audio selected')),
      );
    }

    final repo = ref.read(contentRepositoryProvider);
    final positionSec = audioState.position.inSeconds.toDouble();
    final durationSec = audioState.duration.inSeconds.toDouble().clamp(1.0, 9999.0);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? AppColors.darkBackground
          : const Color(0xFF1E1B18), // Rich dark backdrop for music focus
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'NOW PLAYING',
          style: TextStyle(
            color: AppColors.primarySaffron,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: post.isSaved ? AppColors.primarySaffron : Colors.white,
            ),
            onPressed: () async {
              await repo.toggleSave(post.id);
              ref.read(audioServiceProvider.notifier).playPost(post.copyWith(isSaved: !post.isSaved));
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {
              ShareHelper.sharePost(
                postId: post.id,
                title: post.title,
                description: post.description,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Large Devotional Artwork Disk / Card
              Center(
                child: Hero(
                  tag: 'audio_art_${post.id}',
                  child: Container(
                    height: 280,
                    width: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primarySaffron.withValues(alpha: 0.35),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: DevotionalImagePlaceholder(
                      imageUrl: post.imageUrl,
                      title: post.title,
                      category: post.contentType.name,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),

              // Title and Subtitle Info
              Column(
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🙏 ${post.deity} • ${post.authorName}',
                      style: const TextStyle(
                        color: AppColors.primarySaffronLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Seek Bar & Time Indicators
              Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primarySaffron,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                      thumbColor: Colors.white,
                      overlayColor: AppColors.primarySaffron.withValues(alpha: 0.2),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: positionSec.clamp(0.0, durationSec),
                      min: 0.0,
                      max: durationSec,
                      onChanged: (val) {
                        ref.read(audioServiceProvider.notifier).seek(Duration(seconds: val.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          NumberFormatter.formatDuration(audioState.position),
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                        ),
                        Text(
                          NumberFormatter.formatDuration(audioState.duration),
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Playback Controls (Prev, Play/Pause, Next)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                    onPressed: () {
                      ref.read(audioServiceProvider.notifier).seek(Duration.zero);
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(audioServiceProvider.notifier).togglePlayPause();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.saffronGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primarySaffron,
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        audioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                    onPressed: () {
                      ref.read(audioServiceProvider.notifier).seek(audioState.duration);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
