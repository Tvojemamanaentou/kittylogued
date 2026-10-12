// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMeMeta = const VerificationMeta('isMe');
  @override
  late final GeneratedColumn<bool> isMe = GeneratedColumn<bool>(
    'is_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_me" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uid,
    username,
    displayName,
    avatarUrl,
    isMe,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('is_me')) {
      context.handle(
        _isMeMeta,
        isMe.isAcceptableOrUnknown(data['is_me']!, _isMeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      isMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_me'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String uid;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final bool isMe;
  final DateTime createdAt;
  const User({
    required this.id,
    required this.uid,
    this.username,
    this.displayName,
    this.avatarUrl,
    required this.isMe,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['is_me'] = Variable<bool>(isMe);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      uid: Value(uid),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      isMe: Value(isMe),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      username: serializer.fromJson<String?>(json['username']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      isMe: serializer.fromJson<bool>(json['isMe']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'username': serializer.toJson<String?>(username),
      'displayName': serializer.toJson<String?>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'isMe': serializer.toJson<bool>(isMe),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith({
    int? id,
    String? uid,
    Value<String?> username = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    bool? isMe,
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    uid: uid ?? this.uid,
    username: username.present ? username.value : this.username,
    displayName: displayName.present ? displayName.value : this.displayName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    isMe: isMe ?? this.isMe,
    createdAt: createdAt ?? this.createdAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      isMe: data.isMe.present ? data.isMe.value : this.isMe,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('isMe: $isMe, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uid, username, displayName, avatarUrl, isMe, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.isMe == this.isMe &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String?> username;
  final Value<String?> displayName;
  final Value<String?> avatarUrl;
  final Value<bool> isMe;
  final Value<DateTime> createdAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.isMe = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String uid,
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.isMe = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : uid = Value(uid);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<bool>? isMe,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (isMe != null) 'is_me': isMe,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? uid,
    Value<String?>? username,
    Value<String?>? displayName,
    Value<String?>? avatarUrl,
    Value<bool>? isMe,
    Value<DateTime>? createdAt,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMe: isMe ?? this.isMe,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (isMe.present) {
      map['is_me'] = Variable<bool>(isMe.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('isMe: $isMe, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _internalIdMeta = const VerificationMeta(
    'internalId',
  );
  @override
  late final GeneratedColumn<String> internalId = GeneratedColumn<String>(
    'internal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalTitleMeta = const VerificationMeta(
    'originalTitle',
  );
  @override
  late final GeneratedColumn<String> originalTitle = GeneratedColumn<String>(
    'original_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
    'isbn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shelfLocationMeta = const VerificationMeta(
    'shelfLocation',
  );
  @override
  late final GeneratedColumn<String> shelfLocation = GeneratedColumn<String>(
    'shelf_location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signaturaMeta = const VerificationMeta(
    'signatura',
  );
  @override
  late final GeneratedColumn<String> signatura = GeneratedColumn<String>(
    'signatura',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publicationYearMeta = const VerificationMeta(
    'publicationYear',
  );
  @override
  late final GeneratedColumn<int> publicationYear = GeneratedColumn<int>(
    'publication_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cze'),
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bindingTypeMeta = const VerificationMeta(
    'bindingType',
  );
  @override
  late final GeneratedColumn<String> bindingType = GeneratedColumn<String>(
    'binding_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondaryContributorsMeta =
      const VerificationMeta('secondaryContributors');
  @override
  late final GeneratedColumn<String> secondaryContributors =
      GeneratedColumn<String>(
        'secondary_contributors',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _readingStatusMeta = const VerificationMeta(
    'readingStatus',
  );
  @override
  late final GeneratedColumn<String> readingStatus = GeneratedColumn<String>(
    'reading_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unread'),
  );
  static const VerificationMeta _personalRatingMeta = const VerificationMeta(
    'personalRating',
  );
  @override
  late final GeneratedColumn<double> personalRating = GeneratedColumn<double>(
    'personal_rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _privateNotesMeta = const VerificationMeta(
    'privateNotes',
  );
  @override
  late final GeneratedColumn<String> privateNotes = GeneratedColumn<String>(
    'private_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _physicalConditionMeta = const VerificationMeta(
    'physicalCondition',
  );
  @override
  late final GeneratedColumn<String> physicalCondition =
      GeneratedColumn<String>(
        'physical_condition',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isWishlistMeta = const VerificationMeta(
    'isWishlist',
  );
  @override
  late final GeneratedColumn<bool> isWishlist = GeneratedColumn<bool>(
    'is_wishlist',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_wishlist" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synopsisMeta = const VerificationMeta(
    'synopsis',
  );
  @override
  late final GeneratedColumn<String> synopsis = GeneratedColumn<String>(
    'synopsis',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<int> ownerId = GeneratedColumn<int>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingHalfStarsMeta = const VerificationMeta(
    'ratingHalfStars',
  );
  @override
  late final GeneratedColumn<int> ratingHalfStars = GeneratedColumn<int>(
    'rating_half_stars',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewTextMeta = const VerificationMeta(
    'reviewText',
  );
  @override
  late final GeneratedColumn<String> reviewText = GeneratedColumn<String>(
    'review_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    internalId,
    title,
    author,
    originalTitle,
    isbn,
    shelfLocation,
    signatura,
    publisher,
    publicationYear,
    language,
    pageCount,
    bindingType,
    secondaryContributors,
    readingStatus,
    personalRating,
    privateNotes,
    physicalCondition,
    isWishlist,
    coverUrl,
    synopsis,
    uid,
    ownerId,
    updatedAt,
    deletedAt,
    ratingHalfStars,
    reviewText,
    currentPage,
    startedAt,
    finishedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('internal_id')) {
      context.handle(
        _internalIdMeta,
        internalId.isAcceptableOrUnknown(data['internal_id']!, _internalIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('original_title')) {
      context.handle(
        _originalTitleMeta,
        originalTitle.isAcceptableOrUnknown(
          data['original_title']!,
          _originalTitleMeta,
        ),
      );
    }
    if (data.containsKey('isbn')) {
      context.handle(
        _isbnMeta,
        isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta),
      );
    }
    if (data.containsKey('shelf_location')) {
      context.handle(
        _shelfLocationMeta,
        shelfLocation.isAcceptableOrUnknown(
          data['shelf_location']!,
          _shelfLocationMeta,
        ),
      );
    }
    if (data.containsKey('signatura')) {
      context.handle(
        _signaturaMeta,
        signatura.isAcceptableOrUnknown(data['signatura']!, _signaturaMeta),
      );
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('publication_year')) {
      context.handle(
        _publicationYearMeta,
        publicationYear.isAcceptableOrUnknown(
          data['publication_year']!,
          _publicationYearMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('binding_type')) {
      context.handle(
        _bindingTypeMeta,
        bindingType.isAcceptableOrUnknown(
          data['binding_type']!,
          _bindingTypeMeta,
        ),
      );
    }
    if (data.containsKey('secondary_contributors')) {
      context.handle(
        _secondaryContributorsMeta,
        secondaryContributors.isAcceptableOrUnknown(
          data['secondary_contributors']!,
          _secondaryContributorsMeta,
        ),
      );
    }
    if (data.containsKey('reading_status')) {
      context.handle(
        _readingStatusMeta,
        readingStatus.isAcceptableOrUnknown(
          data['reading_status']!,
          _readingStatusMeta,
        ),
      );
    }
    if (data.containsKey('personal_rating')) {
      context.handle(
        _personalRatingMeta,
        personalRating.isAcceptableOrUnknown(
          data['personal_rating']!,
          _personalRatingMeta,
        ),
      );
    }
    if (data.containsKey('private_notes')) {
      context.handle(
        _privateNotesMeta,
        privateNotes.isAcceptableOrUnknown(
          data['private_notes']!,
          _privateNotesMeta,
        ),
      );
    }
    if (data.containsKey('physical_condition')) {
      context.handle(
        _physicalConditionMeta,
        physicalCondition.isAcceptableOrUnknown(
          data['physical_condition']!,
          _physicalConditionMeta,
        ),
      );
    }
    if (data.containsKey('is_wishlist')) {
      context.handle(
        _isWishlistMeta,
        isWishlist.isAcceptableOrUnknown(data['is_wishlist']!, _isWishlistMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('synopsis')) {
      context.handle(
        _synopsisMeta,
        synopsis.isAcceptableOrUnknown(data['synopsis']!, _synopsisMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rating_half_stars')) {
      context.handle(
        _ratingHalfStarsMeta,
        ratingHalfStars.isAcceptableOrUnknown(
          data['rating_half_stars']!,
          _ratingHalfStarsMeta,
        ),
      );
    }
    if (data.containsKey('review_text')) {
      context.handle(
        _reviewTextMeta,
        reviewText.isAcceptableOrUnknown(data['review_text']!, _reviewTextMeta),
      );
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      internalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}internal_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      originalTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_title'],
      ),
      isbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn'],
      ),
      shelfLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shelf_location'],
      ),
      signatura: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signatura'],
      ),
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      publicationYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publication_year'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      bindingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}binding_type'],
      ),
      secondaryContributors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_contributors'],
      ),
      readingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_status'],
      )!,
      personalRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}personal_rating'],
      ),
      privateNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}private_notes'],
      ),
      physicalCondition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}physical_condition'],
      ),
      isWishlist: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_wishlist'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      synopsis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synopsis'],
      ),
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      ),
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}owner_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      ratingHalfStars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating_half_stars'],
      ),
      reviewText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_text'],
      ),
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String? internalId;
  final String title;
  final String author;
  final String? originalTitle;
  final String? isbn;
  final String? shelfLocation;
  final String? signatura;
  final String? publisher;
  final int? publicationYear;
  final String language;
  final int? pageCount;
  final String? bindingType;
  final String? secondaryContributors;
  final String readingStatus;
  final double? personalRating;
  final String? privateNotes;
  final String? physicalCondition;
  final bool isWishlist;
  final String? coverUrl;
  final String? synopsis;
  final String? uid;
  final int? ownerId;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final int? ratingHalfStars;
  final String? reviewText;
  final int currentPage;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime createdAt;
  const Book({
    required this.id,
    this.internalId,
    required this.title,
    required this.author,
    this.originalTitle,
    this.isbn,
    this.shelfLocation,
    this.signatura,
    this.publisher,
    this.publicationYear,
    required this.language,
    this.pageCount,
    this.bindingType,
    this.secondaryContributors,
    required this.readingStatus,
    this.personalRating,
    this.privateNotes,
    this.physicalCondition,
    required this.isWishlist,
    this.coverUrl,
    this.synopsis,
    this.uid,
    this.ownerId,
    this.updatedAt,
    this.deletedAt,
    this.ratingHalfStars,
    this.reviewText,
    required this.currentPage,
    this.startedAt,
    this.finishedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || internalId != null) {
      map['internal_id'] = Variable<String>(internalId);
    }
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || originalTitle != null) {
      map['original_title'] = Variable<String>(originalTitle);
    }
    if (!nullToAbsent || isbn != null) {
      map['isbn'] = Variable<String>(isbn);
    }
    if (!nullToAbsent || shelfLocation != null) {
      map['shelf_location'] = Variable<String>(shelfLocation);
    }
    if (!nullToAbsent || signatura != null) {
      map['signatura'] = Variable<String>(signatura);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || publicationYear != null) {
      map['publication_year'] = Variable<int>(publicationYear);
    }
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || bindingType != null) {
      map['binding_type'] = Variable<String>(bindingType);
    }
    if (!nullToAbsent || secondaryContributors != null) {
      map['secondary_contributors'] = Variable<String>(secondaryContributors);
    }
    map['reading_status'] = Variable<String>(readingStatus);
    if (!nullToAbsent || personalRating != null) {
      map['personal_rating'] = Variable<double>(personalRating);
    }
    if (!nullToAbsent || privateNotes != null) {
      map['private_notes'] = Variable<String>(privateNotes);
    }
    if (!nullToAbsent || physicalCondition != null) {
      map['physical_condition'] = Variable<String>(physicalCondition);
    }
    map['is_wishlist'] = Variable<bool>(isWishlist);
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || synopsis != null) {
      map['synopsis'] = Variable<String>(synopsis);
    }
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<String>(uid);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<int>(ownerId);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || ratingHalfStars != null) {
      map['rating_half_stars'] = Variable<int>(ratingHalfStars);
    }
    if (!nullToAbsent || reviewText != null) {
      map['review_text'] = Variable<String>(reviewText);
    }
    map['current_page'] = Variable<int>(currentPage);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      internalId: internalId == null && nullToAbsent
          ? const Value.absent()
          : Value(internalId),
      title: Value(title),
      author: Value(author),
      originalTitle: originalTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(originalTitle),
      isbn: isbn == null && nullToAbsent ? const Value.absent() : Value(isbn),
      shelfLocation: shelfLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfLocation),
      signatura: signatura == null && nullToAbsent
          ? const Value.absent()
          : Value(signatura),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      publicationYear: publicationYear == null && nullToAbsent
          ? const Value.absent()
          : Value(publicationYear),
      language: Value(language),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      bindingType: bindingType == null && nullToAbsent
          ? const Value.absent()
          : Value(bindingType),
      secondaryContributors: secondaryContributors == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryContributors),
      readingStatus: Value(readingStatus),
      personalRating: personalRating == null && nullToAbsent
          ? const Value.absent()
          : Value(personalRating),
      privateNotes: privateNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(privateNotes),
      physicalCondition: physicalCondition == null && nullToAbsent
          ? const Value.absent()
          : Value(physicalCondition),
      isWishlist: Value(isWishlist),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      synopsis: synopsis == null && nullToAbsent
          ? const Value.absent()
          : Value(synopsis),
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      ratingHalfStars: ratingHalfStars == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingHalfStars),
      reviewText: reviewText == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewText),
      currentPage: Value(currentPage),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      internalId: serializer.fromJson<String?>(json['internalId']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      originalTitle: serializer.fromJson<String?>(json['originalTitle']),
      isbn: serializer.fromJson<String?>(json['isbn']),
      shelfLocation: serializer.fromJson<String?>(json['shelfLocation']),
      signatura: serializer.fromJson<String?>(json['signatura']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      publicationYear: serializer.fromJson<int?>(json['publicationYear']),
      language: serializer.fromJson<String>(json['language']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      bindingType: serializer.fromJson<String?>(json['bindingType']),
      secondaryContributors: serializer.fromJson<String?>(
        json['secondaryContributors'],
      ),
      readingStatus: serializer.fromJson<String>(json['readingStatus']),
      personalRating: serializer.fromJson<double?>(json['personalRating']),
      privateNotes: serializer.fromJson<String?>(json['privateNotes']),
      physicalCondition: serializer.fromJson<String?>(
        json['physicalCondition'],
      ),
      isWishlist: serializer.fromJson<bool>(json['isWishlist']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      synopsis: serializer.fromJson<String?>(json['synopsis']),
      uid: serializer.fromJson<String?>(json['uid']),
      ownerId: serializer.fromJson<int?>(json['ownerId']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      ratingHalfStars: serializer.fromJson<int?>(json['ratingHalfStars']),
      reviewText: serializer.fromJson<String?>(json['reviewText']),
      currentPage: serializer.fromJson<int>(json['currentPage']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'internalId': serializer.toJson<String?>(internalId),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'originalTitle': serializer.toJson<String?>(originalTitle),
      'isbn': serializer.toJson<String?>(isbn),
      'shelfLocation': serializer.toJson<String?>(shelfLocation),
      'signatura': serializer.toJson<String?>(signatura),
      'publisher': serializer.toJson<String?>(publisher),
      'publicationYear': serializer.toJson<int?>(publicationYear),
      'language': serializer.toJson<String>(language),
      'pageCount': serializer.toJson<int?>(pageCount),
      'bindingType': serializer.toJson<String?>(bindingType),
      'secondaryContributors': serializer.toJson<String?>(
        secondaryContributors,
      ),
      'readingStatus': serializer.toJson<String>(readingStatus),
      'personalRating': serializer.toJson<double?>(personalRating),
      'privateNotes': serializer.toJson<String?>(privateNotes),
      'physicalCondition': serializer.toJson<String?>(physicalCondition),
      'isWishlist': serializer.toJson<bool>(isWishlist),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'synopsis': serializer.toJson<String?>(synopsis),
      'uid': serializer.toJson<String?>(uid),
      'ownerId': serializer.toJson<int?>(ownerId),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'ratingHalfStars': serializer.toJson<int?>(ratingHalfStars),
      'reviewText': serializer.toJson<String?>(reviewText),
      'currentPage': serializer.toJson<int>(currentPage),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Book copyWith({
    int? id,
    Value<String?> internalId = const Value.absent(),
    String? title,
    String? author,
    Value<String?> originalTitle = const Value.absent(),
    Value<String?> isbn = const Value.absent(),
    Value<String?> shelfLocation = const Value.absent(),
    Value<String?> signatura = const Value.absent(),
    Value<String?> publisher = const Value.absent(),
    Value<int?> publicationYear = const Value.absent(),
    String? language,
    Value<int?> pageCount = const Value.absent(),
    Value<String?> bindingType = const Value.absent(),
    Value<String?> secondaryContributors = const Value.absent(),
    String? readingStatus,
    Value<double?> personalRating = const Value.absent(),
    Value<String?> privateNotes = const Value.absent(),
    Value<String?> physicalCondition = const Value.absent(),
    bool? isWishlist,
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> synopsis = const Value.absent(),
    Value<String?> uid = const Value.absent(),
    Value<int?> ownerId = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> ratingHalfStars = const Value.absent(),
    Value<String?> reviewText = const Value.absent(),
    int? currentPage,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
    DateTime? createdAt,
  }) => Book(
    id: id ?? this.id,
    internalId: internalId.present ? internalId.value : this.internalId,
    title: title ?? this.title,
    author: author ?? this.author,
    originalTitle: originalTitle.present
        ? originalTitle.value
        : this.originalTitle,
    isbn: isbn.present ? isbn.value : this.isbn,
    shelfLocation: shelfLocation.present
        ? shelfLocation.value
        : this.shelfLocation,
    signatura: signatura.present ? signatura.value : this.signatura,
    publisher: publisher.present ? publisher.value : this.publisher,
    publicationYear: publicationYear.present
        ? publicationYear.value
        : this.publicationYear,
    language: language ?? this.language,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    bindingType: bindingType.present ? bindingType.value : this.bindingType,
    secondaryContributors: secondaryContributors.present
        ? secondaryContributors.value
        : this.secondaryContributors,
    readingStatus: readingStatus ?? this.readingStatus,
    personalRating: personalRating.present
        ? personalRating.value
        : this.personalRating,
    privateNotes: privateNotes.present ? privateNotes.value : this.privateNotes,
    physicalCondition: physicalCondition.present
        ? physicalCondition.value
        : this.physicalCondition,
    isWishlist: isWishlist ?? this.isWishlist,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    synopsis: synopsis.present ? synopsis.value : this.synopsis,
    uid: uid.present ? uid.value : this.uid,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    ratingHalfStars: ratingHalfStars.present
        ? ratingHalfStars.value
        : this.ratingHalfStars,
    reviewText: reviewText.present ? reviewText.value : this.reviewText,
    currentPage: currentPage ?? this.currentPage,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      internalId: data.internalId.present
          ? data.internalId.value
          : this.internalId,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      originalTitle: data.originalTitle.present
          ? data.originalTitle.value
          : this.originalTitle,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      shelfLocation: data.shelfLocation.present
          ? data.shelfLocation.value
          : this.shelfLocation,
      signatura: data.signatura.present ? data.signatura.value : this.signatura,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      publicationYear: data.publicationYear.present
          ? data.publicationYear.value
          : this.publicationYear,
      language: data.language.present ? data.language.value : this.language,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      bindingType: data.bindingType.present
          ? data.bindingType.value
          : this.bindingType,
      secondaryContributors: data.secondaryContributors.present
          ? data.secondaryContributors.value
          : this.secondaryContributors,
      readingStatus: data.readingStatus.present
          ? data.readingStatus.value
          : this.readingStatus,
      personalRating: data.personalRating.present
          ? data.personalRating.value
          : this.personalRating,
      privateNotes: data.privateNotes.present
          ? data.privateNotes.value
          : this.privateNotes,
      physicalCondition: data.physicalCondition.present
          ? data.physicalCondition.value
          : this.physicalCondition,
      isWishlist: data.isWishlist.present
          ? data.isWishlist.value
          : this.isWishlist,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      synopsis: data.synopsis.present ? data.synopsis.value : this.synopsis,
      uid: data.uid.present ? data.uid.value : this.uid,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      ratingHalfStars: data.ratingHalfStars.present
          ? data.ratingHalfStars.value
          : this.ratingHalfStars,
      reviewText: data.reviewText.present
          ? data.reviewText.value
          : this.reviewText,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('internalId: $internalId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('originalTitle: $originalTitle, ')
          ..write('isbn: $isbn, ')
          ..write('shelfLocation: $shelfLocation, ')
          ..write('signatura: $signatura, ')
          ..write('publisher: $publisher, ')
          ..write('publicationYear: $publicationYear, ')
          ..write('language: $language, ')
          ..write('pageCount: $pageCount, ')
          ..write('bindingType: $bindingType, ')
          ..write('secondaryContributors: $secondaryContributors, ')
          ..write('readingStatus: $readingStatus, ')
          ..write('personalRating: $personalRating, ')
          ..write('privateNotes: $privateNotes, ')
          ..write('physicalCondition: $physicalCondition, ')
          ..write('isWishlist: $isWishlist, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('synopsis: $synopsis, ')
          ..write('uid: $uid, ')
          ..write('ownerId: $ownerId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('ratingHalfStars: $ratingHalfStars, ')
          ..write('reviewText: $reviewText, ')
          ..write('currentPage: $currentPage, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    internalId,
    title,
    author,
    originalTitle,
    isbn,
    shelfLocation,
    signatura,
    publisher,
    publicationYear,
    language,
    pageCount,
    bindingType,
    secondaryContributors,
    readingStatus,
    personalRating,
    privateNotes,
    physicalCondition,
    isWishlist,
    coverUrl,
    synopsis,
    uid,
    ownerId,
    updatedAt,
    deletedAt,
    ratingHalfStars,
    reviewText,
    currentPage,
    startedAt,
    finishedAt,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.internalId == this.internalId &&
          other.title == this.title &&
          other.author == this.author &&
          other.originalTitle == this.originalTitle &&
          other.isbn == this.isbn &&
          other.shelfLocation == this.shelfLocation &&
          other.signatura == this.signatura &&
          other.publisher == this.publisher &&
          other.publicationYear == this.publicationYear &&
          other.language == this.language &&
          other.pageCount == this.pageCount &&
          other.bindingType == this.bindingType &&
          other.secondaryContributors == this.secondaryContributors &&
          other.readingStatus == this.readingStatus &&
          other.personalRating == this.personalRating &&
          other.privateNotes == this.privateNotes &&
          other.physicalCondition == this.physicalCondition &&
          other.isWishlist == this.isWishlist &&
          other.coverUrl == this.coverUrl &&
          other.synopsis == this.synopsis &&
          other.uid == this.uid &&
          other.ownerId == this.ownerId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.ratingHalfStars == this.ratingHalfStars &&
          other.reviewText == this.reviewText &&
          other.currentPage == this.currentPage &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.createdAt == this.createdAt);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String?> internalId;
  final Value<String> title;
  final Value<String> author;
  final Value<String?> originalTitle;
  final Value<String?> isbn;
  final Value<String?> shelfLocation;
  final Value<String?> signatura;
  final Value<String?> publisher;
  final Value<int?> publicationYear;
  final Value<String> language;
  final Value<int?> pageCount;
  final Value<String?> bindingType;
  final Value<String?> secondaryContributors;
  final Value<String> readingStatus;
  final Value<double?> personalRating;
  final Value<String?> privateNotes;
  final Value<String?> physicalCondition;
  final Value<bool> isWishlist;
  final Value<String?> coverUrl;
  final Value<String?> synopsis;
  final Value<String?> uid;
  final Value<int?> ownerId;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> ratingHalfStars;
  final Value<String?> reviewText;
  final Value<int> currentPage;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<DateTime> createdAt;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.internalId = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.originalTitle = const Value.absent(),
    this.isbn = const Value.absent(),
    this.shelfLocation = const Value.absent(),
    this.signatura = const Value.absent(),
    this.publisher = const Value.absent(),
    this.publicationYear = const Value.absent(),
    this.language = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.bindingType = const Value.absent(),
    this.secondaryContributors = const Value.absent(),
    this.readingStatus = const Value.absent(),
    this.personalRating = const Value.absent(),
    this.privateNotes = const Value.absent(),
    this.physicalCondition = const Value.absent(),
    this.isWishlist = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.synopsis = const Value.absent(),
    this.uid = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.ratingHalfStars = const Value.absent(),
    this.reviewText = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    this.internalId = const Value.absent(),
    required String title,
    required String author,
    this.originalTitle = const Value.absent(),
    this.isbn = const Value.absent(),
    this.shelfLocation = const Value.absent(),
    this.signatura = const Value.absent(),
    this.publisher = const Value.absent(),
    this.publicationYear = const Value.absent(),
    this.language = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.bindingType = const Value.absent(),
    this.secondaryContributors = const Value.absent(),
    this.readingStatus = const Value.absent(),
    this.personalRating = const Value.absent(),
    this.privateNotes = const Value.absent(),
    this.physicalCondition = const Value.absent(),
    this.isWishlist = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.synopsis = const Value.absent(),
    this.uid = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.ratingHalfStars = const Value.absent(),
    this.reviewText = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       author = Value(author);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? internalId,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? originalTitle,
    Expression<String>? isbn,
    Expression<String>? shelfLocation,
    Expression<String>? signatura,
    Expression<String>? publisher,
    Expression<int>? publicationYear,
    Expression<String>? language,
    Expression<int>? pageCount,
    Expression<String>? bindingType,
    Expression<String>? secondaryContributors,
    Expression<String>? readingStatus,
    Expression<double>? personalRating,
    Expression<String>? privateNotes,
    Expression<String>? physicalCondition,
    Expression<bool>? isWishlist,
    Expression<String>? coverUrl,
    Expression<String>? synopsis,
    Expression<String>? uid,
    Expression<int>? ownerId,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? ratingHalfStars,
    Expression<String>? reviewText,
    Expression<int>? currentPage,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (internalId != null) 'internal_id': internalId,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (originalTitle != null) 'original_title': originalTitle,
      if (isbn != null) 'isbn': isbn,
      if (shelfLocation != null) 'shelf_location': shelfLocation,
      if (signatura != null) 'signatura': signatura,
      if (publisher != null) 'publisher': publisher,
      if (publicationYear != null) 'publication_year': publicationYear,
      if (language != null) 'language': language,
      if (pageCount != null) 'page_count': pageCount,
      if (bindingType != null) 'binding_type': bindingType,
      if (secondaryContributors != null)
        'secondary_contributors': secondaryContributors,
      if (readingStatus != null) 'reading_status': readingStatus,
      if (personalRating != null) 'personal_rating': personalRating,
      if (privateNotes != null) 'private_notes': privateNotes,
      if (physicalCondition != null) 'physical_condition': physicalCondition,
      if (isWishlist != null) 'is_wishlist': isWishlist,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (synopsis != null) 'synopsis': synopsis,
      if (uid != null) 'uid': uid,
      if (ownerId != null) 'owner_id': ownerId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (ratingHalfStars != null) 'rating_half_stars': ratingHalfStars,
      if (reviewText != null) 'review_text': reviewText,
      if (currentPage != null) 'current_page': currentPage,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String?>? internalId,
    Value<String>? title,
    Value<String>? author,
    Value<String?>? originalTitle,
    Value<String?>? isbn,
    Value<String?>? shelfLocation,
    Value<String?>? signatura,
    Value<String?>? publisher,
    Value<int?>? publicationYear,
    Value<String>? language,
    Value<int?>? pageCount,
    Value<String?>? bindingType,
    Value<String?>? secondaryContributors,
    Value<String>? readingStatus,
    Value<double?>? personalRating,
    Value<String?>? privateNotes,
    Value<String?>? physicalCondition,
    Value<bool>? isWishlist,
    Value<String?>? coverUrl,
    Value<String?>? synopsis,
    Value<String?>? uid,
    Value<int?>? ownerId,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? ratingHalfStars,
    Value<String?>? reviewText,
    Value<int>? currentPage,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<DateTime>? createdAt,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      internalId: internalId ?? this.internalId,
      title: title ?? this.title,
      author: author ?? this.author,
      originalTitle: originalTitle ?? this.originalTitle,
      isbn: isbn ?? this.isbn,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      signatura: signatura ?? this.signatura,
      publisher: publisher ?? this.publisher,
      publicationYear: publicationYear ?? this.publicationYear,
      language: language ?? this.language,
      pageCount: pageCount ?? this.pageCount,
      bindingType: bindingType ?? this.bindingType,
      secondaryContributors:
          secondaryContributors ?? this.secondaryContributors,
      readingStatus: readingStatus ?? this.readingStatus,
      personalRating: personalRating ?? this.personalRating,
      privateNotes: privateNotes ?? this.privateNotes,
      physicalCondition: physicalCondition ?? this.physicalCondition,
      isWishlist: isWishlist ?? this.isWishlist,
      coverUrl: coverUrl ?? this.coverUrl,
      synopsis: synopsis ?? this.synopsis,
      uid: uid ?? this.uid,
      ownerId: ownerId ?? this.ownerId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      ratingHalfStars: ratingHalfStars ?? this.ratingHalfStars,
      reviewText: reviewText ?? this.reviewText,
      currentPage: currentPage ?? this.currentPage,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (internalId.present) {
      map['internal_id'] = Variable<String>(internalId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (originalTitle.present) {
      map['original_title'] = Variable<String>(originalTitle.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (shelfLocation.present) {
      map['shelf_location'] = Variable<String>(shelfLocation.value);
    }
    if (signatura.present) {
      map['signatura'] = Variable<String>(signatura.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (publicationYear.present) {
      map['publication_year'] = Variable<int>(publicationYear.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (bindingType.present) {
      map['binding_type'] = Variable<String>(bindingType.value);
    }
    if (secondaryContributors.present) {
      map['secondary_contributors'] = Variable<String>(
        secondaryContributors.value,
      );
    }
    if (readingStatus.present) {
      map['reading_status'] = Variable<String>(readingStatus.value);
    }
    if (personalRating.present) {
      map['personal_rating'] = Variable<double>(personalRating.value);
    }
    if (privateNotes.present) {
      map['private_notes'] = Variable<String>(privateNotes.value);
    }
    if (physicalCondition.present) {
      map['physical_condition'] = Variable<String>(physicalCondition.value);
    }
    if (isWishlist.present) {
      map['is_wishlist'] = Variable<bool>(isWishlist.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (synopsis.present) {
      map['synopsis'] = Variable<String>(synopsis.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<int>(ownerId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (ratingHalfStars.present) {
      map['rating_half_stars'] = Variable<int>(ratingHalfStars.value);
    }
    if (reviewText.present) {
      map['review_text'] = Variable<String>(reviewText.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('internalId: $internalId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('originalTitle: $originalTitle, ')
          ..write('isbn: $isbn, ')
          ..write('shelfLocation: $shelfLocation, ')
          ..write('signatura: $signatura, ')
          ..write('publisher: $publisher, ')
          ..write('publicationYear: $publicationYear, ')
          ..write('language: $language, ')
          ..write('pageCount: $pageCount, ')
          ..write('bindingType: $bindingType, ')
          ..write('secondaryContributors: $secondaryContributors, ')
          ..write('readingStatus: $readingStatus, ')
          ..write('personalRating: $personalRating, ')
          ..write('privateNotes: $privateNotes, ')
          ..write('physicalCondition: $physicalCondition, ')
          ..write('isWishlist: $isWishlist, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('synopsis: $synopsis, ')
          ..write('uid: $uid, ')
          ..write('ownerId: $ownerId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('ratingHalfStars: $ratingHalfStars, ')
          ..write('reviewText: $reviewText, ')
          ..write('currentPage: $currentPage, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isPublicMeta = const VerificationMeta(
    'isPublic',
  );
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isPublic];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_public')) {
      context.handle(
        _isPublicMeta,
        isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final bool isPublic;
  const Tag({required this.id, required this.name, required this.isPublic});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_public'] = Variable<bool>(isPublic);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      isPublic: Value(isPublic),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isPublic': serializer.toJson<bool>(isPublic),
    };
  }

  Tag copyWith({int? id, String? name, bool? isPublic}) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    isPublic: isPublic ?? this.isPublic,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isPublic: $isPublic')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isPublic);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.isPublic == this.isPublic);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isPublic;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isPublic = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isPublic = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isPublic,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isPublic != null) 'is_public': isPublic,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isPublic,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isPublic: $isPublic')
          ..write(')'))
        .toString();
  }
}

class $BookTagsTable extends BookTags with TableInfo<$BookTagsTable, BookTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, tagId};
  @override
  BookTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookTag(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $BookTagsTable createAlias(String alias) {
    return $BookTagsTable(attachedDatabase, alias);
  }
}

class BookTag extends DataClass implements Insertable<BookTag> {
  final int bookId;
  final int tagId;
  const BookTag({required this.bookId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<int>(bookId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  BookTagsCompanion toCompanion(bool nullToAbsent) {
    return BookTagsCompanion(bookId: Value(bookId), tagId: Value(tagId));
  }

  factory BookTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookTag(
      bookId: serializer.fromJson<int>(json['bookId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<int>(bookId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  BookTag copyWith({int? bookId, int? tagId}) =>
      BookTag(bookId: bookId ?? this.bookId, tagId: tagId ?? this.tagId);
  BookTag copyWithCompanion(BookTagsCompanion data) {
    return BookTag(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookTag(')
          ..write('bookId: $bookId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookTag &&
          other.bookId == this.bookId &&
          other.tagId == this.tagId);
}

class BookTagsCompanion extends UpdateCompanion<BookTag> {
  final Value<int> bookId;
  final Value<int> tagId;
  final Value<int> rowid;
  const BookTagsCompanion({
    this.bookId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookTagsCompanion.insert({
    required int bookId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       tagId = Value(tagId);
  static Insertable<BookTag> custom({
    Expression<int>? bookId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookTagsCompanion copyWith({
    Value<int>? bookId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return BookTagsCompanion(
      bookId: bookId ?? this.bookId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookTagsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingLogsTable extends ReadingLogs
    with TableInfo<$ReadingLogsTable, ReadingLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _loggedOnMeta = const VerificationMeta(
    'loggedOn',
  );
  @override
  late final GeneratedColumn<DateTime> loggedOn = GeneratedColumn<DateTime>(
    'logged_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bookId, loggedOn, page, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('logged_on')) {
      context.handle(
        _loggedOnMeta,
        loggedOn.isAcceptableOrUnknown(data['logged_on']!, _loggedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedOnMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      loggedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_on'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $ReadingLogsTable createAlias(String alias) {
    return $ReadingLogsTable(attachedDatabase, alias);
  }
}

class ReadingLog extends DataClass implements Insertable<ReadingLog> {
  final int id;
  final int bookId;
  final DateTime loggedOn;
  final int page;
  final String? note;
  const ReadingLog({
    required this.id,
    required this.bookId,
    required this.loggedOn,
    required this.page,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['logged_on'] = Variable<DateTime>(loggedOn);
    map['page'] = Variable<int>(page);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ReadingLogsCompanion toCompanion(bool nullToAbsent) {
    return ReadingLogsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      loggedOn: Value(loggedOn),
      page: Value(page),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ReadingLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingLog(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      loggedOn: serializer.fromJson<DateTime>(json['loggedOn']),
      page: serializer.fromJson<int>(json['page']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'loggedOn': serializer.toJson<DateTime>(loggedOn),
      'page': serializer.toJson<int>(page),
      'note': serializer.toJson<String?>(note),
    };
  }

  ReadingLog copyWith({
    int? id,
    int? bookId,
    DateTime? loggedOn,
    int? page,
    Value<String?> note = const Value.absent(),
  }) => ReadingLog(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    loggedOn: loggedOn ?? this.loggedOn,
    page: page ?? this.page,
    note: note.present ? note.value : this.note,
  );
  ReadingLog copyWithCompanion(ReadingLogsCompanion data) {
    return ReadingLog(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      loggedOn: data.loggedOn.present ? data.loggedOn.value : this.loggedOn,
      page: data.page.present ? data.page.value : this.page,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingLog(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('page: $page, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, loggedOn, page, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingLog &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.loggedOn == this.loggedOn &&
          other.page == this.page &&
          other.note == this.note);
}

class ReadingLogsCompanion extends UpdateCompanion<ReadingLog> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<DateTime> loggedOn;
  final Value<int> page;
  final Value<String?> note;
  const ReadingLogsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.loggedOn = const Value.absent(),
    this.page = const Value.absent(),
    this.note = const Value.absent(),
  });
  ReadingLogsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required DateTime loggedOn,
    required int page,
    this.note = const Value.absent(),
  }) : bookId = Value(bookId),
       loggedOn = Value(loggedOn),
       page = Value(page);
  static Insertable<ReadingLog> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<DateTime>? loggedOn,
    Expression<int>? page,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (loggedOn != null) 'logged_on': loggedOn,
      if (page != null) 'page': page,
      if (note != null) 'note': note,
    });
  }

  ReadingLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<DateTime>? loggedOn,
    Value<int>? page,
    Value<String?>? note,
  }) {
    return ReadingLogsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      loggedOn: loggedOn ?? this.loggedOn,
      page: page ?? this.page,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (loggedOn.present) {
      map['logged_on'] = Variable<DateTime>(loggedOn.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingLogsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('page: $page, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $LookupCacheEntriesTable extends LookupCacheEntries
    with TableInfo<$LookupCacheEntriesTable, LookupCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LookupCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
    'isbn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [isbn, payload, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lookup_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LookupCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('isbn')) {
      context.handle(
        _isbnMeta,
        isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta),
      );
    } else if (isInserting) {
      context.missing(_isbnMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {isbn};
  @override
  LookupCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LookupCacheEntry(
      isbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $LookupCacheEntriesTable createAlias(String alias) {
    return $LookupCacheEntriesTable(attachedDatabase, alias);
  }
}

class LookupCacheEntry extends DataClass
    implements Insertable<LookupCacheEntry> {
  final String isbn;
  final String payload;
  final DateTime fetchedAt;
  const LookupCacheEntry({
    required this.isbn,
    required this.payload,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['isbn'] = Variable<String>(isbn);
    map['payload'] = Variable<String>(payload);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  LookupCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return LookupCacheEntriesCompanion(
      isbn: Value(isbn),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory LookupCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LookupCacheEntry(
      isbn: serializer.fromJson<String>(json['isbn']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isbn': serializer.toJson<String>(isbn),
      'payload': serializer.toJson<String>(payload),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  LookupCacheEntry copyWith({
    String? isbn,
    String? payload,
    DateTime? fetchedAt,
  }) => LookupCacheEntry(
    isbn: isbn ?? this.isbn,
    payload: payload ?? this.payload,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  LookupCacheEntry copyWithCompanion(LookupCacheEntriesCompanion data) {
    return LookupCacheEntry(
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LookupCacheEntry(')
          ..write('isbn: $isbn, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(isbn, payload, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LookupCacheEntry &&
          other.isbn == this.isbn &&
          other.payload == this.payload &&
          other.fetchedAt == this.fetchedAt);
}

class LookupCacheEntriesCompanion extends UpdateCompanion<LookupCacheEntry> {
  final Value<String> isbn;
  final Value<String> payload;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const LookupCacheEntriesCompanion({
    this.isbn = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LookupCacheEntriesCompanion.insert({
    required String isbn,
    required String payload,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : isbn = Value(isbn),
       payload = Value(payload),
       fetchedAt = Value(fetchedAt);
  static Insertable<LookupCacheEntry> custom({
    Expression<String>? isbn,
    Expression<String>? payload,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isbn != null) 'isbn': isbn,
      if (payload != null) 'payload': payload,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LookupCacheEntriesCompanion copyWith({
    Value<String>? isbn,
    Value<String>? payload,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return LookupCacheEntriesCompanion(
      isbn: isbn ?? this.isbn,
      payload: payload ?? this.payload,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LookupCacheEntriesCompanion(')
          ..write('isbn: $isbn, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BatchQueueEntriesTable extends BatchQueueEntries
    with TableInfo<$BatchQueueEntriesTable, BatchQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [uid, payload, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batch_queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<BatchQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  BatchQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatchQueueEntry(
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BatchQueueEntriesTable createAlias(String alias) {
    return $BatchQueueEntriesTable(attachedDatabase, alias);
  }
}

class BatchQueueEntry extends DataClass implements Insertable<BatchQueueEntry> {
  final String uid;
  final String payload;
  final DateTime createdAt;
  const BatchQueueEntry({
    required this.uid,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BatchQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return BatchQueueEntriesCompanion(
      uid: Value(uid),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory BatchQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatchQueueEntry(
      uid: serializer.fromJson<String>(json['uid']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BatchQueueEntry copyWith({
    String? uid,
    String? payload,
    DateTime? createdAt,
  }) => BatchQueueEntry(
    uid: uid ?? this.uid,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  BatchQueueEntry copyWithCompanion(BatchQueueEntriesCompanion data) {
    return BatchQueueEntry(
      uid: data.uid.present ? data.uid.value : this.uid,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatchQueueEntry(')
          ..write('uid: $uid, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uid, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatchQueueEntry &&
          other.uid == this.uid &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class BatchQueueEntriesCompanion extends UpdateCompanion<BatchQueueEntry> {
  final Value<String> uid;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BatchQueueEntriesCompanion({
    this.uid = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchQueueEntriesCompanion.insert({
    required String uid,
    required String payload,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : uid = Value(uid),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<BatchQueueEntry> custom({
    Expression<String>? uid,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchQueueEntriesCompanion copyWith({
    Value<String>? uid,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BatchQueueEntriesCompanion(
      uid: uid ?? this.uid,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchQueueEntriesCompanion(')
          ..write('uid: $uid, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $BookTagsTable bookTags = $BookTagsTable(this);
  late final $ReadingLogsTable readingLogs = $ReadingLogsTable(this);
  late final $LookupCacheEntriesTable lookupCacheEntries =
      $LookupCacheEntriesTable(this);
  late final $BatchQueueEntriesTable batchQueueEntries =
      $BatchQueueEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    books,
    tags,
    bookTags,
    readingLogs,
    lookupCacheEntries,
    batchQueueEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reading_logs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  required String uid,
  Value<String?> username,
  Value<String?> displayName,
  Value<String?> avatarUrl,
  Value<bool> isMe,
  Value<DateTime> createdAt,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String> uid,
  Value<String?> username,
  Value<String?> displayName,
  Value<String?> avatarUrl,
  Value<bool> isMe,
  Value<DateTime> createdAt,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BooksTable, List<Book>> _booksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.books,
    aliasName: 'users__id__books__owner_id',
  );

  $$BooksTableProcessedTableManager get booksRefs {
    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_booksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> booksRefs(
    Expression<bool> Function($$BooksTableFilterComposer f) f,
  ) {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<bool> get isMe =>
      $composableBuilder(column: $table.isMe, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> booksRefs<T extends Object>(
    Expression<T> Function($$BooksTableAnnotationComposer a) f,
  ) {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({bool booksRefs})
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<bool> isMe = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                uid: uid,
                username: username,
                displayName: displayName,
                avatarUrl: avatarUrl,
                isMe: isMe,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uid,
                Value<String?> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<bool> isMe = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                uid: uid,
                username: username,
                displayName: displayName,
                avatarUrl: avatarUrl,
                isMe: isMe,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, User>(table),
                  $$UsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({booksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (booksRefs) db.books],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (booksRefs)
                    await $_getPrefetchedData<User, $UsersTable, Book>(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences._booksRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$UsersTableReferences(db, table, p0).booksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ownerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({bool booksRefs})
    >;
typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  Value<String?> internalId,
  required String title,
  required String author,
  Value<String?> originalTitle,
  Value<String?> isbn,
  Value<String?> shelfLocation,
  Value<String?> signatura,
  Value<String?> publisher,
  Value<int?> publicationYear,
  Value<String> language,
  Value<int?> pageCount,
  Value<String?> bindingType,
  Value<String?> secondaryContributors,
  Value<String> readingStatus,
  Value<double?> personalRating,
  Value<String?> privateNotes,
  Value<String?> physicalCondition,
  Value<bool> isWishlist,
  Value<String?> coverUrl,
  Value<String?> synopsis,
  Value<String?> uid,
  Value<int?> ownerId,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> ratingHalfStars,
  Value<String?> reviewText,
  Value<int> currentPage,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<DateTime> createdAt,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  Value<String?> internalId,
  Value<String> title,
  Value<String> author,
  Value<String?> originalTitle,
  Value<String?> isbn,
  Value<String?> shelfLocation,
  Value<String?> signatura,
  Value<String?> publisher,
  Value<int?> publicationYear,
  Value<String> language,
  Value<int?> pageCount,
  Value<String?> bindingType,
  Value<String?> secondaryContributors,
  Value<String> readingStatus,
  Value<double?> personalRating,
  Value<String?> privateNotes,
  Value<String?> physicalCondition,
  Value<bool> isWishlist,
  Value<String?> coverUrl,
  Value<String?> synopsis,
  Value<String?> uid,
  Value<int?> ownerId,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> ratingHalfStars,
  Value<String?> reviewText,
  Value<int> currentPage,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<DateTime> createdAt,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('books__owner_id__users__id');

  $$UsersTableProcessedTableManager? get ownerId {
    final $_column = $_itemColumn<int>('owner_id');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BookTagsTable, List<BookTag>> _bookTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.bookTags,
    aliasName: 'books__id__book_tags__book_id',
  );

  $$BookTagsTableProcessedTableManager get bookTagsRefs {
    final manager = $$BookTagsTableTableManager(
      $_db,
      $_db.bookTags,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingLogsTable, List<ReadingLog>>
  _readingLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingLogs,
    aliasName: 'books__id__reading_logs__book_id',
  );

  $$ReadingLogsTableProcessedTableManager get readingLogsRefs {
    final manager = $$ReadingLogsTableTableManager(
      $_db,
      $_db.readingLogs,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shelfLocation => $composableBuilder(
    column: $table.shelfLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signatura => $composableBuilder(
    column: $table.signatura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publicationYear => $composableBuilder(
    column: $table.publicationYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bindingType => $composableBuilder(
    column: $table.bindingType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryContributors => $composableBuilder(
    column: $table.secondaryContributors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readingStatus => $composableBuilder(
    column: $table.readingStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get personalRating => $composableBuilder(
    column: $table.personalRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privateNotes => $composableBuilder(
    column: $table.privateNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get physicalCondition => $composableBuilder(
    column: $table.physicalCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWishlist => $composableBuilder(
    column: $table.isWishlist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get synopsis => $composableBuilder(
    column: $table.synopsis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratingHalfStars => $composableBuilder(
    column: $table.ratingHalfStars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewText => $composableBuilder(
    column: $table.reviewText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get ownerId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> bookTagsRefs(
    Expression<bool> Function($$BookTagsTableFilterComposer f) f,
  ) {
    final $$BookTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableFilterComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingLogsRefs(
    Expression<bool> Function($$ReadingLogsTableFilterComposer f) f,
  ) {
    final $$ReadingLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingLogs,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingLogsTableFilterComposer(
            $db: $db,
            $table: $db.readingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shelfLocation => $composableBuilder(
    column: $table.shelfLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signatura => $composableBuilder(
    column: $table.signatura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publicationYear => $composableBuilder(
    column: $table.publicationYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bindingType => $composableBuilder(
    column: $table.bindingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryContributors => $composableBuilder(
    column: $table.secondaryContributors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readingStatus => $composableBuilder(
    column: $table.readingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get personalRating => $composableBuilder(
    column: $table.personalRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privateNotes => $composableBuilder(
    column: $table.privateNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get physicalCondition => $composableBuilder(
    column: $table.physicalCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWishlist => $composableBuilder(
    column: $table.isWishlist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get synopsis => $composableBuilder(
    column: $table.synopsis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratingHalfStars => $composableBuilder(
    column: $table.ratingHalfStars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewText => $composableBuilder(
    column: $table.reviewText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get ownerId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get shelfLocation => $composableBuilder(
    column: $table.shelfLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get signatura =>
      $composableBuilder(column: $table.signatura, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<int> get publicationYear => $composableBuilder(
    column: $table.publicationYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get bindingType => $composableBuilder(
    column: $table.bindingType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryContributors => $composableBuilder(
    column: $table.secondaryContributors,
    builder: (column) => column,
  );

  GeneratedColumn<String> get readingStatus => $composableBuilder(
    column: $table.readingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get personalRating => $composableBuilder(
    column: $table.personalRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privateNotes => $composableBuilder(
    column: $table.privateNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get physicalCondition => $composableBuilder(
    column: $table.physicalCondition,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isWishlist => $composableBuilder(
    column: $table.isWishlist,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get synopsis =>
      $composableBuilder(column: $table.synopsis, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get ratingHalfStars => $composableBuilder(
    column: $table.ratingHalfStars,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewText => $composableBuilder(
    column: $table.reviewText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get ownerId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> bookTagsRefs<T extends Object>(
    Expression<T> Function($$BookTagsTableAnnotationComposer a) f,
  ) {
    final $$BookTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingLogsRefs<T extends Object>(
    Expression<T> Function($$ReadingLogsTableAnnotationComposer a) f,
  ) {
    final $$ReadingLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingLogs,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.readingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({
            bool ownerId,
            bool bookTagsRefs,
            bool readingLogsRefs,
          })
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> internalId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String?> originalTitle = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> shelfLocation = const Value.absent(),
                Value<String?> signatura = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<int?> publicationYear = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> bindingType = const Value.absent(),
                Value<String?> secondaryContributors = const Value.absent(),
                Value<String> readingStatus = const Value.absent(),
                Value<double?> personalRating = const Value.absent(),
                Value<String?> privateNotes = const Value.absent(),
                Value<String?> physicalCondition = const Value.absent(),
                Value<bool> isWishlist = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> synopsis = const Value.absent(),
                Value<String?> uid = const Value.absent(),
                Value<int?> ownerId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> ratingHalfStars = const Value.absent(),
                Value<String?> reviewText = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                internalId: internalId,
                title: title,
                author: author,
                originalTitle: originalTitle,
                isbn: isbn,
                shelfLocation: shelfLocation,
                signatura: signatura,
                publisher: publisher,
                publicationYear: publicationYear,
                language: language,
                pageCount: pageCount,
                bindingType: bindingType,
                secondaryContributors: secondaryContributors,
                readingStatus: readingStatus,
                personalRating: personalRating,
                privateNotes: privateNotes,
                physicalCondition: physicalCondition,
                isWishlist: isWishlist,
                coverUrl: coverUrl,
                synopsis: synopsis,
                uid: uid,
                ownerId: ownerId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                ratingHalfStars: ratingHalfStars,
                reviewText: reviewText,
                currentPage: currentPage,
                startedAt: startedAt,
                finishedAt: finishedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> internalId = const Value.absent(),
                required String title,
                required String author,
                Value<String?> originalTitle = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> shelfLocation = const Value.absent(),
                Value<String?> signatura = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<int?> publicationYear = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> bindingType = const Value.absent(),
                Value<String?> secondaryContributors = const Value.absent(),
                Value<String> readingStatus = const Value.absent(),
                Value<double?> personalRating = const Value.absent(),
                Value<String?> privateNotes = const Value.absent(),
                Value<String?> physicalCondition = const Value.absent(),
                Value<bool> isWishlist = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> synopsis = const Value.absent(),
                Value<String?> uid = const Value.absent(),
                Value<int?> ownerId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> ratingHalfStars = const Value.absent(),
                Value<String?> reviewText = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                internalId: internalId,
                title: title,
                author: author,
                originalTitle: originalTitle,
                isbn: isbn,
                shelfLocation: shelfLocation,
                signatura: signatura,
                publisher: publisher,
                publicationYear: publicationYear,
                language: language,
                pageCount: pageCount,
                bindingType: bindingType,
                secondaryContributors: secondaryContributors,
                readingStatus: readingStatus,
                personalRating: personalRating,
                privateNotes: privateNotes,
                physicalCondition: physicalCondition,
                isWishlist: isWishlist,
                coverUrl: coverUrl,
                synopsis: synopsis,
                uid: uid,
                ownerId: ownerId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                ratingHalfStars: ratingHalfStars,
                reviewText: reviewText,
                currentPage: currentPage,
                startedAt: startedAt,
                finishedAt: finishedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BooksTable, Book>(table),
                  $$BooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ownerId = false,
                bookTagsRefs = false,
                readingLogsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (bookTagsRefs) db.bookTags,
                    if (readingLogsRefs) db.readingLogs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (ownerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.ownerId,
                            referencedTable: $$BooksTableReferences
                                ._ownerIdTable(db),
                            referencedColumn: $$BooksTableReferences
                                ._ownerIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (bookTagsRefs)
                        await $_getPrefetchedData<Book, $BooksTable, BookTag>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readingLogsRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          ReadingLog
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readingLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readingLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({
        bool ownerId,
        bool bookTagsRefs,
        bool readingLogsRefs,
      })
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String name,
  Value<bool> isPublic,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<bool> isPublic,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookTagsTable, List<BookTag>> _bookTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.bookTags,
    aliasName: 'tags__id__book_tags__tag_id',
  );

  $$BookTagsTableProcessedTableManager get bookTagsRefs {
    final manager = $$BookTagsTableTableManager(
      $_db,
      $_db.bookTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookTagsRefs(
    Expression<bool> Function($$BookTagsTableFilterComposer f) f,
  ) {
    final $$BookTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableFilterComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  Expression<T> bookTagsRefs<T extends Object>(
    Expression<T> Function($$BookTagsTableAnnotationComposer a) f,
  ) {
    final $$BookTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool bookTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isPublic = const Value.absent(),
          }) => TagsCompanion(id: id, name: name, isPublic: isPublic),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<bool> isPublic = const Value.absent(),
          }) => TagsCompanion.insert(id: id, name: name, isPublic: isPublic),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, Tag>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookTagsRefs) db.bookTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, BookTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._bookTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).bookTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool bookTagsRefs})
    >;
typedef $$BookTagsTableCreateCompanionBuilder = BookTagsCompanion Function({
  required int bookId,
  required int tagId,
  Value<int> rowid,
});
typedef $$BookTagsTableUpdateCompanionBuilder = BookTagsCompanion Function({
  Value<int> bookId,
  Value<int> tagId,
  Value<int> rowid,
});

final class $$BookTagsTableReferences
    extends BaseReferences<_$AppDatabase, $BookTagsTable, BookTag> {
  $$BookTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('book_tags__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('book_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookTagsTableFilterComposer
    extends Composer<_$AppDatabase, $BookTagsTable> {
  $$BookTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookTagsTable> {
  $$BookTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookTagsTable> {
  $$BookTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookTagsTable,
          BookTag,
          $$BookTagsTableFilterComposer,
          $$BookTagsTableOrderingComposer,
          $$BookTagsTableAnnotationComposer,
          $$BookTagsTableCreateCompanionBuilder,
          $$BookTagsTableUpdateCompanionBuilder,
          (BookTag, $$BookTagsTableReferences),
          BookTag,
          PrefetchHooks Function({bool bookId, bool tagId})
        > {
  $$BookTagsTableTableManager(_$AppDatabase db, $BookTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> bookId = const Value.absent(),
            Value<int> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => BookTagsCompanion(bookId: bookId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required int bookId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => BookTagsCompanion.insert(
                bookId: bookId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookTagsTable, BookTag>(table),
                  $$BookTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$BookTagsTableReferences._bookIdTable(
                          db,
                        ),
                        referencedColumn: $$BookTagsTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$BookTagsTableReferences._tagIdTable(
                          db,
                        ),
                        referencedColumn: $$BookTagsTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookTagsTable,
      BookTag,
      $$BookTagsTableFilterComposer,
      $$BookTagsTableOrderingComposer,
      $$BookTagsTableAnnotationComposer,
      $$BookTagsTableCreateCompanionBuilder,
      $$BookTagsTableUpdateCompanionBuilder,
      (BookTag, $$BookTagsTableReferences),
      BookTag,
      PrefetchHooks Function({bool bookId, bool tagId})
    >;
typedef $$ReadingLogsTableCreateCompanionBuilder =
    ReadingLogsCompanion Function({
      Value<int> id,
      required int bookId,
      required DateTime loggedOn,
      required int page,
      Value<String?> note,
    });
typedef $$ReadingLogsTableUpdateCompanionBuilder =
    ReadingLogsCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<DateTime> loggedOn,
      Value<int> page,
      Value<String?> note,
    });

final class $$ReadingLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingLogsTable, ReadingLog> {
  $$ReadingLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('reading_logs__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingLogsTable> {
  $$ReadingLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedOn => $composableBuilder(
    column: $table.loggedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingLogsTable> {
  $$ReadingLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedOn => $composableBuilder(
    column: $table.loggedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingLogsTable> {
  $$ReadingLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedOn =>
      $composableBuilder(column: $table.loggedOn, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingLogsTable,
          ReadingLog,
          $$ReadingLogsTableFilterComposer,
          $$ReadingLogsTableOrderingComposer,
          $$ReadingLogsTableAnnotationComposer,
          $$ReadingLogsTableCreateCompanionBuilder,
          $$ReadingLogsTableUpdateCompanionBuilder,
          (ReadingLog, $$ReadingLogsTableReferences),
          ReadingLog,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReadingLogsTableTableManager(_$AppDatabase db, $ReadingLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<DateTime> loggedOn = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => ReadingLogsCompanion(
                id: id,
                bookId: bookId,
                loggedOn: loggedOn,
                page: page,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required DateTime loggedOn,
                required int page,
                Value<String?> note = const Value.absent(),
              }) => ReadingLogsCompanion.insert(
                id: id,
                bookId: bookId,
                loggedOn: loggedOn,
                page: page,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingLogsTable, ReadingLog>(table),
                  $$ReadingLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$ReadingLogsTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$ReadingLogsTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingLogsTable,
      ReadingLog,
      $$ReadingLogsTableFilterComposer,
      $$ReadingLogsTableOrderingComposer,
      $$ReadingLogsTableAnnotationComposer,
      $$ReadingLogsTableCreateCompanionBuilder,
      $$ReadingLogsTableUpdateCompanionBuilder,
      (ReadingLog, $$ReadingLogsTableReferences),
      ReadingLog,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$LookupCacheEntriesTableCreateCompanionBuilder =
    LookupCacheEntriesCompanion Function({
      required String isbn,
      required String payload,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$LookupCacheEntriesTableUpdateCompanionBuilder =
    LookupCacheEntriesCompanion Function({
      Value<String> isbn,
      Value<String> payload,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$LookupCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LookupCacheEntriesTable> {
  $$LookupCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LookupCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LookupCacheEntriesTable> {
  $$LookupCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LookupCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LookupCacheEntriesTable> {
  $$LookupCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$LookupCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LookupCacheEntriesTable,
          LookupCacheEntry,
          $$LookupCacheEntriesTableFilterComposer,
          $$LookupCacheEntriesTableOrderingComposer,
          $$LookupCacheEntriesTableAnnotationComposer,
          $$LookupCacheEntriesTableCreateCompanionBuilder,
          $$LookupCacheEntriesTableUpdateCompanionBuilder,
          (
            LookupCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $LookupCacheEntriesTable,
              LookupCacheEntry
            >,
          ),
          LookupCacheEntry,
          PrefetchHooks Function()
        > {
  $$LookupCacheEntriesTableTableManager(
    _$AppDatabase db,
    $LookupCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LookupCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LookupCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LookupCacheEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> isbn = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LookupCacheEntriesCompanion(
                isbn: isbn,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String isbn,
                required String payload,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => LookupCacheEntriesCompanion.insert(
                isbn: isbn,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LookupCacheEntriesTable, LookupCacheEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LookupCacheEntriesTable,
                    LookupCacheEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LookupCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LookupCacheEntriesTable,
      LookupCacheEntry,
      $$LookupCacheEntriesTableFilterComposer,
      $$LookupCacheEntriesTableOrderingComposer,
      $$LookupCacheEntriesTableAnnotationComposer,
      $$LookupCacheEntriesTableCreateCompanionBuilder,
      $$LookupCacheEntriesTableUpdateCompanionBuilder,
      (
        LookupCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $LookupCacheEntriesTable,
          LookupCacheEntry
        >,
      ),
      LookupCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$BatchQueueEntriesTableCreateCompanionBuilder =
    BatchQueueEntriesCompanion Function({
      required String uid,
      required String payload,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BatchQueueEntriesTableUpdateCompanionBuilder =
    BatchQueueEntriesCompanion Function({
      Value<String> uid,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BatchQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $BatchQueueEntriesTable> {
  $$BatchQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BatchQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchQueueEntriesTable> {
  $$BatchQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BatchQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchQueueEntriesTable> {
  $$BatchQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BatchQueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchQueueEntriesTable,
          BatchQueueEntry,
          $$BatchQueueEntriesTableFilterComposer,
          $$BatchQueueEntriesTableOrderingComposer,
          $$BatchQueueEntriesTableAnnotationComposer,
          $$BatchQueueEntriesTableCreateCompanionBuilder,
          $$BatchQueueEntriesTableUpdateCompanionBuilder,
          (
            BatchQueueEntry,
            BaseReferences<
              _$AppDatabase,
              $BatchQueueEntriesTable,
              BatchQueueEntry
            >,
          ),
          BatchQueueEntry,
          PrefetchHooks Function()
        > {
  $$BatchQueueEntriesTableTableManager(
    _$AppDatabase db,
    $BatchQueueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchQueueEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uid = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchQueueEntriesCompanion(
                uid: uid,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uid,
                required String payload,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BatchQueueEntriesCompanion.insert(
                uid: uid,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BatchQueueEntriesTable, BatchQueueEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BatchQueueEntriesTable,
                    BatchQueueEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BatchQueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchQueueEntriesTable,
      BatchQueueEntry,
      $$BatchQueueEntriesTableFilterComposer,
      $$BatchQueueEntriesTableOrderingComposer,
      $$BatchQueueEntriesTableAnnotationComposer,
      $$BatchQueueEntriesTableCreateCompanionBuilder,
      $$BatchQueueEntriesTableUpdateCompanionBuilder,
      (
        BatchQueueEntry,
        BaseReferences<_$AppDatabase, $BatchQueueEntriesTable, BatchQueueEntry>,
      ),
      BatchQueueEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$BookTagsTableTableManager get bookTags =>
      $$BookTagsTableTableManager(_db, _db.bookTags);
  $$ReadingLogsTableTableManager get readingLogs =>
      $$ReadingLogsTableTableManager(_db, _db.readingLogs);
  $$LookupCacheEntriesTableTableManager get lookupCacheEntries =>
      $$LookupCacheEntriesTableTableManager(_db, _db.lookupCacheEntries);
  $$BatchQueueEntriesTableTableManager get batchQueueEntries =>
      $$BatchQueueEntriesTableTableManager(_db, _db.batchQueueEntries);
}
