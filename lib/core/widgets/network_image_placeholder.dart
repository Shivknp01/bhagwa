import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DevotionalImagePlaceholder extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String category;
  final double? height;
  final double width;
  final BorderRadius? borderRadius;

  const DevotionalImagePlaceholder({
    super.key,
    this.imageUrl,
    required this.title,
    required this.category,
    this.height,
    this.width = double.infinity,
    this.borderRadius,
  });

  LinearGradient _getCategoryGradient() {
    switch (category.toLowerCase()) {
      case 'wallpaper':
        return const LinearGradient(
          colors: [Color(0xFF880E4F), Color(0xFFFF6D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'bhajan':
      case 'music':
        return const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF00B0FF)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        );
      case 'ringtone':
        return const LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFFFF4081)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'mantra':
      case 'stuti':
        return const LinearGradient(
          colors: [Color(0xFFE65100), Color(0xFFFFB300)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'horoscope':
        return const LinearGradient(
          colors: [Color(0xFF311B92), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'status':
      default:
        return const LinearGradient(
          colors: [Color(0xFFFF3D00), Color(0xFFFFB300)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'wallpaper':
        return Icons.image_rounded;
      case 'bhajan':
      case 'music':
        return Icons.music_note_rounded;
      case 'ringtone':
        return Icons.notifications_active_rounded;
      case 'mantra':
        return Icons.auto_awesome_rounded;
      case 'stuti':
        return Icons.menu_book_rounded;
      case 'horoscope':
        return Icons.auto_graph_rounded;
      case 'status':
      default:
        return Icons.share_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);

    // If imageUrl is provided and starts with http, attempt Image.network with fallback
    if (imageUrl != null && (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'))) {
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: Image.network(
          imageUrl!,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackCard(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildFallbackCard(isLoading: true);
          },
        ),
      );
    }

    return _buildFallbackCard();
  }

  Widget _buildFallbackCard({bool isLoading = false}) {
    return Container(
      height: height ?? 220,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        gradient: _getCategoryGradient(),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySaffron.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle background decorative circle pattern
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    const SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.5,
                      ),
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(),
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
