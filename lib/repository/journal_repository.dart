import 'package:hive/hive.dart';
import 'package:my_journal/models/journal_model.dart';

class JournalRepository {
  static const String _boxName = 'journalBox';

  static Future<Box<JournalModel>> _getBox() async {
    return await Hive.openBox<JournalModel>(_boxName);
  }

  Future<List<JournalModel>> index() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> store(JournalModel journal) async {
    final box = await _getBox();
    await box.put(journal.id, journal);
  }

  Future<void> update(JournalModel journal) async {
    final box = await _getBox();
    if (!box.containsKey(journal.id)) {
      throw Exception('Journal not found');
    }
    await box.put(journal.id, journal);
  }

  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}
