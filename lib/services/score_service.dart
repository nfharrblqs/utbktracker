import 'package:utbktracker/db/db.dart';

class ScoreService {
  Future<bool> hasScore(int userId) async {
    final db = await DB.database;
    try {
      final result = await db.query(
        'score',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking score: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getScoreByUserId(int userId) async {
    final db = await DB.database;
    try {
      final result = await db.query(
        'score',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'tanggal_input DESC',
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting score by user ID: $e');
      return null;
    }
  }

  Future<int> upsertScore(Map<String, dynamic> scoreData) async {
    final db = await DB.database;
    try {
      final userId = scoreData['user_id'] as int;

      final existing = await db.query(
        'score',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      int totalScore = _calculateTotalScore(scoreData);

      final Map<String, dynamic> dataToSave = {
        'user_id': userId,
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

      if (existing.isNotEmpty) {
        final scoreId = existing.first['id'] as int;
        final result = await db.update(
          'score',
          dataToSave,
          where: 'id = ?',
          whereArgs: [scoreId],
        );
        print('Score berhasil diupdate untuk user $userId');
        return scoreId;
      } else {
        final result = await db.insert('score', dataToSave);
        print('Score berhasil disimpan untuk user $userId');
        return result;
      }
    } catch (e) {
      print('Error upserting score: $e');
      return -1;
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

  Future<Map<String, dynamic>?> getLatestScoreByUser(int userId) async {
    final db = await DB.database;
    try {
      final result = await db.query(
        'score',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'tanggal_input DESC',
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting latest score: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllScoreByUser(int userId) async {
    final db = await DB.database;
    try {
      final result = await db.query(
        'score',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'tanggal_input DESC',
      );
      return result;
    } catch (e) {
      print('Error getting all score: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getScoreById(int scoreId) async {
    final db = await DB.database;
    try {
      final result = await db.query(
        'score',
        where: 'id = ?',
        whereArgs: [scoreId],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting score by ID: $e');
      return null;
    }
  }

  Future<bool> updateScore(int scoreId, Map<String, dynamic> scoreData) async {
    final db = await DB.database;
    try {
      int totalScore = _calculateTotalScore(scoreData);

      final Map<String, dynamic> dataToUpdate = {
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

      final result = await db.update(
        'score',
        dataToUpdate,
        where: 'id = ?',
        whereArgs: [scoreId],
      );
      print('Score berhasil diupdate');
      return result > 0;
    } catch (e) {
      print('Error updating score: $e');
      return false;
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

  Future<Map<String, dynamic>> getScoreStatistics(int userId) async {
    final db = await DB.database;
    try {
      final result = await db.rawQuery(
        '''
        SELECT 
          COUNT(*) as total_test,
          AVG(penalaran_umum) as avg_penalaran_umum,
          AVG(pengetahuan_pemahaman_umum) as avg_pengetahuan_pemahaman_umum,
          AVG(pemahaman_bacaan_menulis) as avg_pemahaman_bacaan_menulis,
          AVG(pengetahuan_kuantitatif) as avg_pengetahuan_kuantitatif,
          AVG(literasi_bahasa_indonesia) as avg_literasi_bahasa_indonesia,
          AVG(literasi_bahasa_inggris) as avg_literasi_bahasa_inggris,
          AVG(penalaran_matematika) as avg_penalaran_matematika,
          AVG(total_score) as avg_total_score,
          MAX(total_score) as max_total_score,
          MIN(total_score) as min_total_score
        FROM score
        WHERE user_id = ?
      ''',
        [userId],
      );

      return result.isNotEmpty ? result.first : {};
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getImprovementTrend(int userId) async {
    final allScore = await getAllScoreByUser(userId);

    if (allScore.length < 2) {
      return {
        'hasImprovement': false,
        'message': 'Belum cukup data untuk membandingkan',
      };
    }

    final latest = allScore[0];
    final previous = allScore[1];

    final improvement =
        (latest['total_score'] ?? 0) - (previous['total_score'] ?? 0);

    return {
      'hasImprovement': improvement > 0,
      'improvement': improvement,
      'percentageChange':
          improvement > 0
              ? ((improvement / (previous['total_score'] ?? 1)) * 100)
                  .toStringAsFixed(2)
              : '0',
      'latestScore': latest['total_score'],
      'previousScore': previous['total_score'],
    };
  }

  bool validateScore(int score) {
    return score >= 0 && score <= 1000;
  }

  String getRecommendation(int scoreSesi) {
    if (scoreSesi >= 800) {
      return 'Sempurna! Pertahankan performa ini.';
    } else if (scoreSesi >= 700) {
      return 'Bagus! Masih ada ruang untuk peningkatan.';
    } else if (scoreSesi >= 600) {
      return 'Cukup. Fokus untuk meningkatkan sesi ini.';
    } else if (scoreSesi >= 500) {
      return 'Perlu perhatian lebih. Tingkatkan strategi belajar.';
    } else {
      return 'Perlu pelatihan intensif untuk sesi ini.';
    }
  }

  String getColorStatus(int score) {
    if (score >= 800) {
      return 'green';
    } else if (score >= 700) {
      return 'lightGreen';
    } else if (score >= 600) {
      return 'yellow';
    } else if (score >= 500) {
      return 'orange';
    } else {
      return 'red';
    }
  }
}

