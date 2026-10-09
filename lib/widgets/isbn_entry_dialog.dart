import 'package:flutter/material.dart';

/// Small dialog asking the user to type an ISBN. Pops with the entered text.
class IsbnEntryDialog extends StatefulWidget {
  const IsbnEntryDialog({super.key});

  @override
  State<IsbnEntryDialog> createState() => _IsbnEntryDialogState();
}

class _IsbnEntryDialogState extends State<IsbnEntryDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final isbn = _controller.text.trim();
    if (isbn.isEmpty) return;
    Navigator.of(context).pop(isbn);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ISBN Lookup'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          labelText: 'ISBN',
          hintText: 'e.g. 978-80-257-0000-0',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Look up')),
      ],
    );
  }
}
