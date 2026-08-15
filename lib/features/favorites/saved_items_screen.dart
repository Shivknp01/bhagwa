import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../data/repositories/mock_content_repository.dart';
import '../../models/devotional_post.dart';
import '../post/widgets/devotional_post_card.dart';

class SavedItemsScreen extends ConsumerStatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  ConsumerState<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends ConsumerState<SavedItemsScreen> {
  List<DevotionalPost> _savedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final repo = ref.read(contentRepositoryProvider);
    final list = await repo.getSavedPosts();
    if (mounted) {
      setState(() {
        _savedPosts = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Collection 🔖'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _savedPosts.isEmpty
              ? const EmptyState(
                  title: 'No Saved Content Yet',
                  message: 'Tap the bookmark icon on any Bhajan, Mantra or Wallpaper to save it for offline access.',
                  icon: Icons.bookmark_border_rounded,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedPosts.length,
                  itemBuilder: (context, index) {
                    return DevotionalPostCard(
                      post: _savedPosts[index],
                      onPostUpdated: _loadSaved,
                    );
                  },
                ),
    );
  }
}
