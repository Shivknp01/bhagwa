import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../data/repositories/mock_content_repository.dart';
import '../../models/devotional_post.dart';
import '../post/widgets/devotional_post_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  String _selectedCategory = 'All';
  List<DevotionalPost> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _performSearch();
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    final query = _searchController.text.trim();
    final repo = ref.read(contentRepositoryProvider);

    final list = await repo.searchPosts(
      query,
      categoryFilter: _selectedCategory,
    );

    if (mounted) {
      setState(() {
        _results = list;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _searchController,
            autofocus: widget.initialQuery == null || widget.initialQuery!.isEmpty,
            onChanged: (_) => _performSearch(),
            decoration: InputDecoration(
              hintText: 'Search Bhajans, Mantras, Wallpapers...',
              hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primarySaffron),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Pills
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.contentCategories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = AppConstants.contentCategories[index];
                  final isSelected = cat == _selectedCategory;

                  return ChoiceChip(
                    showCheckmark: false,
                    selected: isSelected,
                    selectedColor: AppColors.primarySaffron,
                    backgroundColor: theme.colorScheme.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    label: Text(cat),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                        _performSearch();
                      }
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),

            // Search Results List
            Expanded(
              child: _isLoading
                  ? const LoadingIndicator()
                  : _results.isEmpty
                      ? const EmptyState(
                          title: 'No Content Found',
                          message: 'Try searching for Mahadev, Hanuman, Krishna, or Mantra',
                          icon: Icons.search_off_rounded,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final post = _results[index];
                            return DevotionalPostCard(
                              post: post,
                              onPostUpdated: _performSearch,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
