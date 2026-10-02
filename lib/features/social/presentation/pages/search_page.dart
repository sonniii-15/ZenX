import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/zenx_colors.dart';
import '../providers/social_providers.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  List<dynamic> _searchResults = []; // Holds UserSearchResult
  bool _isLoading = false;

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final repo = ref.read(userSearchRepositoryProvider);
      final results = await repo.searchUsers(query.trim());
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e'), backgroundColor: ZenXColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: ZenXColors.textSecondary),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
          autofocus: true,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: ZenXColors.primary))
        : _searchResults.isEmpty && _searchController.text.isNotEmpty
          ? const Center(child: Text('No users found.', style: TextStyle(color: ZenXColors.textSecondary)))
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: ZenXColors.surfaceHighlight,
                    child: Icon(Icons.person, color: ZenXColors.textSecondary),
                  ),
                  title: Text(result.profile.username, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text('${result.profile.totalPoints} pts • Level ${result.profile.currentLevel}', style: const TextStyle(color: ZenXColors.primary)),
                  onTap: () {
                    context.push('/public-profile/${result.userId}');
                  },
                );
              },
            ),
    );
  }
}
