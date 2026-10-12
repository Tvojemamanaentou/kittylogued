import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/models/book_draft.dart';

/// Edits the tags of one book. Every tag is either private (lock icon,
/// stays on this device) or public (globe icon, visible to friends).
/// Tap a chip to switch its type, tap the x to remove it.
class TagEditor extends StatefulWidget {
  final AppDatabase database;
  final List<TagDraft> tags;
  final ValueChanged<List<TagDraft>> onChanged;

  const TagEditor({
    super.key,
    required this.database,
    required this.tags,
    required this.onChanged,
  });

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  final TextEditingController _controller = TextEditingController();
  bool _newIsPublic = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _has(String name) =>
      widget.tags.any((t) => t.name.toLowerCase() == name.toLowerCase());

  void _add(String raw, {bool? isPublic}) {
    final next = [...widget.tags];
    for (final part in raw.split(',')) {
      final name = part.trim();
      if (name.isNotEmpty && !_has(name) &&
          !next.any((t) => t.name.toLowerCase() == name.toLowerCase())) {
        next.add(TagDraft(name, isPublic: isPublic ?? _newIsPublic));
      }
    }
    _controller.clear();
    widget.onChanged(next);
  }

  void _toggle(TagDraft tag) {
    widget.onChanged([
      for (final t in widget.tags)
        t.name == tag.name ? t.copyWith(isPublic: !t.isPublic) : t,
    ]);
  }

  void _remove(TagDraft tag) {
    widget.onChanged(widget.tags.where((t) => t.name != tag.name).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.sell_outlined, size: 18, color: Colors.grey),
            const SizedBox(width: 6),
            Text('Tags', style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final tag in widget.tags)
                InputChip(
                  avatar: Icon(
                    tag.isPublic ? Icons.public : Icons.lock_outline,
                    size: 16,
                  ),
                  label: Text(tag.name),
                  tooltip: tag.isPublic
                      ? 'Public - tap to make private'
                      : 'Private - tap to make public',
                  onPressed: () => _toggle(tag),
                  onDeleted: () => _remove(tag),
                ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Add tag',
                  hintText: 'e.g. favourites, borrowed, sci-fi',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add tag',
                    onPressed: () => _add(_controller.text),
                  ),
                ),
                onSubmitted: _add,
              ),
            ),
            const SizedBox(width: 8),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.lock_outline, size: 18),
                  tooltip: 'New tags are private',
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.public, size: 18),
                  tooltip: 'New tags are public',
                ),
              ],
              selected: {_newIsPublic},
              onSelectionChanged: (s) => setState(() => _newIsPublic = s.first),
            ),
          ],
        ),
        StreamBuilder<List<Tag>>(
          stream: widget.database.watchAllTags(),
          builder: (context, snapshot) {
            final suggestions = (snapshot.data ?? const <Tag>[])
                .where((t) => !_has(t.name))
                .take(12)
                .toList();
            if (suggestions.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final tag in suggestions)
                    ActionChip(
                      avatar: Icon(
                        tag.isPublic ? Icons.public : Icons.lock_outline,
                        size: 14,
                      ),
                      label: Text(tag.name),
                      onPressed: () => _add(tag.name, isPublic: tag.isPublic),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
