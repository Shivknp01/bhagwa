import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/language_toggle_button.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../data/repositories/mock_content_repository.dart';
import '../../models/horoscope.dart';
import '../../services/storage_service.dart';

class HoroscopeScreen extends ConsumerStatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  ConsumerState<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends ConsumerState<HoroscopeScreen> {
  String _selectedSign = 'Aries';
  List<Horoscope> _horoscopes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHoroscopes();
  }

  Future<void> _loadHoroscopes() async {
    final repo = ref.read(contentRepositoryProvider);
    final list = await repo.getHoroscopes();
    if (mounted) {
      setState(() {
        _horoscopes = list;
        _isLoading = false;
      });
    }
  }

  Horoscope? get _currentHoroscope {
    if (_horoscopes.isEmpty) return null;
    final match = _horoscopes.where((h) => h.sign.toLowerCase() == _selectedSign.toLowerCase()).toList();
    return match.isNotEmpty ? match.first : _horoscopes.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(userPreferencesProvider);
    final lang = prefs.appLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'hi' ? 'आज का राशिफल एवं पंचांग 🔮' : 'Today\'s Rashifal & Panchang 🔮'),
        actions: const [
          LanguageToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Calculating planetary movements...')
          : SafeArea(
              child: Column(
                children: [
                  // Horizontal Zodiac Selector Wheels
                  Container(
                    height: 90,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _horoscopes.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = _horoscopes[index];
                        final isSelected = item.sign.toLowerCase() == _selectedSign.toLowerCase();

                        return ChoiceChip(
                          showCheckmark: false,
                          selected: isSelected,
                          selectedColor: AppColors.primarySaffron,
                          backgroundColor: theme.colorScheme.surface,
                          side: BorderSide(
                            color: isSelected ? AppColors.primarySaffron : theme.dividerColor,
                          ),
                          label: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.symbol,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.localizedSign(lang),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedSign = item.sign);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // Selected Horoscope Detailed Display
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: _currentHoroscope == null
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Hero Header Box
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF311B92), Color(0xFF7C4DFF)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withValues(alpha: 0.2),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        _currentHoroscope!.symbol,
                                        style: const TextStyle(fontSize: 52),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _currentHoroscope!.localizedSign(lang),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        lang == 'hi'
                                            ? 'व्यक्तिगत फलादेश • ${_currentHoroscope!.date}'
                                            : 'Personalized Guidance • ${_currentHoroscope!.date}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Overview Text
                                Text(
                                  lang == 'hi' ? 'दैनिक राशिफल (Overview)' : 'Daily Overview',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: theme.dividerColor, width: 0.8),
                                  ),
                                  child: Text(
                                    _currentHoroscope!.localizedOverview(lang),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Lucky Parameters Grid (Lucky Number, Lucky Color, Lucky Time)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildParameterCard(
                                        context,
                                        title: lang == 'hi' ? 'शुभ अंक' : 'Lucky Number',
                                        value: _currentHoroscope!.luckyNumber,
                                        icon: Icons.filter_7_rounded,
                                        accentColor: Colors.amber,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildParameterCard(
                                        context,
                                        title: lang == 'hi' ? 'शुभ रंग' : 'Lucky Color',
                                        value: _currentHoroscope!.luckyColor,
                                        icon: Icons.palette_rounded,
                                        accentColor: AppColors.primarySaffron,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildParameterCard(
                                  context,
                                  title: lang == 'hi' ? 'शुभ मुहूर्त' : 'Auspicious Muhurat',
                                  value: _currentHoroscope!.luckyTime,
                                  icon: Icons.access_time_filled_rounded,
                                  accentColor: Colors.teal,
                                ),
                                const SizedBox(height: 20),

                                // Spiritual Remedy & Advice
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySaffron.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.primarySaffron.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.auto_awesome_rounded, color: AppColors.primarySaffron, size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lang == 'hi' ? 'दैनिक उपाय (Remedy)' : 'Daily Remedy (उपाय)',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColors.primarySaffronDark,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _currentHoroscope!.localizedAdvice(lang),
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: theme.colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildParameterCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
