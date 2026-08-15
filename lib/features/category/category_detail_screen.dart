import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/language_toggle_button.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../data/repositories/mock_content_repository.dart';
import '../../models/devotional_post.dart';
import '../post/widgets/devotional_post_card.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String categoryName;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  List<DevotionalPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryPosts();
  }

  Future<void> _loadCategoryPosts() async {
    final repo = ref.read(contentRepositoryProvider);
    final posts = await repo.getFeed(category: widget.categoryName);

    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  String _getCategoryHeaderEmoji(String cat) {
    switch (cat.toLowerCase()) {
      case 'wallpaper':
        return '🖼';
      case 'bhajan':
        return '🙏';
      case 'music':
        return '🎵';
      case 'ringtone':
        return '🔔';
      case 'mantra':
        return '🕉';
      case 'stuti':
        return '📖';
      case 'status':
        return '📱';
      default:
        return '🚩';
    }
  }

  LinearGradient _getCategoryHeaderGradient(String cat) {
    switch (cat.toLowerCase()) {
      case 'wallpaper':
        return AppColors.wallpaperGradient;
      case 'bhajan':
        return AppColors.bhajanGradient;
      case 'music':
        return AppColors.musicGradient;
      case 'ringtone':
        return AppColors.ringtoneGradient;
      case 'mantra':
        return AppColors.mantraGradient;
      case 'stuti':
        return AppColors.stutiGradient;
      case 'status':
        return AppColors.statusGradient;
      default:
        return AppColors.allCategoryGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emoji = _getCategoryHeaderEmoji(widget.categoryName);
    final gradient = _getCategoryHeaderGradient(widget.categoryName);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName} Collection $emoji'),
        actions: const [
          LanguageToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCategoryPosts,
          color: AppColors.primarySaffron,
          child: Column(
            children: [
              // Hero Category Banner
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sacred ${widget.categoryName}s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Exclusively showing ${widget.categoryName} devotional content',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Item Count Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                child: Row(
                  children: [
                    Text(
                      'Total Available (${_posts.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Dedicated Content List
              Expanded(
                child: _isLoading
                    ? const LoadingIndicator(message: 'Loading collection...')
                    : _posts.isEmpty
                        ? EmptyState(
                            title: 'No ${widget.categoryName}s Found',
                            message: 'No items available in this category currently.',
                            icon: Icons.search_off_rounded,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              return DevotionalPostCard(
                                post: _posts[index],
                                onPostUpdated: _loadCategoryPosts,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
