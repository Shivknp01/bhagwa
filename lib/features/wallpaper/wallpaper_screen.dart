import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/mock_content_repository.dart';
import '../../models/devotional_post.dart';
import '../post/widgets/wallpaper_cta_sheet.dart';

class DeityAvatarItem {
  final String id;
  final String name;
  final String imageUrl;

  const DeityAvatarItem({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class WallpaperScreen extends ConsumerStatefulWidget {
  const WallpaperScreen({super.key});

  @override
  ConsumerState<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends ConsumerState<WallpaperScreen> {
  String? _selectedDeityId;
  List<Map<String, String>> _dynamicWallpapers = [];

  // 1. Deity Avatars matching screenshot
  static const List<DeityAvatarItem> _deityAvatars = [
    DeityAvatarItem(
      id: 'shiva',
      name: 'Shiva Ji',
      imageUrl: 'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=400&q=80',
    ),
    DeityAvatarItem(
      id: 'hanuman',
      name: 'Hanuman Ji',
      imageUrl: 'https://images.unsplash.com/photo-1617650728468-8581e439c864?w=400&q=80',
    ),
    DeityAvatarItem(
      id: 'krishna',
      name: 'Shri Krishna',
      imageUrl: 'https://images.unsplash.com/photo-1590077428593-a55bb07c4665?w=400&q=80',
    ),
    DeityAvatarItem(
      id: 'vishnu',
      name: 'Vishnu Ji',
      imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=400&q=80',
    ),
    DeityAvatarItem(
      id: 'saraswati',
      name: 'Saraswati Mata',
      imageUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=400&q=80',
    ),
    DeityAvatarItem(
      id: 'durga',
      name: 'Durga Mata',
      imageUrl: 'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?w=400&q=80',
    ),
    DeityAvatarItem(
      id: 'ganesha',
      name: 'Ganesha Ji',
      imageUrl: 'https://images.unsplash.com/photo-1567591374603-49005959da4d?w=400&q=80',
    ),
    DeityAvatarItem(
      id: 'kuber',
      name: 'Kuber Dev',
      imageUrl: 'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=400&q=80',
    ),
  ];

  // 2. Curated High-Res Wallpapers for Live & New Sections
  static const List<Map<String, String>> _topLiveWallpapers = [
    {
      'title': 'Shri Krishna Playing Flute 🪈',
      'deity': 'krishna',
      'imageUrl': 'https://images.unsplash.com/photo-1590077428593-a55bb07c4665?w=800&q=80',
    },
    {
      'title': 'Maa Durga Crescent Moon 🌙',
      'deity': 'durga',
      'imageUrl': 'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?w=800&q=80',
    },
    {
      'title': 'Baal Krishna Divine Bliss ✨',
      'deity': 'krishna',
      'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
    },
    {
      'title': 'Mahakal Third Eye Glow 🔱',
      'deity': 'shiva',
      'imageUrl': 'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=800&q=80',
    },
    {
      'title': 'Sankat Mochan Hanuman Ji 🚩',
      'deity': 'hanuman',
      'imageUrl': 'https://images.unsplash.com/photo-1617650728468-8581e439c864?w=800&q=80',
    },
  ];

  static const List<Map<String, String>> _staticNewWallpapers = [
    {
      'title': 'Shri Kuber Dev Golden Treasury 🪙',
      'deity': 'kuber',
      'imageUrl': 'https://images.unsplash.com/photo-1567591374603-49005959da4d?w=800&q=80',
    },
    {
      'title': 'Golden Temple Lord Ganesha 🪔',
      'deity': 'ganesha',
      'imageUrl': 'https://images.unsplash.com/photo-1567591374603-49005959da4d?w=800&q=80',
    },
    {
      'title': 'Mahadev Blue Cosmic Glow 🕉️',
      'deity': 'shiva',
      'imageUrl': 'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=800&q=80',
    },
    {
      'title': 'Shri Ram Lalla Temple Aura 🚩',
      'deity': 'krishna',
      'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
    },
    {
      'title': 'Saraswati Veena Harmony 📖',
      'deity': 'saraswati',
      'imageUrl': 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=800&q=80',
    },
    {
      'title': 'Maa Lakshmi Lotus Blessing 🪷',
      'deity': 'durga',
      'imageUrl': 'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?w=800&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadWallpapers();
  }

  Future<void> _loadWallpapers() async {
    try {
      final repo = ref.read(contentRepositoryProvider);
      final feed = await repo.getFeed(category: 'Wallpaper');
      if (mounted) {
        setState(() {
          final fetched = feed
              .where((p) => p.contentType == PostContentType.wallpaper && p.imageUrl != null)
              .map((p) => {
                    'title': p.title,
                    'deity': p.deity.toLowerCase(),
                    'imageUrl': p.imageUrl!,


                  })
              .toList();

          _dynamicWallpapers = [...fetched, ..._staticNewWallpapers];
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _dynamicWallpapers = _staticNewWallpapers;
        });
      }
    }
  }


  void _openWallpaperCtaSheet(String imageUrl, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WallpaperCtaSheet(
        imageUrl: imageUrl,
        title: title,
      ),
    );
  }

  List<Map<String, String>> _getFilteredList(List<Map<String, String>> original) {
    if (_selectedDeityId == null) return original;
    return original.where((item) => item['deity'] == _selectedDeityId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredTopLive = _getFilteredList(_topLiveWallpapers);
    final filteredNew = _getFilteredList(_dynamicWallpapers.isNotEmpty ? _dynamicWallpapers : _staticNewWallpapers);


    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFF141414), // Premium dark theme matching screenshot
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar with back button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ],
                ),
              ),
            ),

            // Section 1: Title & Deity Circle Avatars Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wallpapers of all gods and\ngoddesses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Horizontal Scrolling Deity Avatars
                    SizedBox(
                      height: 104,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _deityAvatars.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),

                        itemBuilder: (context, index) {
                          final avatar = _deityAvatars[index];
                          final isSelected = _selectedDeityId == avatar.id;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_selectedDeityId == avatar.id) {
                                  _selectedDeityId = null; // Toggle off filter
                                } else {
                                  _selectedDeityId = avatar.id;
                                }
                              });
                            },
                            child: SizedBox(
                              width: 72,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primarySaffron
                                            : Colors.white.withValues(alpha: 0.15),
                                        width: isSelected ? 2.5 : 1.0,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primarySaffron.withValues(alpha: 0.4),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey.shade900,
                                      backgroundImage: NetworkImage(avatar.imageUrl),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    avatar.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primarySaffron
                                          : Colors.white.withValues(alpha: 0.9),
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Section 2: Top Live Wallpapers
            if (filteredTopLive.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top Live Wallpapers',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Horizontal 9:16 Cards List
                      SizedBox(
                        height: 250,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredTopLive.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 14),

                          itemBuilder: (context, index) {
                            final item = filteredTopLive[index];

                            return GestureDetector(
                              onTap: () => _openWallpaperCtaSheet(
                                item['imageUrl']!,
                                item['title']!,
                              ),
                              child: Container(
                                width: 145,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: NetworkImage(item['imageUrl']!),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Gradient overlay at bottom
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withValues(alpha: 0.7),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Live Badge at Top Right
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.amberGold.withValues(alpha: 0.6),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'LIVE',
                                              style: TextStyle(
                                                color: AppColors.amberGold,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            SizedBox(width: 3),
                                            Text('✨', style: TextStyle(fontSize: 9)),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Title at Bottom
                                    Positioned(
                                      bottom: 12,
                                      left: 10,
                                      right: 10,
                                      child: Text(
                                        item['title']!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],

            // Section 3: New Wallpapers Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'New wallpapers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (_selectedDeityId != null)
                          GestureDetector(
                            onTap: () => setState(() => _selectedDeityId = null),
                            child: const Text(
                              'Show All ↺',
                              style: TextStyle(
                                color: AppColors.primarySaffron,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Grid of New Wallpapers
            if (filteredNew.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Text(
                      'No wallpapers found for this deity 🙏',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62, // 9:16 portrait ratio
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredNew[index];

                      return GestureDetector(
                        onTap: () => _openWallpaperCtaSheet(
                          item['imageUrl']!,
                          item['title']!,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(item['imageUrl']!),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Bottom gradient shadow
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.75),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Action Icon Top Right
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.wallpaper_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),

                              // Bottom Title
                              Positioned(
                                bottom: 12,
                                left: 10,
                                right: 10,
                                child: Text(
                                  item['title']!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filteredNew.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
