import 'package:hive/hive.dart';

part 'journal_model.g.dart';

@HiveType(typeId: 0)
class JournalModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? mood;

  @HiveField(4)
  String? location;

  @HiveField(5)
  List<String> images;

  @HiveField(6)
  DateTime waktu;

  JournalModel({
    required this.id,
    required this.title,
    this.description,
    this.mood,
    this.location,
    required this.images,
    required this.waktu,
  });
}
