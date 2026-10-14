import 'package:flutter/material.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/services/friends_service.dart';
import 'package:kittylogued/utils/text_normalizer.dart';

/// The person a book is lent to / borrowed from.
class PersonChoice {
  final String name;
  final int? userId;
  final bool isFriend;

  const PersonChoice(this.name, {this.userId, this.isFriend = false});
}

/// Search box + friends list. With [allowNickname] the user can also type a
/// name for someone without an account.
class PersonPicker extends StatefulWidget {
  final bool allowNickname;
  final ValueChanged<PersonChoice?> onChanged;

  const PersonPicker({
    super.key,
    this.allowNickname = true,
    required this.onChanged,
  });

  @override
  State<PersonPicker> createState() => _PersonPickerState();
}

class _PersonPickerState extends State<PersonPicker> {
  final TextEditingController _controller = TextEditingController();
  List<Friend> _friends = [];
  bool _loading = true;
  Friend? _selectedFriend;
  bool _nicknameSelected = false;

  @override
  void initState() {
    super.initState();
    AppScope.of(context).friends.loadFriends().then((list) {
      if (mounted) {
        setState(() {
          _friends = list;
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _emit() {
    final text = _controller.text.trim();
    if (_selectedFriend != null) {
      widget.onChanged(
        PersonChoice(
          _selectedFriend!.username,
          userId: _selectedFriend!.userId,
          isFriend: true,
        ),
      );
    } else if (_nicknameSelected && text.isNotEmpty) {
      widget.onChanged(PersonChoice(text));
    } else {
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final normalizedQuery = normalizeText(query);
    final matches = _friends
        .where(
          (f) =>
              normalizedQuery.isEmpty ||
              normalizeText(f.username).contains(normalizedQuery),
        )
        .toList();
    final exactFriend = _friends.any(
      (f) => normalizeText(f.username) == normalizedQuery,
    );
    final showNickname =
        widget.allowNickname && query.isNotEmpty && !exactFriend;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: widget.allowNickname
                ? 'Search friends or type a nickname'
                : 'Search friends',
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (_) {
            setState(() {
              // A typed nickname follows the text; a friend stays selected.
              if (_nicknameSelected && _controller.text.trim().isEmpty) {
                _nicknameSelected = false;
              }
            });
            _emit();
          },
        ),
        const SizedBox(height: 8),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              'Friends',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          if (matches.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                'No friends found.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final friend in matches)
                  ListTile(
                    dense: true,
                    selected: identical(_selectedFriend, friend),
                    leading: CircleAvatar(
                      radius: 16,
                      child: Text(friend.username.characters.first),
                    ),
                    title: Text(friend.username),
                    subtitle: friend.isExample
                        ? const Text('Example friend (friends list is a TODO)')
                        : null,
                    trailing: identical(_selectedFriend, friend)
                        ? const Icon(Icons.check_circle)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedFriend = friend;
                        _nicknameSelected = false;
                      });
                      _emit();
                    },
                  ),
              ],
            ),
          if (showNickname)
            ListTile(
              dense: true,
              selected: _nicknameSelected,
              leading: const Icon(Icons.person_add_alt),
              title: Text('Use "$query" (no account)'),
              trailing: _nicknameSelected
                  ? const Icon(Icons.check_circle)
                  : null,
              onTap: () {
                setState(() {
                  _nicknameSelected = true;
                  _selectedFriend = null;
                });
                _emit();
              },
            ),
        ],
      ],
    );
  }
}
