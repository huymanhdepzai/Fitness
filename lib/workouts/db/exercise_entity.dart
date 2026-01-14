import 'package:isar/isar.dart';

part 'exercise_entity.g.dart';

// Hash string -> Id (Isar primary key phải là int)
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  for (var i = 0; i < string.length; i++) {
    hash ^= string.codeUnitAt(i);
    hash *= 0x100000001b3;
  }
  return hash.toUnsigned(64).toInt();
}

@collection
class ExerciseEntity {
  ExerciseEntity();

  // Primary key
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String exerciseId; // từ JSON

  late String name;
  late String gifUrl;

  // Lưu lowercase để query dễ + ổn định
  late List<String> targetMuscles;
  late List<String> secondaryMuscles;
  late List<String> bodyParts;
  late List<String> equipments;

  // Có thể lưu String (join) để nhẹ hơn List
  late List<String> instructions;

  // ✅ Quan trọng: lưu sẵn goal nào match (lose_fat/lean_tone/improve_shape)
  @Index()
  late List<String> goals;
  @Index()
  String primaryTarget = '';

  // helper: set primary id ổn định theo exerciseId
  void fixId() {
    id = fastHash(exerciseId);
  }
}
