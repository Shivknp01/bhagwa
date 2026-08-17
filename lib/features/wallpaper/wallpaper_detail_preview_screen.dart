import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/share_helper.dart';
import '../post/widgets/wallpaper_cta_sheet.dart';

class WallpaperDetailPreviewScreen extends ConsumerStatefulWidget {
  final String imageUrl;
  final String title;
  final int initialLikes;
  final int initialShares;
  final int setTimes;

  const WallpaperDetailPreviewScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    this.initialLikes = 17,
    this.initialShares = 5,
    this.setTimes = 7,
  });

  @override
  ConsumerState<WallpaperDetailPreviewScreen> createState() =>
      _WallpaperDetailPreviewScreenState();
}

class _WallpaperDetailPreviewScreenState
    extends ConsumerState<WallpaperDetailPreviewScreen> {
  late bool _isLiked;
  late int _likesCount;
  late int _sharesCount;
  late int _setTimesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likesCount = widget.initialLikes;
    _sharesCount = widget.initialShares;
    _setTimesCount = widget.setTimes;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likesCount++;
      } else {
        _likesCount--;
      }
    });
  }

  Future<void> _shareWallpaper() async {
    setState(() {
      _sharesCount++;
    });
    await ShareHelper.shareWhatsApp(
      postId: widget.title.hashCode.toString(),
      title: widget.title,
      description: 'Check out this sacred divine HD wallpaper on Daivik Bhakti app!',
    );
  }

  void _openApplyWallpaperSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WallpaperCtaSheet(
        imageUrl: widget.imageUrl,
        title: widget.title,
      ),
    ).then((_) {
      // Increment set times count after attempting
      if (mounted) {
        setState(() {
          _setTimesCount++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Edge-to-Edge Fullscreen Wallpaper Background
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.0,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFF14100C),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColors.primarySaffron,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF14100C),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Subtle Vignette & Bottom Gradient Overlay for Readability
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.25, 0.65, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 3. Top Left Navigation Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ),

          // 4. Right Side Floating Action Buttons (Likes & Shares)
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 90,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Like Button
                GestureDetector(
                  onTap: _toggleLike,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.4),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _isLiked ? Colors.redAccent : Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_likesCount Likes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 4,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Share Button
                GestureDetector(
                  onTap: _shareWallpaper,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.4),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_sharesCount Shares',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 4,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. Bottom Overlay: "X times set" Text & "Apply wallpaper" Pill Button
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // "X times set" Text on Left
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                    child: Text(
                      '$_setTimesCount times set',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 6,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // Pill Action Button: "Apply wallpaper" (matching 2nd reference image)
                SizedBox(
                  width: 220,
                  height: 48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: ElevatedButton(
                        onPressed: _openApplyWallpaperSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.85),
                          foregroundColor: Colors.black,
                          elevation: 4,
                          shadowColor: Colors.black45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'Apply wallpaper',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C2C2E),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
