import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/coming_soon_dialog.dart';
import '../../../core/widgets/network_image_placeholder.dart';
import '../../../data/repositories/mock_content_repository.dart';
import '../../../models/devotional_post.dart';
import '../../../services/audio_service.dart';
import '../../../services/storage_service.dart';
import 'comments_sheet.dart';
import 'ringtone_cta_sheet.dart';
import 'status_share_sheet.dart';
import 'wallpaper_cta_sheet.dart';

class DevotionalPostCard extends ConsumerStatefulWidget {
  final DevotionalPost post;
  final VoidCallback? onPostUpdated;

  const DevotionalPostCard({super.key, required this.post, this.onPostUpdated});

  @override
  ConsumerState<DevotionalPostCard> createState() => _DevotionalPostCardState();
}

class _DevotionalPostCardState extends ConsumerState<DevotionalPostCard>
    with SingleTickerProviderStateMixin {
  late DevotionalPost _post;
  late AnimationController _likeAnimController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _post = widget.post;

    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_likeAnimController);
  }

  @override
  void didUpdateWidget(covariant DevotionalPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post != oldWidget.post) {
      _post = widget.post;
    }
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  Future<void> _handleLike() async {
    _likeAnimController.forward(from: 0.0);
    final repo = ref.read(contentRepositoryProvider);
    final updated = await repo.toggleLike(_post.id);
    if (mounted) {
      setState(() => _post = updated);
      if (widget.onPostUpdated != null) widget.onPostUpdated!();
    }
  }

  Future<void> _handleSave() async {
    final repo = ref.read(contentRepositoryProvider);
    final updated = await repo.toggleSave(_post.id);
    if (mounted) {
      setState(() => _post = updated);
      if (widget.onPostUpdated != null) widget.onPostUpdated!();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _post.isSaved
                ? 'Saved to collection 🔖'
                : 'Removed from collection',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _executePrimaryAction() {
    switch (_post.actionType) {
      case PostActionType.setWallpaper:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => WallpaperCtaSheet(
            imageUrl: _post.imageUrl ?? '',
            title: _post.title,
          ),
        );
        break;

      case PostActionType.playMusic:
      case PostActionType.playBhajan:
        showComingSoonDialog(
          context,
          featureName: 'Devotional Audio & Bhajan Streaming',
          iconEmoji: '🎵',
        );
        break;

      case PostActionType.setRingtone:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => RingtoneCtaSheet(
            audioUrl: _post.audioUrl ?? '',
            title: _post.title,
          ),
        );
        break;

      case PostActionType.readMantra:
      case PostActionType.readStuti:
        context.push('/reader/${_post.id}');
        break;

      case PostActionType.readHoroscope:
        context.push('/horoscope');
        break;

      case PostActionType.shareStatus:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => StatusShareSheet(
            postId: _post.id,
            title: _post.title,
            description: _post.description,
            imageUrl: _post.imageUrl,
            category: _post.contentType.name,
          ),
        );
        break;
    }
  }

  IconData _getActionIcon() {
    switch (_post.actionType) {
      case PostActionType.setWallpaper:
        return Icons.wallpaper_rounded;
      case PostActionType.playMusic:
      case PostActionType.playBhajan:
        return Icons.play_arrow_rounded;
      case PostActionType.setRingtone:
        return Icons.notifications_active_rounded;
      case PostActionType.readMantra:
        return Icons.auto_awesome_rounded;
      case PostActionType.readStuti:
        return Icons.menu_book_rounded;
      case PostActionType.readHoroscope:
        return Icons.auto_graph_rounded;
      case PostActionType.shareStatus:
        return Icons.share_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioState = ref.watch(audioServiceProvider);
    final prefs = ref.watch(userPreferencesProvider);
    final lang = prefs.appLanguage;
    final isCurrentlyPlayingThis =
        audioState.isPlaying && audioState.currentPost?.id == _post.id;

    final displayTitle = _post.localizedTitle(lang);
    final displayDescription = _post.localizedDescription(lang);
    final displayActionLabel = _post.localizedActionLabel(lang);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        gradient: theme.brightness == Brightness.dark
            ? AppColors.darkCardGradient
            : LinearGradient(
                colors: [
                  const Color(0xFFFFFDF9),
                  AppColors.primarySaffron.withValues(alpha: 0.04),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.primarySaffron.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySaffron.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Badge & Deity tag
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySaffron.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getCategoryEmoji(_post.contentType),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _post.contentType.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primarySaffron,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${_post.deity}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  _post.authorName,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),

          // Title & Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Content Media Section (Wallpaper / Audio Artwork / Mantra Preview)
          if (_post.contentType == PostContentType.mantra ||
              _post.contentType == PostContentType.stuti) ...[
            // Mantra Card Preview Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primarySaffron.withValues(alpha: 0.08),
                    AppColors.amberGold.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primarySaffron.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _post.mantraText ?? displayDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                      fontSize: 17,
                      color: AppColors.primarySaffronDark,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DevotionalImagePlaceholder(
                  imageUrl: _post.imageUrl,
                  title: displayTitle,
                  category: _post.contentType.name,
                  height: _post.contentType == PostContentType.wallpaper
                      ? 280
                      : 200,
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Primary Content CTA Action Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _executePrimaryAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrentlyPlayingThis
                      ? AppColors.deepMaroon
                      : AppColors.primarySaffron,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 1,
                ),
                icon: Icon(
                  isCurrentlyPlayingThis
                      ? Icons.pause_circle_filled_rounded
                      : _getActionIcon(),
                  size: 20,
                ),
                label: Text(
                  isCurrentlyPlayingThis
                      ? (lang == 'hi' ? 'ऑडियो रोकें' : 'Pause Audio')
                      : displayActionLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // Social Actions Row (Likes, Comments, Views, Save)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Like Button with Animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: IconButton(
                    onPressed: _handleLike,
                    icon: Icon(
                      _post.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _post.isLiked
                          ? AppColors.sacredRed
                          : theme.iconTheme.color,
                      size: 22,
                    ),
                  ),
                ),
                Text(
                  NumberFormatter.formatCount(_post.likes),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),

                // Comments Button
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => CommentsSheet(
                        postId: _post.id,
                        postTitle: _post.title,
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                ),
                Text(
                  NumberFormatter.formatCount(_post.commentsCount),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),

                // Views Indicator
                const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  NumberFormatter.formatCount(_post.views),
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),

                const Spacer(),

                // Share Button (WhatsApp quick trigger)
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => StatusShareSheet(
                        postId: _post.id,
                        title: _post.title,
                        description: _post.description,
                        imageUrl: _post.imageUrl,
                        category: _post.contentType.name,
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 20),
                ),

                // Save Bookmark Button
                IconButton(
                  onPressed: _handleSave,
                  icon: Icon(
                    _post.isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: _post.isSaved
                        ? AppColors.primarySaffron
                        : theme.iconTheme.color,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryEmoji(PostContentType type) {
    switch (type) {
      case PostContentType.wallpaper:
        return '🖼';
      case PostContentType.bhajan:
        return '🙏';
      case PostContentType.music:
        return '🎵';
      case PostContentType.ringtone:
        return '🔔';
      case PostContentType.mantra:
        return '🕉';
      case PostContentType.stuti:
        return '📖';
      case PostContentType.horoscope:
        return '🔮';
      case PostContentType.status:
        return '📱';
    }
  }
}
