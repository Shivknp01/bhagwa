import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../services/storage_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final Set<String> _selectedDeities = {'Mahadev', 'Hanuman', 'Krishna'};
  final Set<String> _selectedContentTypes = {
    'Bhajans',
    'Wallpapers',
    'Mantras',
  };

  void _finishOnboarding() {
    ref
        .read(userPreferencesProvider.notifier)
        .completeOnboarding(
          _selectedDeities.toList(),
          _selectedContentTypes.toList(),
        );
    final prefs = ref.read(userPreferencesProvider);
    if (prefs.isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              // Header progress indicator
              Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _step
                            ? AppColors.primarySaffron
                            : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),

              Expanded(child: _buildStepContent(theme)),

              // Bottom Navigation Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_step < 2) {
                      setState(() => _step++);
                    } else {
                      _finishOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarySaffron,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    _step == 0
                        ? 'Continue'
                        : (_step == 2 ? 'Explore Devotional Feed 🚩' : 'Next'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    switch (_step) {
      case 0:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.saffronGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySaffron.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Text('🚩', style: TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 32),
            Text(
              '🙏 Welcome to Daivik — Bhakti',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Make your day more peaceful and divine with wallpapers, music, bhajans, mantras, and daily horoscope.',
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              'What do you love?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your revered deities to personalize your feed.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 12,
                children: AppConstants.deities.map((deity) {
                  final isSelected = _selectedDeities.contains(deity);
                  final symbol = _getDeitySymbol(deity);

                  return FilterChip(
                    showCheckmark: false,
                    selected: isSelected,
                    selectedColor: AppColors.primarySaffron,
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primarySaffron
                            : theme.dividerColor,
                      ),
                    ),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(symbol, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          deity,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDeities.add(deity);
                        } else {
                          _selectedDeities.remove(deity);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              'What would you like?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select content types you want to discover daily.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 12,
                children:
                    [
                      'Bhajans',
                      'Wallpapers',
                      'Ringtones',
                      'Mantras',
                      'Status',
                      'Horoscope',
                    ].map((type) {
                      final isSelected = _selectedContentTypes.contains(type);
                      final emoji = _getContentEmoji(type);

                      return FilterChip(
                        showCheckmark: false,
                        selected: isSelected,
                        selectedColor: AppColors.primarySaffron,
                        backgroundColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primarySaffron
                                : theme.dividerColor,
                          ),
                        ),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              type,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedContentTypes.add(type);
                            } else {
                              _selectedContentTypes.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String _getDeitySymbol(String name) {
    switch (name) {
      case 'Mahadev':
        return '🔱';
      case 'Hanuman':
        return '🙏';
      case 'Krishna':
        return '🦚';
      case 'Shri Ram':
        return '🏹';
      case 'Ganesh':
        return '🐘';
      case 'Durga':
        return '🌺';
      case 'Lakshmi':
        return '✨';
      default:
        return '🌸';
    }
  }

  String _getContentEmoji(String type) {
    switch (type) {
      case 'Bhajans':
        return '🎵';
      case 'Wallpapers':
        return '🖼';
      case 'Ringtones':
        return '🔔';
      case 'Mantras':
        return '🕉';
      case 'Status':
        return '📱';
      case 'Horoscope':
        return '🔮';
      default:
        return '✨';
    }
  }
}
