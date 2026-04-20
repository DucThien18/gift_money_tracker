// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_record_isar_model.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetGuestRecordIsarModelCollection on Isar {
  IsarCollection<int, GuestRecordIsarModel> get guestRecordIsarModels =>
      this.collection();
}

const GuestRecordIsarModelSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'GuestRecordIsarModel',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'eventListId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'fullName',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'note',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'amount',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'isDebtPaid',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'createdAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'updatedAt',
        type: IsarType.dateTime,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'eventListId',
        properties: [
          "eventListId",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'fullName',
        properties: [
          "fullName",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'isDebtPaid',
        properties: [
          "isDebtPaid",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, GuestRecordIsarModel>(
    serialize: serializeGuestRecordIsarModel,
    deserialize: deserializeGuestRecordIsarModel,
    deserializeProperty: deserializeGuestRecordIsarModelProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeGuestRecordIsarModel(
    IsarWriter writer, GuestRecordIsarModel object) {
  IsarCore.writeLong(writer, 1, object.eventListId);
  IsarCore.writeString(writer, 2, object.fullName);
  IsarCore.writeString(writer, 3, object.note);
  IsarCore.writeLong(writer, 4, object.amount);
  IsarCore.writeBool(writer, 5, object.isDebtPaid);
  IsarCore.writeLong(
      writer, 6, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(
      writer, 7, object.updatedAt.toUtc().microsecondsSinceEpoch);
  return object.id;
}

@isarProtected
GuestRecordIsarModel deserializeGuestRecordIsarModel(IsarReader reader) {
  final object = GuestRecordIsarModel();
  object.id = IsarCore.readId(reader);
  object.eventListId = IsarCore.readLong(reader, 1);
  object.fullName = IsarCore.readString(reader, 2) ?? '';
  object.note = IsarCore.readString(reader, 3) ?? '';
  object.amount = IsarCore.readLong(reader, 4);
  object.isDebtPaid = IsarCore.readBool(reader, 5);
  {
    final value = IsarCore.readLong(reader, 6);
    if (value == -9223372036854775808) {
      object.createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      object.updatedAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.updatedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  return object;
}

@isarProtected
dynamic deserializeGuestRecordIsarModelProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readLong(reader, 1);
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readLong(reader, 4);
    case 5:
      return IsarCore.readBool(reader, 5);
    case 6:
      {
        final value = IsarCore.readLong(reader, 6);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _GuestRecordIsarModelUpdate {
  bool call({
    required int id,
    int? eventListId,
    String? fullName,
    String? note,
    int? amount,
    bool? isDebtPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class _GuestRecordIsarModelUpdateImpl implements _GuestRecordIsarModelUpdate {
  const _GuestRecordIsarModelUpdateImpl(this.collection);

  final IsarCollection<int, GuestRecordIsarModel> collection;

  @override
  bool call({
    required int id,
    Object? eventListId = ignore,
    Object? fullName = ignore,
    Object? note = ignore,
    Object? amount = ignore,
    Object? isDebtPaid = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (eventListId != ignore) 1: eventListId as int?,
          if (fullName != ignore) 2: fullName as String?,
          if (note != ignore) 3: note as String?,
          if (amount != ignore) 4: amount as int?,
          if (isDebtPaid != ignore) 5: isDebtPaid as bool?,
          if (createdAt != ignore) 6: createdAt as DateTime?,
          if (updatedAt != ignore) 7: updatedAt as DateTime?,
        }) >
        0;
  }
}

sealed class _GuestRecordIsarModelUpdateAll {
  int call({
    required List<int> id,
    int? eventListId,
    String? fullName,
    String? note,
    int? amount,
    bool? isDebtPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class _GuestRecordIsarModelUpdateAllImpl
    implements _GuestRecordIsarModelUpdateAll {
  const _GuestRecordIsarModelUpdateAllImpl(this.collection);

  final IsarCollection<int, GuestRecordIsarModel> collection;

  @override
  int call({
    required List<int> id,
    Object? eventListId = ignore,
    Object? fullName = ignore,
    Object? note = ignore,
    Object? amount = ignore,
    Object? isDebtPaid = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
  }) {
    return collection.updateProperties(id, {
      if (eventListId != ignore) 1: eventListId as int?,
      if (fullName != ignore) 2: fullName as String?,
      if (note != ignore) 3: note as String?,
      if (amount != ignore) 4: amount as int?,
      if (isDebtPaid != ignore) 5: isDebtPaid as bool?,
      if (createdAt != ignore) 6: createdAt as DateTime?,
      if (updatedAt != ignore) 7: updatedAt as DateTime?,
    });
  }
}

extension GuestRecordIsarModelUpdate
    on IsarCollection<int, GuestRecordIsarModel> {
  _GuestRecordIsarModelUpdate get update =>
      _GuestRecordIsarModelUpdateImpl(this);

  _GuestRecordIsarModelUpdateAll get updateAll =>
      _GuestRecordIsarModelUpdateAllImpl(this);
}

sealed class _GuestRecordIsarModelQueryUpdate {
  int call({
    int? eventListId,
    String? fullName,
    String? note,
    int? amount,
    bool? isDebtPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class _GuestRecordIsarModelQueryUpdateImpl
    implements _GuestRecordIsarModelQueryUpdate {
  const _GuestRecordIsarModelQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<GuestRecordIsarModel> query;
  final int? limit;

  @override
  int call({
    Object? eventListId = ignore,
    Object? fullName = ignore,
    Object? note = ignore,
    Object? amount = ignore,
    Object? isDebtPaid = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (eventListId != ignore) 1: eventListId as int?,
      if (fullName != ignore) 2: fullName as String?,
      if (note != ignore) 3: note as String?,
      if (amount != ignore) 4: amount as int?,
      if (isDebtPaid != ignore) 5: isDebtPaid as bool?,
      if (createdAt != ignore) 6: createdAt as DateTime?,
      if (updatedAt != ignore) 7: updatedAt as DateTime?,
    });
  }
}

extension GuestRecordIsarModelQueryUpdate on IsarQuery<GuestRecordIsarModel> {
  _GuestRecordIsarModelQueryUpdate get updateFirst =>
      _GuestRecordIsarModelQueryUpdateImpl(this, limit: 1);

  _GuestRecordIsarModelQueryUpdate get updateAll =>
      _GuestRecordIsarModelQueryUpdateImpl(this);
}

class _GuestRecordIsarModelQueryBuilderUpdateImpl
    implements _GuestRecordIsarModelQueryUpdate {
  const _GuestRecordIsarModelQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QOperations>
      query;
  final int? limit;

  @override
  int call({
    Object? eventListId = ignore,
    Object? fullName = ignore,
    Object? note = ignore,
    Object? amount = ignore,
    Object? isDebtPaid = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (eventListId != ignore) 1: eventListId as int?,
        if (fullName != ignore) 2: fullName as String?,
        if (note != ignore) 3: note as String?,
        if (amount != ignore) 4: amount as int?,
        if (isDebtPaid != ignore) 5: isDebtPaid as bool?,
        if (createdAt != ignore) 6: createdAt as DateTime?,
        if (updatedAt != ignore) 7: updatedAt as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension GuestRecordIsarModelQueryBuilderUpdate
    on QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QOperations> {
  _GuestRecordIsarModelQueryUpdate get updateFirst =>
      _GuestRecordIsarModelQueryBuilderUpdateImpl(this, limit: 1);

  _GuestRecordIsarModelQueryUpdate get updateAll =>
      _GuestRecordIsarModelQueryBuilderUpdateImpl(this);
}

extension GuestRecordIsarModelQueryFilter on QueryBuilder<GuestRecordIsarModel,
    GuestRecordIsarModel, QFilterCondition> {
  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> eventListIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> eventListIdGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> eventListIdGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> eventListIdLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> eventListIdLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> eventListIdBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> fullNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> fullNameGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> fullNameGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> fullNameLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> fullNameLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> fullNameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
          QAfterFilterCondition>
      fullNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
          QAfterFilterCondition>
      fullNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> noteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> noteGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> noteGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> noteLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> noteLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> noteBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
          QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
          QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> amountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> amountGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> amountGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> amountLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> amountLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> amountBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> isDebtPaidEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> createdAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> createdAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> updatedAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> updatedAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension GuestRecordIsarModelQueryObject on QueryBuilder<GuestRecordIsarModel,
    GuestRecordIsarModel, QFilterCondition> {}

extension GuestRecordIsarModelQuerySortBy
    on QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QSortBy> {
  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByEventListId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByEventListIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByFullName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByFullNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByNote({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByNoteDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByIsDebtPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByIsDebtPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }
}

extension GuestRecordIsarModelQuerySortThenBy
    on QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QSortThenBy> {
  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByEventListId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByEventListIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByFullName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByFullNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByNote({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByNoteDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByIsDebtPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByIsDebtPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }
}

extension GuestRecordIsarModelQueryWhereDistinct
    on QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QDistinct> {
  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterDistinct>
      distinctByEventListId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterDistinct>
      distinctByFullName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterDistinct>
      distinctByNote({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterDistinct>
      distinctByIsDebtPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QAfterDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }
}

extension GuestRecordIsarModelQueryProperty1
    on QueryBuilder<GuestRecordIsarModel, GuestRecordIsarModel, QProperty> {
  QueryBuilder<GuestRecordIsarModel, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<GuestRecordIsarModel, int, QAfterProperty>
      eventListIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<GuestRecordIsarModel, String, QAfterProperty>
      fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<GuestRecordIsarModel, String, QAfterProperty> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<GuestRecordIsarModel, int, QAfterProperty> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<GuestRecordIsarModel, bool, QAfterProperty>
      isDebtPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<GuestRecordIsarModel, DateTime, QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<GuestRecordIsarModel, DateTime, QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }
}

extension GuestRecordIsarModelQueryProperty2<R>
    on QueryBuilder<GuestRecordIsarModel, R, QAfterProperty> {
  QueryBuilder<GuestRecordIsarModel, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R, int), QAfterProperty>
      eventListIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R, String), QAfterProperty>
      fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R, String), QAfterProperty>
      noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R, int), QAfterProperty>
      amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R, bool), QAfterProperty>
      isDebtPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R, DateTime), QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R, DateTime), QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }
}

extension GuestRecordIsarModelQueryProperty3<R1, R2>
    on QueryBuilder<GuestRecordIsarModel, (R1, R2), QAfterProperty> {
  QueryBuilder<GuestRecordIsarModel, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R1, R2, int), QOperations>
      eventListIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R1, R2, String), QOperations>
      fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R1, R2, String), QOperations>
      noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R1, R2, int), QOperations>
      amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R1, R2, bool), QOperations>
      isDebtPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<GuestRecordIsarModel, (R1, R2, DateTime), QOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }
}
