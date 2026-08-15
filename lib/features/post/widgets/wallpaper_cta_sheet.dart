import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/wallpaper_service.dart';

class WallpaperCtaSheet extends ConsumerStatefulWidget {
  final String imageUrl;
  final String title;

  const WallpaperCtaSheet({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  ConsumerState<WallpaperCtaSheet> createState() => _WallpaperCtaSheetState();
}

class _WallpaperCtaSheetState extends ConsumerState<WallpaperCtaSheet> {
  bool _isSetting = false;

  Future<void> _applyWallpaper(WallpaperTarget target) async {
    setState(() => _isSetting = true);
    final service = ref.read(wallpaperServiceProvider);
    final success = await service.setWallpaper(widget.imageUrl, target);

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Wallpaper set successfully! 🖼'),
              ],
            ),
            backgroundColor: AppColors.primarySaffron,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySaffron.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wallpaper_rounded, color: AppColors.primarySaffron, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set Wallpaper',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.title,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isSetting)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primarySaffron),
                ),
              ),
            )
          else ...[
            _buildOptionButton(
              context,
              icon: Icons.home_rounded,
              label: 'Home Screen',
              onTap: () => _applyWallpaper(WallpaperTarget.homeScreen),
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              context,
              icon: Icons.lock_rounded,
              label: 'Lock Screen',
              onTap: () => _applyWallpaper(WallpaperTarget.lockScreen),
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              context,
              icon: Icons.phonelink_setup_rounded,
              label: 'Both (Home & Lock Screen)',
              onTap: () => _applyWallpaper(WallpaperTarget.both),
              isHighlighted: true,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isHighlighted
            ? AppColors.primarySaffron
            : theme.colorScheme.surface,
        foregroundColor: isHighlighted
            ? Colors.white
            : theme.colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isHighlighted
              ? BorderSide.none
              : BorderSide(color: theme.dividerColor, width: 0.8),
        ),
        elevation: isHighlighted ? 2 : 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
