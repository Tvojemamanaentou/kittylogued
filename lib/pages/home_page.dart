import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/services/book_suggestions_service.dart';
import 'package:kittylogued/services/friends_activity_service.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/pages/book_form_page.dart';
import 'package:kittylogued/utils/reading_insights.dart';
import 'package:kittylogued/widgets/reading_insights_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BookSuggestionsService _suggestionsService = BookSuggestionsService();
  final FriendsActivityService _friendsService = FriendsActivityService();
  AppServices get _s => AppScope.of(context);

  late Future<List<SuggestionSection>> _suggestions;
  late Future<List<FriendActivity>> _acquired;
  late Future<List<FriendActivity>> _updates;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _suggestions = _suggestionsService.fetchSuggestions();
    _acquired = _friendsService.fetchRecentlyAcquired();
    _updates = _friendsService.fetchReadingUpdates();
  }

  Future<void> _refresh() async {
    setState(_load);
    await Future.wait([_suggestions, _acquired, _updates]);
  }

  void _addSuggested(SuggestedBook book) {
    openBookForm(
      context,
      database: _s.database,
      repository: _s.repository,
      coverCacheService: _s.coverCache,
      initialIsbn: book.isbn,
      initialResult: BookLookupResult(
        title: book.title,
        author: book.author,
        isbn: book.isbn,
        coverUrl: book.coverUrl,
        synopsis: book.blurb,
      ),
    );
  }

  static String _ago(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }

  Future<void> _editGoal() async {
    final controller = TextEditingController(
      text: _s.settings.yearlyGoal > 0 ? '${_s.settings.yearlyGoal}' : '',
    );
    final value = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Yearly reading goal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Books to finish this year',
            helperText: 'Leave empty or 0 for no goal',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) =>
              Navigator.of(dialogContext).pop(int.tryParse(v.trim()) ?? 0),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              int.tryParse(controller.text.trim()) ?? 0,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (value != null) await _s.settings.setYearlyGoal(value);
  }

  /// Goal, streak and charts, built from the books and dated progress entries.
  Widget _buildInsights() {
    return StreamBuilder<List<Book>>(
      stream: _s.database.watchLiveBooks(),
      builder: (context, booksSnapshot) {
        return StreamBuilder<List<ReadingLog>>(
          stream: _s.database.watchAllReadingLogs(),
          builder: (context, logsSnapshot) {
            final insights = ReadingInsights.compute(
              booksSnapshot.data ?? const <Book>[],
              logsSnapshot.data ?? const <ReadingLog>[],
              DateTime.now(),
            );
            return ListenableBuilder(
              listenable: _s.settings,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your reading',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ReadingInsightsSection(
                    insights: insights,
                    goal: _s.settings.yearlyGoal,
                    onEditGoal: _editGoal,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _heading(String text, {String? note}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(text, style: Theme.of(context).textTheme.titleMedium),
          if (note != null) ...[
            const SizedBox(width: 8),
            Text(
              note,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _loading() => const Padding(
    padding: EdgeInsets.all(24),
    child: Center(child: CircularProgressIndicator()),
  );

  Widget _cover(SuggestedBook book) {
    final placeholder = Container(
      color: Colors.grey.withValues(alpha: 0.2),
      child: const Center(
        child: Icon(Icons.book, size: 36, color: Colors.grey),
      ),
    );
    final url = book.coverUrl;
    if (url == null || url.isEmpty) return placeholder;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }

  Widget _suggestionRow(SuggestionSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          section.title,
          note: section.isSample ? 'example titles' : null,
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: section.books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final book = section.books[index];
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _addSuggested(book),
                child: SizedBox(
                  width: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: double.infinity,
                            child: _cover(book),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _describe(FriendActivity a) {
    if (a.type == FriendActivityType.acquired) {
      return '${a.friendName} added "${a.bookTitle}"';
    }
    switch (a.status) {
      case 'read':
        return '${a.friendName} finished "${a.bookTitle}"';
      case 'reading':
        return '${a.friendName} started reading "${a.bookTitle}"';
      default:
        return '${a.friendName} moved "${a.bookTitle}" to their to-read list';
    }
  }

  IconData _iconFor(FriendActivity a) {
    if (a.type == FriendActivityType.acquired) {
      return Icons.library_add_outlined;
    }
    switch (a.status) {
      case 'read':
        return Icons.check_circle_outline;
      case 'reading':
        return Icons.auto_stories;
      default:
        return Icons.bookmark_border;
    }
  }

  Widget _activityList(Future<List<FriendActivity>> future) {
    return FutureBuilder<List<FriendActivity>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _loading();
        }
        final items = snapshot.data ?? const <FriendActivity>[];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Nothing yet.', style: TextStyle(color: Colors.grey)),
          );
        }
        return Card(
          child: Column(
            children: [
              for (final a in items)
                ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 18,
                    child: Text(a.friendName.characters.first),
                  ),
                  title: Text(_describe(a)),
                  subtitle: Text('${a.author} • ${_ago(a.at)}'),
                  trailing: Icon(_iconFor(a), size: 20, color: Colors.grey),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInsights(),
            const SizedBox(height: 20),
            FutureBuilder<List<SuggestionSection>>(
              future: _suggestions,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return _loading();
                }
                final sections = snapshot.data ?? const <SuggestionSection>[];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggested for you',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    for (final section in sections) _suggestionRow(section),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Friends activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            _heading('Recently acquired', note: 'example data'),
            _activityList(_acquired),
            _heading('Reading updates', note: 'example data'),
            _activityList(_updates),
          ],
        ),
      ),
    );
  }
}
