import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/language_toggle_button.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final prefs = ref.read(userPreferencesProvider);
    final notifier = ref.read(userPreferencesProvider.notifier);
    final nameController = TextEditingController(text: prefs.userName);
    final authService = AuthService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('🚩 ', style: TextStyle(fontSize: 20)),
              Text('Edit Devotional Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Devotee Display Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Shiv_Bhakta_108 or Aditya Sharma',
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primarySaffron),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  final assignedId = await authService.syncProfileToSupabase(
                    displayName: newName,
                    phone: prefs.userPhone,
                    email: prefs.userEmail,
                  );
                  await notifier.login(
                    name: newName,
                    phone: prefs.userPhone,
                    email: prefs.userEmail,
                    bhagwaUserId: assignedId,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Devotee profile name updated to "$newName" 🚩'),
                        backgroundColor: AppColors.primarySaffron,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySaffron,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final notifier = ref.read(userPreferencesProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Devotional Profile 🚩',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          LanguageToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // User Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primarySaffron.withValues(alpha: 0.15),
                    AppColors.amberGold.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primarySaffron.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=68'),
                    backgroundColor: AppColors.primarySaffron,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prefs.userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primarySaffron.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primarySaffron.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'Bhagwa ID: #${prefs.bhagwaUserId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primarySaffronDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          prefs.userPhone.isNotEmpty ? prefs.userPhone : 'Guest Devotee 🔱',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showEditProfileDialog(context, ref),
                    icon: const Icon(Icons.edit_rounded, color: AppColors.primarySaffron),
                    tooltip: 'Edit Profile Name',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Collections Grid
            Text(
              'My Library',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildLibraryCard(
                  context,
                  title: 'Saved Items',
                  icon: Icons.bookmark_rounded,
                  color: AppColors.primarySaffron,
                  onTap: () => context.push('/saved'),
                ),
                _buildLibraryCard(
                  context,
                  title: 'Liked Posts',
                  icon: Icons.favorite_rounded,
                  color: AppColors.sacredRed,
                  onTap: () => context.push('/saved'),
                ),
                _buildLibraryCard(
                  context,
                  title: 'Recently Played',
                  icon: Icons.history_rounded,
                  color: AppColors.amberGold,
                  onTap: () => context.push('/player'),
                ),
                _buildLibraryCard(
                  context,
                  title: 'Downloaded',
                  icon: Icons.download_done_rounded,
                  color: AppColors.peacockBlue,
                  onTap: () => context.push('/saved'),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // App Settings Section
            Text(
              'Account & App Settings',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildSettingTile(
              context,
              icon: Icons.badge_rounded,
              title: 'Bhagwa Devotee User ID (#${prefs.bhagwaUserId})',
              subtitle: 'Unique numeric user identity assigned server-side',
              onTap: () {},
            ),
            const SizedBox(height: 10),

            _buildSettingTile(
              context,
              icon: Icons.edit_note_rounded,
              title: 'Edit Devotee Name (${prefs.userName})',
              onTap: () => _showEditProfileDialog(context, ref),
            ),
            const SizedBox(height: 10),

            // Dark Mode Switch Tile
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor, width: 0.8),
              ),
              child: SwitchListTile(
                secondary: Icon(
                  prefs.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.primarySaffron,
                ),
                title: const Text('Dark Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                value: prefs.isDarkMode,
                activeTrackColor: AppColors.primarySaffron,
                onChanged: (_) => notifier.toggleDarkMode(),
              ),
            ),
            const SizedBox(height: 10),

            _buildSettingTile(
              context,
              icon: Icons.notifications_active_rounded,
              title: 'Notification Preferences',
              onTap: () => context.push('/notifications'),
            ),
            const SizedBox(height: 10),

            _buildSettingTile(
              context,
              icon: Icons.language_rounded,
              title: 'App Language (हिंदी / English)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Language set to Hindi & English (Default)'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            _buildSettingTile(
              context,
              icon: Icons.privacy_tip_rounded,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            const SizedBox(height: 10),

            _buildSettingTile(
              context,
              icon: Icons.info_rounded,
              title: 'About Bhakti Sanga App (v1.0.0)',
              onTap: () {},
            ),
            const SizedBox(height: 24),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout Session?'),
                    content: const Text('Are you sure you want to log out of Bhakti Sanga?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.sacredRed),
                        child: const Text('Logout', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await notifier.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: AppColors.sacredRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.sacredRed, width: 1.2),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text(
                'Logout (लॉगआउट)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 0.8),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primarySaffron),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
