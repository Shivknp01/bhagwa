import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/permission_service.dart';
import '../../../services/ringtone_service.dart';

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
  final AudioPlayer _player = AudioPlayer();
  bool _isPlayingPreview = false;
  bool _isSetting = false;
  double _playbackProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlayingPreview = state == PlayerState.playing);
      }
    });
    _player.onPositionChanged.listen((pos) async {
      final dur = await _player.getDuration();
      if (mounted && dur != null && dur.inMilliseconds > 0) {
        setState(() {
          _playbackProgress = pos.inMilliseconds / dur.inMilliseconds;
        });
      }
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlayingPreview = false;
          _playbackProgress = 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePreview() async {
    if (_isPlayingPreview) {
      await _player.pause();
    } else {
      if (widget.audioUrl.isEmpty) return;
      await _player.play(UrlSource(widget.audioUrl));
    }
  }

  Future<void> _setAs(RingtoneType type) async {
    // Request system write permission first
    final hasPermission =
        await PermissionService.requestSystemWriteSettingsPermission();
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '⚠️ Please enable "Modify system settings" permission in your device Settings.',
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    await _player.stop();
    setState(() => _isSetting = true);

    final service = ref.read(ringtoneServiceProvider);
    final success = await service.setRingtone(
      widget.audioUrl,
      widget.title,
      type: type,
    );

    if (mounted) {
      Navigator.pop(context);
      final label = switch (type) {
        RingtoneType.ringtone     => 'Ringtone',
        RingtoneType.notification => 'Notification Sound',
        RingtoneType.alarm        => 'Alarm Tone',
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
                      ? '🔔 Set as your $label!'
                      : 'Could not set $label. Grant "Modify system settings" permission.',
                ),
              ),
            ],
          ),
          backgroundColor:
              success ? AppColors.primarySaffron : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
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
                  color: AppColors.amberGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.amberGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set as Ringtone',
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
          const SizedBox(height: 24),

          // Audio Preview Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor, width: 0.8),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.audioUrl.isNotEmpty ? _togglePreview : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _isPlayingPreview
                          ? AppColors.primarySaffron.withValues(alpha: 0.12)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlayingPreview
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      size: 44,
                      color: widget.audioUrl.isNotEmpty
                          ? AppColors.primarySaffron
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPlayingPreview
                            ? '🎵 Playing Preview...'
                            : 'Tap ▶ to Preview Tone',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _playbackProgress,
                          backgroundColor: theme.dividerColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primarySaffron,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (_isSetting)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primarySaffron),
                ),
              ),
            )
          else ...[
            // Set as Ringtone (primary)
            _buildSetButton(
              context,
              icon: Icons.phone_in_talk_rounded,
              label: 'Set as Phone Ringtone',
              subtitle: 'Plays when someone calls you',
              type: RingtoneType.ringtone,
              isHighlighted: true,
            ),
            const SizedBox(height: 10),
            // Set as Notification
            _buildSetButton(
              context,
              icon: Icons.notifications_rounded,
              label: 'Set as Notification Sound',
              subtitle: 'Plays for messages & alerts',
              type: RingtoneType.notification,
            ),
            const SizedBox(height: 10),
            // Set as Alarm
            _buildSetButton(
              context,
              icon: Icons.alarm_rounded,
              label: 'Set as Alarm Tone',
              subtitle: 'Plays when your alarm fires',
              type: RingtoneType.alarm,
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
        ],
      ),
    );
  }

  Widget _buildSetButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required RingtoneType type,
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: () => _setAs(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: isHighlighted
            ? AppColors.primarySaffron
            : theme.colorScheme.surface,
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
