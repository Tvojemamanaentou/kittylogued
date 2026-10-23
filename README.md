# Kittylogued

A personal library catalogue for people who own a lot of physical books. Scan or look up a book, shelve it, track your reading, rate it, and keep everything on your own device.

Built with Flutter and a local SQLite database ([drift](https://drift.simonbinder.eu/)). It is offline-first: the app works without a server, and online features (friends, sharing, a Kittylogued server) are designed in but not connected yet.

---

## Features

**Adding books**
- Barcode scanning, ISBN lookup (typed or pasted) and title/author search from the big **+** button.
- **Batch mode** (switch above the **+** menu): scan or type many ISBNs, they are looked up in the background, then you review and edit everything before adding it to the library. The queue is saved, so it survives closing the app, and lookups wait and retry when you are offline.
- Title search groups results by book and lets you pick the **edition you own**.
- Missing page counts are looked up in other sources (knihovny.cz, Open Library, Google Books).
- Found books are cached for 30 days.

**Catalogue**
- Search that ignores accents and also looks in notes, comments, synopsis, shelf and tags.
- One filter tile: holding place (shelf), status, tags. Plus sorting (title, author, date added, rating, progress) and **saved views**.
- Swipe right to mark finished, swipe left to delete (with Undo). Long-press or right-click for a quick "update page / rate" sheet.
- On wide windows (980 px and up) a details panel shows the selected book.
- Tap a book to open its full-screen details (with an Edit button); on wide windows the details show in a side panel instead.
- Tap a cover to enlarge it.

**Reading**
- Status as a progress bar driven by the page you are on; the bar changes colour in five steps (to read, red, orange, yellow, finished green).
- Progress can be **backdated**: pick an earlier day, edit the started/finished dates, or add past entries.
- Half-star rating (0.5 to 5 stars, stored as 0-10).

**Notes, tags and privacy**
- **Public** (meant to be visible to friends once sharing exists): rating, comment, public tags.
- **Private** (never leave the device): private notes, private tags.

**Lending and borrowing**
- **Lend** button in the catalogue (under edit/delete): pick a friend or type a nickname for someone without an account, optional due date. The book is greyed out with "Lent to ...", and the button becomes **Return**.
- **Lending page**: everything lent out, borrowed and requested, with due dates (overdue in red) and a returned history.
- Ask a friend to lend you a book (saved now, sent once friends are connected), or record a book borrowed from someone without an account.
- Friends list is a stub with example friends until the server exists.

**Home and profile**
- Home: yearly reading goal, streak, charts (books and pages per month, rating spread), book suggestions and friends activity.
- Profile: username, profile picture, library overview (counts, books and pages per week/month/year, reading speed), Settings, and **Recently deleted**.
- Settings: light / dark / system, five colour palettes, a high-contrast option, and backups.

**Safety**
- Deleted books go to **Recently deleted** and are removed for good after 30 days.
- Automatic database backups: weekly, before every schema upgrade, and manual. Restore from Settings (finishes on the next app start).

**Desktop**
- `Ctrl`/`Cmd` + `N` add a book, `Ctrl`/`Cmd` + `F` search, `Esc` go back.

---

## Getting started

### Requirements
- Flutter (a recent stable release; the code uses Dart 3 records and `Color.withValues`)
- A device or desktop target for Flutter, plus a camera if you want barcode scanning

### Setup

```bash
git clone https://github.com/Tvojemamanaentou/kittylogued.git
cd kittylogued
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates the drift database code
flutter run
```

Run the build_runner step again whenever you change `lib/database/app_database.dart`.

### Tests and analysis

```bash
flutter analyze
flutter test
```

### Optional: NYT best sellers

The home page shows example titles until a source is connected. To use the New York Times list, get a free key from developer.nytimes.com and pass it where the source is created: `NytBestSellersSource(apiKey: ...)` in `lib/services/book_suggestions_service.dart`. For a released app, route this through your own server so the key is not shipped inside the app.

---

## Project structure

```
lib/
  main.dart               start-up: restore a scheduled backup, build services, run the app
  app.dart                MaterialApp, themes, Esc shortcut
  app_services.dart       AppServices + AppScope (shared services for all screens)
  auth/                   sign-in "brains": one stub per provider (email, Google, Facebook, Microsoft)
  database/               drift schema (app_database.dart) and file helpers (db_files.dart)
  models/                 BookDraft, TagDraft, ReadingLogDraft (what forms edit)
  repositories/           LibraryRepository and UserRepository: persistence boundaries
  services/               settings, auth, backups, ISBN lookup, lookup cache, batch queue,
                          saved views, cover cache, suggestions, friends activity, API auth
  api/                    API client, exceptions, and request/response DTOs
  pages/                  screens (home, catalogue, book form, search, batch, profile, ...)
  widgets/                reusable pieces (stars, tag editor, progress bar, charts, ...)
  theme/                  colour palettes and theme builder
  utils/                  pure helpers (progress, stats, insights, text, ids)
test/                     unit tests
```

### How it fits together
- **Screens get what they need from `AppScope.of(context)`** instead of constructor parameters. Services are built once in `main()`.
- **Saving goes through `LibraryRepository`.** Forms build a `BookDraft`; the repository writes the rows (ids, owner and timestamps are set in one place).
- **Pure logic lives in `utils/`** (reading progress, stats, insights) so it can be unit-tested without Flutter or a database.
- **Every book belongs to a user.** The main account is a `Users` row marked `isMe`; friends will be other rows, with their books read-only.

### Changing the database
1. Edit the tables in `lib/database/app_database.dart`.
2. Raise `kSchemaVersion` and add a migration step in `onUpgrade`.
3. Run `dart run build_runner build --delete-conflicting-outputs`.

A snapshot of the database is copied to the backups folder automatically before an upgrade runs.

---

## Data and privacy

- Everything is stored locally: the database (`kittylogued.sqlite`), cached covers, backups, and settings.
- Private notes and private tags are never meant to leave the device.
- ISBN and title lookups send the ISBN or search text to public catalogues (knihovny.cz, Open Library, Google Books).

---

## Status

**Working**
Everything under Features above, running locally.

**Stubs (structure is in place, logic is not)**
- Sign-in: every button signs in straight away; real logic goes in `lib/auth/*_auth_brain.dart`.
- Friends activity: example data in `friends_activity_service.dart`.
- Luxor best picks: placeholder (no public API); NYT works once a key is set.
- Username uniqueness: `AppSettings.usernameAvailabilityCheck` is the hook for a server.

**Planned**
- Kittylogued server as the first lookup source and as a place to send new-book data (with an offline retry queue and a consent switch).
- Working weekly/monthly recommendations (for example via a server that caches NYT and Open Library lists).
- Home redesign: full-width carousels, friend tiles with blurred covers, full-screen reels-style feed.
- Real friends, notifications for borrow requests, and changing the friend's book state when a request is accepted.
- Export and import (CSV/JSON), Czech/English translations, shelves as real entities with a shelf audit, duplicate detection and merge.

---

## License

Not chosen yet. Add a `LICENSE` file before sharing the code.
