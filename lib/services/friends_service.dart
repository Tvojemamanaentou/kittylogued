/// A friend of the user.
class Friend {
  final int? userId;
  final String username;
  final String? displayName;

  /// True for the built-in example friends (until real friends exist).
  final bool isExample;

  const Friend({
    this.userId,
    required this.username,
    this.displayName,
    this.isExample = false,
  });
}

/// The user's friends list. STUB: returns example friends so the lending
/// screens can be tried out.
///
/// TODO: load the real friends from the server and add friend requests.
class FriendsService {
  Future<List<Friend>> loadFriends() async {
    return const [
      Friend(username: 'Anna', isExample: true),
      Friend(username: 'Tomáš', isExample: true),
      Friend(username: 'Eva', isExample: true),
    ];
  }
}
