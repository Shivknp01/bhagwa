import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/language_toggle_button.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../data/repositories/mock_content_repository.dart';
import '../../models/devotional_post.dart';
import '../post/widgets/devotional_post_card.dart';
import '../../services/marketing_event_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final String _selectedCategory = 'All';
  List<DevotionalPost> _posts = [];
  bool _isLoading = true;

  static const List<Map<String, dynamic>> _categoryTiles = [
    {
      'name': 'All',
      'emoji': '🚩',
      'sub': 'पावन संगम',
      'gradient': AppColors.allCategoryGradient,
    },
    {
      'name': 'Wallpaper',
      'emoji': '🖼',
      'sub': 'HD वॉलपेपर',
      'gradient': AppColors.wallpaperGradient,
    },
    {
      'name': 'Bhajan',
      'emoji': '🙏',
      'sub': 'मधुर भजन',
      'gradient': AppColors.bhajanGradient,
    },
    {
      'name': 'Music',
      'emoji': '🎵',
      'sub': 'भक्ति संगीत',
      'gradient': AppColors.musicGradient,
    },
    {
      'name': 'Ringtone',
      'emoji': '🔔',
      'sub': 'फोन रिंगटोन',
      'gradient': AppColors.ringtoneGradient,
    },
    {
      'name': 'Mantra',
      'emoji': '🕉',
      'sub': 'वेदिक मंत्र',
      'gradient': AppColors.mantraGradient,
    },
    {
      'name': 'Stuti',
      'emoji': '📖',
      'sub': 'पवित्र स्तुति',
      'gradient': AppColors.stutiGradient,
    },
    {
      'name': 'Horoscope',
      'emoji': '🔮',
      'sub': 'आज का राशिफल',
      'gradient': AppColors.horoscopeGradient,
    },
    {
      'name': 'Status',
      'emoji': '📱',
      'sub': 'स्टेटस शेयर',
      'gradient': AppColors.statusGradient,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    final repo = ref.read(contentRepositoryProvider);
    final posts = await repo.getFeed(category: _selectedCategory);

    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  void _onCategoryTileTap(String name) {
    MarketingEventService.trackProductEvent('category_click', parameters: {'category_name': name});
    if (name.toLowerCase() == 'all') {
      _loadFeed();
    } else if (name.toLowerCase() == 'horoscope') {
      context.push('/horoscope');
    } else {
      context.push('/category/$name');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.primarySaffron.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySaffron.withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/daivik_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Daivik — Bhakti',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        actions: [
          const LanguageToggleButton(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFeed,
          color: AppColors.primarySaffron,
          child: CustomScrollView(
            slivers: [
              // Sacred Devotional Header Banner
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD84315),
                        Color(0xFFFF6D00),
                        Color(0xFFFFB300),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primarySaffron.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '🚩 जय श्री राम • हर हर महादेव 🔱',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'आज का पावन भक्ति संगम एवं दर्शन',
                              style: TextStyle(
                                color: Color(0xFFFFF3E0),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🪔', style: TextStyle(fontSize: 22)),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Search Pill
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primarySaffron.withValues(
                            alpha: 0.4,
                          ),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: AppColors.primarySaffron,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search Bhajans, Mantras, Wallpapers...',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primarySaffron.withValues(
                                alpha: 0.12,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mic_rounded,
                              size: 16,
                              color: AppColors.primarySaffron,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Sacred Bhakti Category Grid Tiles (Click to navigate to dedicated page)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Row(
                            children: [
                              Text('🔱', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text(
                                'पावन श्रेणी (Tap to Open Page)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 3x3 Bhakti Gradient Tile Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.6,
                            ),
                        itemCount: _categoryTiles.length,
                        itemBuilder: (context, index) {
                          final item = _categoryTiles[index];
                          final name = item['name'] as String;
                          final emoji = item['emoji'] as String;
                          final sub = item['sub'] as String;
                          final gradient = item['gradient'] as LinearGradient;

                          return GestureDetector(
                            onTap: () => _onCategoryTileTap(name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: isDark
                                    ? LinearGradient(
                                        colors: [
                                          gradient.colors.first.withValues(
                                            alpha: 0.35,
                                          ),
                                          gradient.colors.last.withValues(
                                            alpha: 0.2,
                                          ),
                                        ],
                                      )
                                    : gradient,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.primarySaffron.withValues(
                                          alpha: 0.4,
                                        )
                                      : Colors.white.withValues(alpha: 0.6),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          emoji,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black38,
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      sub,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // Feed Posts Title Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      const Text('🪷', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        'आज का भक्ति प्रवाह (Daily Feed)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySaffron.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_posts.length} posts',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primarySaffron,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Feed Posts List / Loading / Empty
              if (_isLoading)
                const SliverFillRemaining(
                  child: LoadingIndicator(
                    message: 'Loading sacred devotional feed...',
                  ),
                )
              else if (_posts.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    title: 'No Devotional Posts',
                    message: 'No items available currently.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = _posts[index];
                      return DevotionalPostCard(
                        post: post,
                        onPostUpdated: _loadFeed,
                      );
                    }, childCount: _posts.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
