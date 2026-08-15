import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../services/storage_service.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final notifier = ref.read(userPreferencesProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences 🔔'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Customize Your Devotional Reminders',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Receive morning shlokas, evening aarti audio alerts, and festival reminders.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            _buildSwitchTile(
              context,
              title: '🌅 Good Morning Bhakti',
              subtitle: 'Daily 06:00 AM Morning Shlokas & Wallpapers',
              value: prefs.morningBhaktiNotif,
              onChanged: (_) => notifier.toggleMorningNotif(),
            ),
            const SizedBox(height: 12),

            _buildSwitchTile(
              context,
              title: '🪔 Evening Aarti & Bhajans',
              subtitle: 'Daily 06:30 PM Aarti alert & playlist',
              value: prefs.eveningAartiNotif,
              onChanged: (_) => notifier.toggleEveningNotif(),
            ),
            const SizedBox(height: 12),

            _buildSwitchTile(
              context,
              title: '🌙 Good Night Peace',
              subtitle: 'Daily 09:30 PM Peaceful Mantras for sleep',
              value: prefs.goodNightNotif,
              onChanged: (_) => notifier.toggleGoodNightNotif(),
            ),
            const SizedBox(height: 12),

            _buildSwitchTile(
              context,
              title: '🎉 Sacred Festivals',
              subtitle: 'Special Mahashivratri, Janmashtami & Diwali alerts',
              value: prefs.festivalNotif,
              onChanged: (_) => notifier.toggleFestivalNotif(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor, width: 0.8),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        value: value,
        activeTrackColor: AppColors.primarySaffron,
        onChanged: onChanged,
      ),
    );
  }
}
