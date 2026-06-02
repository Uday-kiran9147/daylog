// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTaskEntryCollection on Isar {
  IsarCollection<TaskEntry> get taskEntrys => this.collection();
}

const TaskEntrySchema = CollectionSchema(
  name: r'TaskEntry',
  id: 7036290709079290800,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
    ),
    r'currentElapsedSeconds': PropertySchema(
      id: 1,
      name: r'currentElapsedSeconds',
      type: IsarType.long,
    ),
    r'dayKey': PropertySchema(
      id: 2,
      name: r'dayKey',
      type: IsarType.string,
    ),
    r'durationSeconds': PropertySchema(
      id: 3,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'formattedDuration': PropertySchema(
      id: 4,
      name: r'formattedDuration',
      type: IsarType.string,
    ),
    r'isPaused': PropertySchema(
      id: 5,
      name: r'isPaused',
      type: IsarType.bool,
    ),
    r'isRunning': PropertySchema(
      id: 6,
      name: r'isRunning',
      type: IsarType.bool,
    ),
    r'pauseDurationSeconds': PropertySchema(
      id: 7,
      name: r'pauseDurationSeconds',
      type: IsarType.long,
    ),
    r'pausedAt': PropertySchema(
      id: 8,
      name: r'pausedAt',
      type: IsarType.dateTime,
    ),
    r'startedAt': PropertySchema(
      id: 9,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'stoppedAt': PropertySchema(
      id: 10,
      name: r'stoppedAt',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(
      id: 11,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _taskEntryEstimateSize,
  serialize: _taskEntrySerialize,
  deserialize: _taskEntryDeserialize,
  deserializeProp: _taskEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'category': IndexSchema(
      id: -7560358558326323820,
      name: r'category',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'category',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'dayKey': IndexSchema(
      id: -3264092797330672150,
      name: r'dayKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dayKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _taskEntryGetId,
  getLinks: _taskEntryGetLinks,
  attach: _taskEntryAttach,
  version: '3.1.0+1',
);

int _taskEntryEstimateSize(
  TaskEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.dayKey.length * 3;
  bytesCount += 3 + object.formattedDuration.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _taskEntrySerialize(
  TaskEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category);
  writer.writeLong(offsets[1], object.currentElapsedSeconds);
  writer.writeString(offsets[2], object.dayKey);
  writer.writeLong(offsets[3], object.durationSeconds);
  writer.writeString(offsets[4], object.formattedDuration);
  writer.writeBool(offsets[5], object.isPaused);
  writer.writeBool(offsets[6], object.isRunning);
  writer.writeLong(offsets[7], object.pauseDurationSeconds);
  writer.writeDateTime(offsets[8], object.pausedAt);
  writer.writeDateTime(offsets[9], object.startedAt);
  writer.writeDateTime(offsets[10], object.stoppedAt);
  writer.writeString(offsets[11], object.title);
}

TaskEntry _taskEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TaskEntry();
  object.category = reader.readString(offsets[0]);
  object.durationSeconds = reader.readLong(offsets[3]);
  object.id = id;
  object.pauseDurationSeconds = reader.readLong(offsets[7]);
  object.pausedAt = reader.readDateTimeOrNull(offsets[8]);
  object.startedAt = reader.readDateTime(offsets[9]);
  object.stoppedAt = reader.readDateTimeOrNull(offsets[10]);
  object.title = reader.readString(offsets[11]);
  return object;
}

P _taskEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _taskEntryGetId(TaskEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _taskEntryGetLinks(TaskEntry object) {
  return [];
}

void _taskEntryAttach(IsarCollection<dynamic> col, Id id, TaskEntry object) {
  object.id = id;
}

extension TaskEntryQueryWhereSort
    on QueryBuilder<TaskEntry, TaskEntry, QWhere> {
  QueryBuilder<TaskEntry, TaskEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TaskEntryQueryWhere
    on QueryBuilder<TaskEntry, TaskEntry, QWhereClause> {
  QueryBuilder<TaskEntry, TaskEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterWhereClause> categoryEqualTo(
      String category) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'category',
        value: [category],
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterWhereClause> categoryNotEqualTo(
      String category) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'category',
              lower: [],
              upper: [category],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'category',
              lower: [category],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'category',
              lower: [category],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'category',
              lower: [],
              upper: [category],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterWhereClause> dayKeyEqualTo(
      String dayKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dayKey',
        value: [dayKey],
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterWhereClause> dayKeyNotEqualTo(
      String dayKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dayKey',
              lower: [],
              upper: [dayKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dayKey',
              lower: [dayKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dayKey',
              lower: [dayKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dayKey',
              lower: [],
              upper: [dayKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TaskEntryQueryFilter
    on QueryBuilder<TaskEntry, TaskEntry, QFilterCondition> {
  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> categoryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> categoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      currentElapsedSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentElapsedSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      currentElapsedSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentElapsedSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      currentElapsedSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentElapsedSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      currentElapsedSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentElapsedSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> dayKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> dayKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> dayKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> dayKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dayKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> dayKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> dayKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> dayKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> dayKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dayKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> dayKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dayKey',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> dayKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dayKey',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      durationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      durationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      durationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      durationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      formattedDurationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      formattedDurationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formattedDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      formattedDurationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formattedDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      formattedDurationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formattedDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      formattedDurationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formattedDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      formattedDurationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formattedDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      formattedDurationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formattedDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      formattedDurationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formattedDuration',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      formattedDurationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedDuration',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      formattedDurationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formattedDuration',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> isPausedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPaused',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> isRunningEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRunning',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      pauseDurationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pauseDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      pauseDurationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pauseDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      pauseDurationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pauseDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      pauseDurationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pauseDurationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> pausedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pausedAt',
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      pausedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pausedAt',
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> pausedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pausedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> pausedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pausedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> pausedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pausedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> pausedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pausedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> startedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      startedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> startedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> stoppedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stoppedAt',
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      stoppedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stoppedAt',
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> stoppedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stoppedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition>
      stoppedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stoppedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> stoppedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stoppedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> stoppedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stoppedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension TaskEntryQueryObject
    on QueryBuilder<TaskEntry, TaskEntry, QFilterCondition> {}

extension TaskEntryQueryLinks
    on QueryBuilder<TaskEntry, TaskEntry, QFilterCondition> {}

extension TaskEntryQuerySortBy on QueryBuilder<TaskEntry, TaskEntry, QSortBy> {
  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy>
      sortByCurrentElapsedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElapsedSeconds', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy>
      sortByCurrentElapsedSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElapsedSeconds', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByDayKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayKey', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByDayKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayKey', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByFormattedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDuration', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy>
      sortByFormattedDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDuration', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByIsPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByIsRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRunning', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByIsRunningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRunning', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy>
      sortByPauseDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy>
      sortByPauseDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByPausedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pausedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByPausedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pausedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByStoppedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stoppedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByStoppedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stoppedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension TaskEntryQuerySortThenBy
    on QueryBuilder<TaskEntry, TaskEntry, QSortThenBy> {
  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy>
      thenByCurrentElapsedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElapsedSeconds', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy>
      thenByCurrentElapsedSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElapsedSeconds', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByDayKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayKey', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByDayKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayKey', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByFormattedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDuration', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy>
      thenByFormattedDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDuration', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByIsPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByIsRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRunning', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByIsRunningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRunning', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy>
      thenByPauseDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy>
      thenByPauseDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByPausedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pausedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByPausedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pausedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByStoppedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stoppedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByStoppedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stoppedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension TaskEntryQueryWhereDistinct
    on QueryBuilder<TaskEntry, TaskEntry, QDistinct> {
  QueryBuilder<TaskEntry, TaskEntry, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QDistinct>
      distinctByCurrentElapsedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentElapsedSeconds');
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QDistinct> distinctByDayKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dayKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QDistinct> distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QDistinct> distinctByFormattedDuration(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formattedDuration',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QDistinct> distinctByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPaused');
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QDistinct> distinctByIsRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRunning');
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QDistinct>
      distinctByPauseDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pauseDurationSeconds');
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QDistinct> distinctByPausedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pausedAt');
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QDistinct> distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QDistinct> distinctByStoppedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stoppedAt');
    });
  }

  QueryBuilder<TaskEntry, TaskEntry, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension TaskEntryQueryProperty
    on QueryBuilder<TaskEntry, TaskEntry, QQueryProperty> {
  QueryBuilder<TaskEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TaskEntry, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<TaskEntry, int, QQueryOperations>
      currentElapsedSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentElapsedSeconds');
    });
  }

  QueryBuilder<TaskEntry, String, QQueryOperations> dayKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dayKey');
    });
  }

  QueryBuilder<TaskEntry, int, QQueryOperations> durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<TaskEntry, String, QQueryOperations>
      formattedDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedDuration');
    });
  }

  QueryBuilder<TaskEntry, bool, QQueryOperations> isPausedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPaused');
    });
  }

  QueryBuilder<TaskEntry, bool, QQueryOperations> isRunningProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRunning');
    });
  }

  QueryBuilder<TaskEntry, int, QQueryOperations>
      pauseDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pauseDurationSeconds');
    });
  }

  QueryBuilder<TaskEntry, DateTime?, QQueryOperations> pausedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pausedAt');
    });
  }

  QueryBuilder<TaskEntry, DateTime, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<TaskEntry, DateTime?, QQueryOperations> stoppedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stoppedAt');
    });
  }

  QueryBuilder<TaskEntry, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
