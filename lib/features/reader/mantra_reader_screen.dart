import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/share_helper.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/language_toggle_button.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../data/repositories/mock_content_repository.dart';
import '../../models/devotional_post.dart';
import '../../services/audio_service.dart';
import '../../services/storage_service.dart';

class MantraReaderScreen extends ConsumerStatefulWidget {
  final String postId;

  const MantraReaderScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<MantraReaderScreen> createState() => _MantraReaderScreenState();
}

class _MantraReaderScreenState extends ConsumerState<MantraReaderScreen> {
  DevotionalPost? _post;
  bool _isLoading = true;
  double _fontSize = 20.0;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    final repo = ref.read(contentRepositoryProvider);
    final post = await repo.getPostById(widget.postId);
    if (mounted) {
      setState(() {
        _post = post;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioState = ref.watch(audioServiceProvider);
    final prefs = ref.watch(userPreferencesProvider);
    final lang = prefs.appLanguage;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const LoadingIndicator(message: 'Loading sacred verses...'),
      );
    }

    if (_post == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          errorMessage: 'Verse not found',
          onRetry: _loadPost,
        ),
      );
    }

    final post = _post!;
    final isPlaying = audioState.isPlaying && audioState.currentPost?.id == post.id;
    final displayTitle = post.localizedTitle(lang);
    final displayMeaning = post.localizedMantraMeaning(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(post.contentType.name == 'stuti' ? 'Sacred Stuti' : 'Sacred Mantra'),
        actions: [
          const LanguageToggleButton(),
          IconButton(
            icon: Icon(
              post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: post.isSaved ? AppColors.primarySaffron : null,
            ),
            onPressed: () async {
              final repo = ref.read(contentRepositoryProvider);
              final updated = await repo.toggleSave(post.id);
              setState(() => _post = updated);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              ShareHelper.sharePost(
                postId: post.id,
                title: displayTitle,
                description: post.mantraText ?? post.description,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Font Size adjustment bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  const Text('Font Size:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 12),
                  const Text('A-', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 16.0,
                      max: 28.0,
                      activeColor: AppColors.primarySaffron,
                      onChanged: (val) {
                        setState(() => _fontSize = val);
                      },
                    ),
                  ),
                  const Text('A+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(height: 1),

            // Reading Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primarySaffron.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🙏 ${post.deity} • $displayTitle',
                          style: const TextStyle(
                            color: AppColors.primarySaffron,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Mantra Text Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primarySaffron.withValues(alpha: 0.08),
                            AppColors.amberGold.withValues(alpha: 0.04),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primarySaffron.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        post.mantraText ?? post.localizedDescription(lang),
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.bold,
                          height: 1.8,
                          color: theme.brightness == Brightness.dark
                              ? AppColors.amberGold
                              : AppColors.primarySaffronDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    if (displayMeaning != null) ...[
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.primarySaffron, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            lang == 'hi' ? 'मंत्र अर्थ एवं महत्त्व' : 'Meaning & Significance',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.dividerColor, width: 0.8),
                        ),
                        child: Text(
                          displayMeaning,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            fontSize: _fontSize - 3,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom Audio Trigger Bar if Audio available
            if (post.audioUrl != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(audioServiceProvider.notifier).playPost(post);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPlaying ? AppColors.deepMaroon : AppColors.primarySaffron,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: Icon(isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded),
                    label: Text(
                      isPlaying
                          ? (lang == 'hi' ? 'पाठ ऑडियो रोकें' : 'Pause Recitation Audio')
                          : (lang == 'hi' ? 'पाठ ऑडियो सुनें' : 'Listen to Recitation Audio'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
