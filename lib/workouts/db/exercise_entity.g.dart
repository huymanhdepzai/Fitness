// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExerciseEntityCollection on Isar {
  IsarCollection<ExerciseEntity> get exerciseEntitys => this.collection();
}

const ExerciseEntitySchema = CollectionSchema(
  name: r'ExerciseEntity',
  id: -1061429956440164644,
  properties: {
    r'bodyParts': PropertySchema(
      id: 0,
      name: r'bodyParts',
      type: IsarType.stringList,
    ),
    r'equipments': PropertySchema(
      id: 1,
      name: r'equipments',
      type: IsarType.stringList,
    ),
    r'exerciseId': PropertySchema(
      id: 2,
      name: r'exerciseId',
      type: IsarType.string,
    ),
    r'gifUrl': PropertySchema(
      id: 3,
      name: r'gifUrl',
      type: IsarType.string,
    ),
    r'goals': PropertySchema(
      id: 4,
      name: r'goals',
      type: IsarType.stringList,
    ),
    r'instructions': PropertySchema(
      id: 5,
      name: r'instructions',
      type: IsarType.stringList,
    ),
    r'name': PropertySchema(
      id: 6,
      name: r'name',
      type: IsarType.string,
    ),
    r'primaryTarget': PropertySchema(
      id: 7,
      name: r'primaryTarget',
      type: IsarType.string,
    ),
    r'secondaryMuscles': PropertySchema(
      id: 8,
      name: r'secondaryMuscles',
      type: IsarType.stringList,
    ),
    r'targetMuscles': PropertySchema(
      id: 9,
      name: r'targetMuscles',
      type: IsarType.stringList,
    )
  },
  estimateSize: _exerciseEntityEstimateSize,
  serialize: _exerciseEntitySerialize,
  deserialize: _exerciseEntityDeserialize,
  deserializeProp: _exerciseEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'exerciseId': IndexSchema(
      id: -5431545612219001672,
      name: r'exerciseId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'exerciseId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'goals': IndexSchema(
      id: -4885250467232237783,
      name: r'goals',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'goals',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'primaryTarget': IndexSchema(
      id: -4691061993186144470,
      name: r'primaryTarget',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'primaryTarget',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _exerciseEntityGetId,
  getLinks: _exerciseEntityGetLinks,
  attach: _exerciseEntityAttach,
  version: '3.1.0+1',
);

int _exerciseEntityEstimateSize(
  ExerciseEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bodyParts.length * 3;
  {
    for (var i = 0; i < object.bodyParts.length; i++) {
      final value = object.bodyParts[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.equipments.length * 3;
  {
    for (var i = 0; i < object.equipments.length; i++) {
      final value = object.equipments[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.exerciseId.length * 3;
  bytesCount += 3 + object.gifUrl.length * 3;
  bytesCount += 3 + object.goals.length * 3;
  {
    for (var i = 0; i < object.goals.length; i++) {
      final value = object.goals[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.instructions.length * 3;
  {
    for (var i = 0; i < object.instructions.length; i++) {
      final value = object.instructions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.primaryTarget.length * 3;
  bytesCount += 3 + object.secondaryMuscles.length * 3;
  {
    for (var i = 0; i < object.secondaryMuscles.length; i++) {
      final value = object.secondaryMuscles[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.targetMuscles.length * 3;
  {
    for (var i = 0; i < object.targetMuscles.length; i++) {
      final value = object.targetMuscles[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _exerciseEntitySerialize(
  ExerciseEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.bodyParts);
  writer.writeStringList(offsets[1], object.equipments);
  writer.writeString(offsets[2], object.exerciseId);
  writer.writeString(offsets[3], object.gifUrl);
  writer.writeStringList(offsets[4], object.goals);
  writer.writeStringList(offsets[5], object.instructions);
  writer.writeString(offsets[6], object.name);
  writer.writeString(offsets[7], object.primaryTarget);
  writer.writeStringList(offsets[8], object.secondaryMuscles);
  writer.writeStringList(offsets[9], object.targetMuscles);
}

ExerciseEntity _exerciseEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExerciseEntity();
  object.bodyParts = reader.readStringList(offsets[0]) ?? [];
  object.equipments = reader.readStringList(offsets[1]) ?? [];
  object.exerciseId = reader.readString(offsets[2]);
  object.gifUrl = reader.readString(offsets[3]);
  object.goals = reader.readStringList(offsets[4]) ?? [];
  object.id = id;
  object.instructions = reader.readStringList(offsets[5]) ?? [];
  object.name = reader.readString(offsets[6]);
  object.primaryTarget = reader.readString(offsets[7]);
  object.secondaryMuscles = reader.readStringList(offsets[8]) ?? [];
  object.targetMuscles = reader.readStringList(offsets[9]) ?? [];
  return object;
}

P _exerciseEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringList(offset) ?? []) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _exerciseEntityGetId(ExerciseEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _exerciseEntityGetLinks(ExerciseEntity object) {
  return [];
}

void _exerciseEntityAttach(
    IsarCollection<dynamic> col, Id id, ExerciseEntity object) {
  object.id = id;
}

extension ExerciseEntityByIndex on IsarCollection<ExerciseEntity> {
  Future<ExerciseEntity?> getByExerciseId(String exerciseId) {
    return getByIndex(r'exerciseId', [exerciseId]);
  }

  ExerciseEntity? getByExerciseIdSync(String exerciseId) {
    return getByIndexSync(r'exerciseId', [exerciseId]);
  }

  Future<bool> deleteByExerciseId(String exerciseId) {
    return deleteByIndex(r'exerciseId', [exerciseId]);
  }

  bool deleteByExerciseIdSync(String exerciseId) {
    return deleteByIndexSync(r'exerciseId', [exerciseId]);
  }

  Future<List<ExerciseEntity?>> getAllByExerciseId(
      List<String> exerciseIdValues) {
    final values = exerciseIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'exerciseId', values);
  }

  List<ExerciseEntity?> getAllByExerciseIdSync(List<String> exerciseIdValues) {
    final values = exerciseIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'exerciseId', values);
  }

  Future<int> deleteAllByExerciseId(List<String> exerciseIdValues) {
    final values = exerciseIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'exerciseId', values);
  }

  int deleteAllByExerciseIdSync(List<String> exerciseIdValues) {
    final values = exerciseIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'exerciseId', values);
  }

  Future<Id> putByExerciseId(ExerciseEntity object) {
    return putByIndex(r'exerciseId', object);
  }

  Id putByExerciseIdSync(ExerciseEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'exerciseId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByExerciseId(List<ExerciseEntity> objects) {
    return putAllByIndex(r'exerciseId', objects);
  }

  List<Id> putAllByExerciseIdSync(List<ExerciseEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'exerciseId', objects, saveLinks: saveLinks);
  }
}

extension ExerciseEntityQueryWhereSort
    on QueryBuilder<ExerciseEntity, ExerciseEntity, QWhere> {
  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ExerciseEntityQueryWhere
    on QueryBuilder<ExerciseEntity, ExerciseEntity, QWhereClause> {
  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterWhereClause>
      exerciseIdEqualTo(String exerciseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'exerciseId',
        value: [exerciseId],
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterWhereClause>
      exerciseIdNotEqualTo(String exerciseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exerciseId',
              lower: [],
              upper: [exerciseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exerciseId',
              lower: [exerciseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exerciseId',
              lower: [exerciseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exerciseId',
              lower: [],
              upper: [exerciseId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterWhereClause> goalsEqualTo(
      List<String> goals) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'goals',
        value: [goals],
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterWhereClause>
      goalsNotEqualTo(List<String> goals) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'goals',
              lower: [],
              upper: [goals],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'goals',
              lower: [goals],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'goals',
              lower: [goals],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'goals',
              lower: [],
              upper: [goals],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterWhereClause>
      primaryTargetEqualTo(String primaryTarget) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'primaryTarget',
        value: [primaryTarget],
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterWhereClause>
      primaryTargetNotEqualTo(String primaryTarget) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'primaryTarget',
              lower: [],
              upper: [primaryTarget],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'primaryTarget',
              lower: [primaryTarget],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'primaryTarget',
              lower: [primaryTarget],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'primaryTarget',
              lower: [],
              upper: [primaryTarget],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ExerciseEntityQueryFilter
    on QueryBuilder<ExerciseEntity, ExerciseEntity, QFilterCondition> {
  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodyParts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bodyParts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bodyParts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bodyParts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bodyParts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bodyParts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bodyParts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bodyParts',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodyParts',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bodyParts',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bodyParts',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bodyParts',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bodyParts',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bodyParts',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bodyParts',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      bodyPartsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bodyParts',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'equipments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'equipments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'equipments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'equipments',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'equipments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'equipments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'equipments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'equipments',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'equipments',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'equipments',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equipments',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equipments',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equipments',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equipments',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equipments',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      equipmentsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equipments',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      exerciseIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      exerciseIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      exerciseIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      exerciseIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exerciseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      exerciseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      exerciseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      exerciseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      exerciseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'exerciseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      exerciseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      exerciseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'exerciseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      gifUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gifUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      gifUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gifUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      gifUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gifUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      gifUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gifUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      gifUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gifUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      gifUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gifUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      gifUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gifUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      gifUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gifUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      gifUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gifUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      gifUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gifUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goals',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'goals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'goals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'goals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'goals',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goals',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'goals',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'goals',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'goals',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'goals',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'goals',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'goals',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      goalsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'goals',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'instructions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'instructions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'instructions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'instructions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'instructions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'instructions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'instructions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'instructions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'instructions',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'instructions',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'instructions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'instructions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'instructions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'instructions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'instructions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      instructionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'instructions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      primaryTargetEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      primaryTargetGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'primaryTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      primaryTargetLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'primaryTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      primaryTargetBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'primaryTarget',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      primaryTargetStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'primaryTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      primaryTargetEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'primaryTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      primaryTargetContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'primaryTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      primaryTargetMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'primaryTarget',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      primaryTargetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryTarget',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      primaryTargetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'primaryTarget',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondaryMuscles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'secondaryMuscles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'secondaryMuscles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'secondaryMuscles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'secondaryMuscles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'secondaryMuscles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'secondaryMuscles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'secondaryMuscles',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondaryMuscles',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'secondaryMuscles',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'secondaryMuscles',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'secondaryMuscles',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'secondaryMuscles',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'secondaryMuscles',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'secondaryMuscles',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      secondaryMusclesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'secondaryMuscles',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetMuscles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetMuscles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetMuscles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetMuscles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetMuscles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetMuscles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetMuscles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetMuscles',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetMuscles',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetMuscles',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'targetMuscles',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'targetMuscles',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'targetMuscles',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'targetMuscles',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'targetMuscles',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterFilterCondition>
      targetMusclesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'targetMuscles',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension ExerciseEntityQueryObject
    on QueryBuilder<ExerciseEntity, ExerciseEntity, QFilterCondition> {}

extension ExerciseEntityQueryLinks
    on QueryBuilder<ExerciseEntity, ExerciseEntity, QFilterCondition> {}

extension ExerciseEntityQuerySortBy
    on QueryBuilder<ExerciseEntity, ExerciseEntity, QSortBy> {
  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy>
      sortByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.asc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy>
      sortByExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.desc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy> sortByGifUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gifUrl', Sort.asc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy>
      sortByGifUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gifUrl', Sort.desc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy>
      sortByPrimaryTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryTarget', Sort.asc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy>
      sortByPrimaryTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryTarget', Sort.desc);
    });
  }
}

extension ExerciseEntityQuerySortThenBy
    on QueryBuilder<ExerciseEntity, ExerciseEntity, QSortThenBy> {
  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy>
      thenByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.asc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy>
      thenByExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.desc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy> thenByGifUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gifUrl', Sort.asc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy>
      thenByGifUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gifUrl', Sort.desc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy>
      thenByPrimaryTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryTarget', Sort.asc);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QAfterSortBy>
      thenByPrimaryTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryTarget', Sort.desc);
    });
  }
}

extension ExerciseEntityQueryWhereDistinct
    on QueryBuilder<ExerciseEntity, ExerciseEntity, QDistinct> {
  QueryBuilder<ExerciseEntity, ExerciseEntity, QDistinct>
      distinctByBodyParts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyParts');
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QDistinct>
      distinctByEquipments() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'equipments');
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QDistinct> distinctByExerciseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exerciseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QDistinct> distinctByGifUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gifUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QDistinct> distinctByGoals() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goals');
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QDistinct>
      distinctByInstructions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'instructions');
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QDistinct>
      distinctByPrimaryTarget({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'primaryTarget',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QDistinct>
      distinctBySecondaryMuscles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'secondaryMuscles');
    });
  }

  QueryBuilder<ExerciseEntity, ExerciseEntity, QDistinct>
      distinctByTargetMuscles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetMuscles');
    });
  }
}

extension ExerciseEntityQueryProperty
    on QueryBuilder<ExerciseEntity, ExerciseEntity, QQueryProperty> {
  QueryBuilder<ExerciseEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExerciseEntity, List<String>, QQueryOperations>
      bodyPartsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyParts');
    });
  }

  QueryBuilder<ExerciseEntity, List<String>, QQueryOperations>
      equipmentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'equipments');
    });
  }

  QueryBuilder<ExerciseEntity, String, QQueryOperations> exerciseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exerciseId');
    });
  }

  QueryBuilder<ExerciseEntity, String, QQueryOperations> gifUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gifUrl');
    });
  }

  QueryBuilder<ExerciseEntity, List<String>, QQueryOperations> goalsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goals');
    });
  }

  QueryBuilder<ExerciseEntity, List<String>, QQueryOperations>
      instructionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'instructions');
    });
  }

  QueryBuilder<ExerciseEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ExerciseEntity, String, QQueryOperations>
      primaryTargetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryTarget');
    });
  }

  QueryBuilder<ExerciseEntity, List<String>, QQueryOperations>
      secondaryMusclesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'secondaryMuscles');
    });
  }

  QueryBuilder<ExerciseEntity, List<String>, QQueryOperations>
      targetMusclesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetMuscles');
    });
  }
}
