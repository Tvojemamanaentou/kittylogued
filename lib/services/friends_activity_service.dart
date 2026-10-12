enum FriendActivityType { acquired, statusChanged }

class FriendActivity {
  final String friendName;
  final String bookTitle;
  final String author;
  final FriendActivityType type;

  /// For [FriendActivityType.statusChanged]: 'reading', 'read' or 'unread'.
  final String? status;
  final DateTime at;

  const FriendActivity({
    required this.friendName,
    required this.bookTitle,
    required this.author,
    required this.type,
    this.status,
    required this.at,
  });
}

/// What friends have been doing. STUB with example data until the server
/// exists. Keep the two methods; only their bodies need to change.
class FriendsActivityService {
  /// Books friends recently added to their library.
  Future<List<FriendActivity>> fetchRecentlyAcquired() async {
    final now = DateTime.now();
    return [
      FriendActivity(
        friendName: 'Anna',
        bookTitle: 'Sapiens',
        author: 'Yuval Noah Harari',
        type: FriendActivityType.acquired,
        at: now.subtract(const Duration(hours: 3)),
      ),
      FriendActivity(
        friendName: 'Tomáš',
        bookTitle: 'Dune',
        author: 'Frank Herbert',
        type: FriendActivityType.acquired,
        at: now.subtract(const Duration(days: 1)),
      ),
      FriendActivity(
        friendName: 'Eva',
        bookTitle: 'Sto roků samoty',
        author: 'Gabriel García Márquez',
        type: FriendActivityType.acquired,
        at: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  /// Friends starting or finishing books.
  Future<List<FriendActivity>> fetchReadingUpdates() async {
    final now = DateTime.now();
    return [
      FriendActivity(
        friendName: 'Eva',
        bookTitle: 'Anna Karenina',
        author: 'Lev N. Tolstoj',
        type: FriendActivityType.statusChanged,
        status: 'reading',
        at: now.subtract(const Duration(hours: 6)),
      ),
      FriendActivity(
        friendName: 'Anna',
        bookTitle: 'Zločin a trest',
        author: 'Fjodor M. Dostojevskij',
        type: FriendActivityType.statusChanged,
        status: 'read',
        at: now.subtract(const Duration(days: 2)),
      ),
      FriendActivity(
        friendName: 'Tomáš',
        bookTitle: 'Neuromancer',
        author: 'William Gibson',
        type: FriendActivityType.statusChanged,
        status: 'reading',
        at: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}
