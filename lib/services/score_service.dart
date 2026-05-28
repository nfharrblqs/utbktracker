import 'package:utbktracker/db/db.dart';

class ScoreService {



  Future<List<Map<String, dynamic>>> getAllScoreByUser(int userId) async {
    final db = await DB.database;
    try {
      final result = await db.query(
        'score',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'tanggal_input ASC',
      );
      return result;
    } catch (e) {
      print('Error getting all score: $e');
      return [];
    }
  }

  Future<int> insertScore(Map<String, dynamic> scoreData) async {
    final db = await DB.database;
    try {
      int totalScore = _calculateTotalScore(scoreData);

      final Map<String, dynamic> dataToSave = {
        'user_id': scoreData['user_id'] as int,
        'penalaran_umum': scoreData['penalaran_umum'] as int,
        'pengetahuan_pemahaman_umum':
            scoreData['pengetahuan_pemahaman_umum'] as int,
        'pemahaman_bacaan_menulis':
            scoreData['pemahaman_bacaan_menulis'] as int,
        'pengetahuan_kuantitatif': scoreData['pengetahuan_kuantitatif'] as int,
        'literasi_bahasa_indonesia':
            scoreData['literasi_bahasa_indonesia'] as int,
        'literasi_bahasa_inggris': scoreData['literasi_bahasa_inggris'] as int,
        'penalaran_matematika': scoreData['penalaran_matematika'] as int,
        'total_score': totalScore,
        'tanggal_input': DateTime.now().toIso8601String(),
      };

      final result = await db.insert('score', dataToSave);
      print('Score berhasil disimpan dengan ID: $result');
      return result;
    } catch (e) {
      print('Error inserting score: $e');
      return -1;
    }
  }

  Future<bool> deleteScore(int scoreId) async {
    final db = await DB.database;
    try {
      final result = await db.delete(
        'score',
        where: 'id = ?',
        whereArgs: [scoreId],
      );
      print('Score berhasil dihapus');
      return result > 0;
    } catch (e) {
      print('Error deleting score: $e');
      return false;
    }
  }

  int _calculateTotalScore(Map<String, dynamic> scoreData) {
    int total = 0;
    int count = 0;

    final fields = [
      'penalaran_umum',
      'pengetahuan_pemahaman_umum',
      'pemahaman_bacaan_menulis',
      'pengetahuan_kuantitatif',
      'literasi_bahasa_indonesia',
      'literasi_bahasa_inggris',
      'penalaran_matematika',
    ];

    for (var field in fields) {
      if (scoreData.containsKey(field) && scoreData[field] != null) {
        total += (scoreData[field] as int);
        count++;
      }
    }

    return count > 0 ? (total ~/ count) : 0;
  }

  bool validateScore(int score) {
    return score >= 0 && score <= 1000;
  }
}
