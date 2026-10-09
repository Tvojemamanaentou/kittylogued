// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [books];
}

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
  Value<DateTime> createdAt,
});

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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
          (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
          Book,
          PrefetchHooks Function()
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
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BooksTable, Book>(table),
                  BaseReferences<_$AppDatabase, $BooksTable, Book>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
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
      (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
      Book,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
}
