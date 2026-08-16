import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/coming_soon_dialog.dart';

class RingtoneCtaSheet extends ConsumerStatefulWidget {
  final String audioUrl;
  final String title;

  const RingtoneCtaSheet({
    super.key,
    required this.audioUrl,
    required this.title,
  });

  @override
  ConsumerState<RingtoneCtaSheet> createState() => _RingtoneCtaSheetState();
}

class _RingtoneCtaSheetState extends ConsumerState<RingtoneCtaSheet> {
  final bool _isPlayingPreview = false;
  final bool _isSetting = false;

  Future<void> _setRingtone() async {
    Navigator.pop(context);
    showComingSoonDialog(context, featureName: 'Devotional Ringtone', iconEmoji: '🔔');
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
                  color: AppColors.amberGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: AppColors.amberGold, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set Phone Ringtone',
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

          // Ringtone Preview Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor, width: 0.8),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    showComingSoonDialog(context, featureName: 'Audio Preview', iconEmoji: '🎵');
                  },
                  icon: Icon(
                    _isPlayingPreview ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    size: 40,
                    color: AppColors.primarySaffron,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPlayingPreview ? 'Playing Preview...' : 'Tap to Preview Tone',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _isPlayingPreview ? 0.6 : 0.0,
                          backgroundColor: theme.dividerColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primarySaffron),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          if (_isSetting)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primarySaffron),
                ),
              ),
            )
          else ...[
            ElevatedButton.icon(
              onPressed: _setRingtone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySaffron,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.notifications_active_rounded, size: 20),
              label: const Text(
                'Set as Ringtone',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
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
}
