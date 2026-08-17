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
  bool _showPreview = false;
  WallpaperTarget? _selectedTarget;

  /// Step 1 – user taps a target button → show fullscreen preview
  void _selectTarget(WallpaperTarget target) {
    setState(() {
      _selectedTarget = target;
      _showPreview = true;
    });
  }

  /// Step 2 – user confirms from preview → actually set the wallpaper
  Future<void> _confirmAndSet() async {
    if (_selectedTarget == null) return;
    setState(() => _isSetting = true);

    final service = ref.read(wallpaperServiceProvider);
    final success = await service.setWallpaper(widget.imageUrl, _selectedTarget!);

    if (mounted) {
      Navigator.pop(context);
      final label = switch (_selectedTarget!) {
        WallpaperTarget.homeScreen => 'Home Screen',
        WallpaperTarget.lockScreen => 'Lock Screen',
        WallpaperTarget.both       => 'Home & Lock Screen',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  success
                      ? '✨ Wallpaper set as $label!'
                      : 'Could not set wallpaper. Please try again.',
                ),
              ),
            ],
          ),
          backgroundColor:
              success ? AppColors.primarySaffron : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _showPreview ? _buildPreviewStep(theme) : _buildTargetStep(theme),
    );
  }

  // ─── Step 1: Target Selection with preview thumbnail ─────────────────────
  Widget _buildTargetStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
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

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySaffron.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wallpaper_rounded,
                  color: AppColors.primarySaffron,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set as Wallpaper',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
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
          const SizedBox(height: 20),

          // Image preview thumbnail
          if (widget.imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 200,
                    color: theme.colorScheme.surface,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primarySaffron,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, e, s) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primarySaffron.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      size: 48,
                      color: AppColors.primarySaffron,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a button below to preview then set',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],

          // Target buttons
          _buildOptionButton(
            context,
            icon: Icons.home_rounded,
            label: 'Home Screen',
            subtitle: 'Set as your home screen background',
            onTap: () => _selectTarget(WallpaperTarget.homeScreen),
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            context,
            icon: Icons.lock_rounded,
            label: 'Lock Screen',
            subtitle: 'Set as your lock screen background',
            onTap: () => _selectTarget(WallpaperTarget.lockScreen),
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            context,
            icon: Icons.phonelink_setup_rounded,
            label: 'Both Screens',
            subtitle: 'Apply to Home & Lock screen together',
            onTap: () => _selectTarget(WallpaperTarget.both),
            isHighlighted: true,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 2: Full Preview + Confirm ──────────────────────────────────────
  Widget _buildPreviewStep(ThemeData theme) {
    final label = switch (_selectedTarget!) {
      WallpaperTarget.homeScreen => 'Home Screen',
      WallpaperTarget.lockScreen => 'Lock Screen',
      WallpaperTarget.both       => 'Home & Lock Screen',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Preview label
        Text(
          'Preview · $label',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Full-width image preview with phone frame overlay
        Stack(
          alignment: Alignment.center,
          children: [
            // Wallpaper image
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySaffron.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 320,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: theme.colorScheme.surface,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primarySaffron,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Lock screen overlay for lock/both targets
            if (_selectedTarget == WallpaperTarget.lockScreen ||
                _selectedTarget == WallpaperTarget.both)
              Positioned(
                top: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Lock Screen Preview',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isSetting
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primarySaffron,
                      ),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _confirmAndSet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primarySaffron,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: Text(
                        'Set as $label',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => setState(() => _showPreview = false),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Change Target'),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isHighlighted ? AppColors.primarySaffron : theme.colorScheme.surface,
        foregroundColor:
            isHighlighted ? Colors.white : theme.colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isHighlighted
              ? BorderSide.none
              : BorderSide(color: theme.dividerColor, width: 0.8),
        ),
        elevation: isHighlighted ? 2 : 0,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: isHighlighted
                        ? Colors.white.withValues(alpha: 0.75)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: isHighlighted
                ? Colors.white.withValues(alpha: 0.7)
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
