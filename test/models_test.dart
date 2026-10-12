import 'package:flutter_test/flutter_test.dart';
import 'package:kittylogued/services/batch_import_queue.dart';
import 'package:kittylogued/services/saved_views_store.dart';

void main() {
  test('SavedView survives a JSON round trip', () {
    const view = SavedView(
      name: 'Unread on Box 1',
      status: 'unread',
      shelf: 'Box 1',
      tags: ['sci-fi', 'borrowed'],
      sortKey: 'rating',
      ascending: false,
    );
    final copy = SavedView.fromJson(view.toJson());
    expect(copy.name, view.name);
    expect(copy.status, 'unread');
    expect(copy.shelf, 'Box 1');
    expect(copy.tags, ['sci-fi', 'borrowed']);
    expect(copy.sortKey, 'rating');
    expect(copy.ascending, isFalse);
  });

  test('BatchItem survives a JSON round trip (saved queue)', () {
    final item = BatchItem('9788025700000')
      ..title = 'Test'
      ..author = 'Someone'
      ..pages = '250'
      ..include = false
      ..status = BatchLookupStatus.found;
    final copy = BatchItem.fromJson(item.toJson());
    expect(copy.uid, item.uid);
    expect(copy.isbn, '9788025700000');
    expect(copy.title, 'Test');
    expect(copy.pages, '250');
    expect(copy.include, isFalse);
    expect(copy.status, BatchLookupStatus.found);
  });
}
