import 'package:utbktracker/db/db.dart';

class StatistikService {
  Future<List<Map<String, dynamic>>> getAllPTN() async {
    final db = await DB.database;
    try {
      final result = await db.query('ptn', orderBy: 'nama ASC');
      return result;
    } catch (e) {
      print('Error getting PTN: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProdiByPTN(int ptnId) async {
    final db = await DB.database;
    try {
      final result = await db.query(
        'prodi',
        where: 'ptn_id = ?',
        whereArgs: [ptnId],
        orderBy: 'nama ASC',
      );
      return result;
    } catch (e) {
      print('Error getting Prodi: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllProdi() async {
    final db = await DB.database;
    try {
      final result = await db.query('prodi', orderBy: 'nama ASC');
      return result;
    } catch (e) {
      print('Error getting all Prodi: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPTNById(int ptnId) async {
    final db = await DB.database;
    try {
      final result = await db.query('ptn', where: 'id = ?', whereArgs: [ptnId]);
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting PTN by ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProdiById(int prodiId) async {
    final db = await DB.database;
    try {
      final result = await db.query(
        'prodi',
        where: 'id = ?',
        whereArgs: [prodiId],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting Prodi by ID: $e');
      return null;
    }
  }

  Future<int> getUserCurrentScore(int userId) async {
    final db = await DB.database;
    try {
      final result = await db.query(
        'score',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'tanggal_input DESC',
        limit: 1,
      );

      if (result.isNotEmpty) {
        final totalScore = result.first['total_score'] as int?;
        return totalScore ?? 600;
      }
      return 600;
    } catch (e) {
      print('Error getting user current score: $e');
      return 600;
    }
  }

  Future<List<Map<String, dynamic>>> getUserScoreHistory(int userId) async {
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
      print('Error getting user score history: $e');
      return [];
    }
  }

  Future<double> getUserAverageScore(int userId) async {
    final db = await DB.database;
    try {
      final result = await db.rawQuery(
        '''
        SELECT AVG(total_score) as avg_score 
        FROM score 
        WHERE user_id = ?
      ''',
        [userId],
      );

      if (result.isNotEmpty && result.first['avg_score'] != null) {
        return result.first['avg_score'] as double;
      }
      return 600.0;
    } catch (e) {
      print('Error getting user average score: $e');
      return 600.0;
    }
  }

  double calculatePassingRate(int dayaTampung, int peminat) {
    if (peminat == 0) return 0;
    return (dayaTampung / peminat) * 100;
  }

  String calculatePeluang(int currentScore, int targetScore) {
    int difference = targetScore - currentScore;

    if (difference <= 0) {
      return 'Tinggi';
    } else if (difference <= 25) {
      return 'Cukup';
    } else if (difference <= 50) {
      return 'Rendah/Cukup';
    } else {
      return 'Rendah';
    }
  }

  String getPeluangColor(String peluang) {
    switch (peluang) {
      case 'Tinggi':
        return 'green';
      case 'Cukup':
        return 'orange';
      case 'Rendah/Cukup':
        return 'orange';
      case 'Rendah':
        return 'red';
      default:
        return 'grey';
    }
  }

  String getRecommendation(int currentScore, int targetScore) {
    int difference = targetScore - currentScore;

    if (difference <= 0) {
      return 'Skor Anda sudah memenuhi target! Pertahankan performa Anda.';
    } else if (difference <= 25) {
      return 'Perlu peningkatan $difference poin lagi. Fokus pada tryout rutin.';
    } else if (difference <= 50) {
      return 'Butuh peningkatan $difference poin. Ikuti bimbingan belajar.';
    } else if (difference <= 100) {
      return 'Tingkatkan secara signifikan. Targetkan peningkatan $difference poin.';
    } else {
      return 'Perlu pelatihan intensif. Selisih $difference poin dari target.';
    }
  }

  Future<List<Map<String, dynamic>>> getAllProdiWithPTN() async {
    final db = await DB.database;
    try {
      final result = await db.rawQuery('''
        SELECT 
          p.id,
          p.nama as prodi_nama,
          p.jenjang,
          p.daya_tampung,
          p.peminat,
          p.ptn_id,
          ptn.nama as ptn_nama,
          ptn.kota
        FROM prodi p
        JOIN ptn ON p.ptn_id = ptn.id
        ORDER BY ptn.nama, p.nama
      ''');
      return result;
    } catch (e) {
      print('Error getting all Prodi with PTN: $e');
      return [];
    }
  }

  int calculateScoreGap(int currentScore, int targetScore) {
    return targetScore - currentScore;
  }

  Map<String, dynamic> getPeluangStatus(int currentScore, int targetScore) {
    String peluang = calculatePeluang(currentScore, targetScore);
    int gap = calculateScoreGap(currentScore, targetScore);

    return {
      'peluang': peluang,
      'gap': gap,
      'status': gap <= 0 ? '✓ Tercapai' : '✗ Belum Tercapai',
      'color': getPeluangColor(peluang),
    };
  }

  Future<List<Map<String, dynamic>>> getRankedProdiByDifficulty(
    int ptnId,
  ) async {
    final prodi = await getProdiByPTN(ptnId);

    prodi.sort((a, b) {
      double rateA = calculatePassingRate(a['daya_tampung'], a['peminat']);
      double rateB = calculatePassingRate(b['daya_tampung'], b['peminat']);
      return rateA.compareTo(rateB);
    });

    return prodi;
  }

  Future<Map<String, dynamic>> getProdiExtremes(int ptnId) async {
    final prodi = await getProdiByPTN(ptnId);

    if (prodi.isEmpty) {
      return {'easiest': null, 'hardest': null};
    }

    Map<String, dynamic> easiest = prodi[0];
    Map<String, dynamic> hardest = prodi[0];

    double easyRate = calculatePassingRate(
      easiest['daya_tampung'],
      easiest['peminat'],
    );
    double hardRate = calculatePassingRate(
      hardest['daya_tampung'],
      hardest['peminat'],
    );

    for (var p in prodi) {
      double rate = calculatePassingRate(p['daya_tampung'], p['peminat']);
      if (rate > easyRate) {
        easiest = p;
        easyRate = rate;
      }
      if (rate < hardRate) {
        hardest = p;
        hardRate = rate;
      }
    }

    return {
      'easiest': easiest,
      'hardest': hardest,
      'easyRate': easyRate,
      'hardRate': hardRate,
    };
  }

  int calculateScoreNeeded(int dayaTampung, int peminat, int baselineScore) {
    double passingRate = calculatePassingRate(dayaTampung, peminat);

    if (passingRate > 10) {
      return baselineScore - 50;
    } else if (passingRate > 5) {
      return baselineScore;
    } else if (passingRate > 2) {
      return baselineScore + 50;
    } else {
      return baselineScore + 100;
    }
  }

  String getProdiDifficultyRecommendation(double passingRate) {
    if (passingRate > 10) {
      return 'Prodi ini relatif mudah dengan banyak kesempatan masuk';
    } else if (passingRate > 5) {
      return 'Prodi ini memiliki tingkat kesulitan menengah';
    } else if (passingRate > 2) {
      return 'Prodi ini cukup sulit, butuh persiapan matang';
    } else {
      return 'Prodi ini sangat kompetitif, butuh skor tertinggi';
    }
  }

  Future<List<Map<String, dynamic>>> searchProdi(String query) async {
    final db = await DB.database;
    try {
      final result = await db.rawQuery(
        '''
        SELECT 
          p.id,
          p.nama as prodi_nama,
          p.jenjang,
          p.daya_tampung,
          p.peminat,
          p.ptn_id,
          ptn.nama as ptn_nama,
          ptn.kota
        FROM prodi p
        JOIN ptn ON p.ptn_id = ptn.id
        WHERE p.nama LIKE ?
        ORDER BY ptn.nama, p.nama
      ''',
        ['%$query%'],
      );
      return result;
    } catch (e) {
      print('Error searching Prodi: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getPTNStatistics(int ptnId) async {
    final prodi = await getProdiByPTN(ptnId);

    if (prodi.isEmpty) {
      return {
        'totalProdi': 0,
        'totalDayaTampung': 0,
        'totalPeminat': 0,
        'averagePassingRate': 0,
      };
    }

    int totalProdi = prodi.length;
    int totalDayaTampung = 0;
    int totalPeminat = 0;

    for (var p in prodi) {
      totalDayaTampung += (p['daya_tampung'] as int);
      totalPeminat += (p['peminat'] as int);
    }

    double averagePassingRate = calculatePassingRate(
      totalDayaTampung,
      totalPeminat,
    );

    return {
      'totalProdi': totalProdi,
      'totalDayaTampung': totalDayaTampung,
      'totalPeminat': totalPeminat,
      'averagePassingRate': averagePassingRate,
    };
  }

  int calculatePercentileScore(double passingRate, int baseScore) {
    if (passingRate > 15) {
      return baseScore - 100;
    } else if (passingRate > 10) {
      return baseScore - 50;
    } else if (passingRate > 5) {
      return baseScore;
    } else if (passingRate > 2) {
      return baseScore + 50;
    } else {
      return baseScore + 100;
    }
  }

  Future<int> savePilihan(
    int userId,
    int urutan,
    int ptnId,
    int prodiId,
  ) async {
    final db = await DB.database;
    try {
      final existing = await db.query(
        'pilihan',
        where: 'user_id = ? AND urutan = ?',
        whereArgs: [userId, urutan],
      );

      if (existing.isNotEmpty) {
        await db.update(
          'pilihan',
          {
            'ptn_id': ptnId,
            'prodi_id': prodiId,
            'tanggal_input': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [existing[0]['id']],
        );
        print('Pilihan $urutan berhasil diupdate');
        return existing[0]['id'] as int;
      } else {
        final result = await db.insert('pilihan', {
          'user_id': userId,
          'urutan': urutan,
          'ptn_id': ptnId,
          'prodi_id': prodiId,
          'tanggal_input': DateTime.now().toIso8601String(),
        });
        print('Pilihan $urutan berhasil disimpan');
        return result;
      }
    } catch (e) {
      print('Error saving pilihan: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getPilihanWithDetails(int userId) async {
    final db = await DB.database;
    try {
      final result = await db.rawQuery(
        '''
        SELECT 
          p.id,
          p.user_id,
          p.urutan,
          p.ptn_id,
          p.prodi_id,
          ptn.nama as ptn_nama,
          ptn.kota as ptn_kota,
          ptn.akreditasi,
          prodi.nama as prodi_nama,
          prodi.jenjang,
          prodi.daya_tampung,
          prodi.peminat,
          prodi.target_score,
          p.tanggal_input
        FROM pilihan p
        JOIN ptn ON p.ptn_id = ptn.id
        JOIN prodi ON p.prodi_id = prodi.id
        WHERE p.user_id = ?
        ORDER BY p.urutan ASC
      ''',
        [userId],
      );
      return result;
    } catch (e) {
      print('Error getting pilihan with details: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPilihanByUrutan(
    int userId,
    int urutan,
  ) async {
    final db = await DB.database;
    try {
      final result = await db.query(
        'pilihan',
        where: 'user_id = ? AND urutan = ?',
        whereArgs: [userId, urutan],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting pilihan by urutan: $e');
      return null;
    }
  }

  Future<bool> deletePilihan(int pilihanId) async {
    final db = await DB.database;
    try {
      final result = await db.delete(
        'pilihan',
        where: 'id = ?',
        whereArgs: [pilihanId],
      );
      return result > 0;
    } catch (e) {
      print('Error deleting pilihan: $e');
      return false;
    }
  }

  Future<bool> deleteAllPilihanByUser(int userId) async {
    final db = await DB.database;
    try {
      await db.delete('pilihan', where: 'user_id = ?', whereArgs: [userId]);
      return true;
    } catch (e) {
      print('Error deleting all pilihan: $e');
      return false;
    }
  }

  Future<int> getPilihanCount(int userId) async {
    final db = await DB.database;
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM pilihan WHERE user_id = ?',
        [userId],
      );
      return (result[0]['count'] as int?) ?? 0;
    } catch (e) {
      print('Error getting pilihan count: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>> getPilihanRecommendation(
    int userId,
    int currentScore,
  ) async {
    final db = await DB.database;
    try {
      final result = await db.rawQuery(
        '''
        SELECT 
          p.urutan,
          ptn.nama as ptn_nama,
          prodi.nama as prodi_nama,
          prodi.target_score,
          prodi.target_score - ? as score_gap,
          CASE
            WHEN prodi.target_score - ? <= 0 THEN 'Tinggi'
            WHEN prodi.target_score - ? <= 25 THEN 'Cukup'
            WHEN prodi.target_score - ? <= 50 THEN 'Rendah/Cukup'
            ELSE 'Rendah'
          END as peluang_lolos,
          prodi.daya_tampung,
          prodi.peminat
        FROM pilihan p
        JOIN ptn ON p.ptn_id = ptn.id
        JOIN prodi ON p.prodi_id = prodi.id
        WHERE p.user_id = ?
        ORDER BY p.urutan ASC
      ''',
        [currentScore, currentScore, currentScore, currentScore, userId],
      );

      return {'success': true, 'data': result};
    } catch (e) {
      print('Error getting recommendation: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  bool validatePilihan(List<Map<String, dynamic>> pilihanList) {
    return pilihanList.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getPeluangLolosAllPilihan(
    int userId,
    int currentScore,
  ) async {
    try {
      final pilihan = await getPilihanWithDetails(userId);

      List<Map<String, dynamic>> result = [];

      for (var p in pilihan) {
        final targetScore = p['target_score'] as int;
        final peluang = calculatePeluang(currentScore, targetScore);
        final gap = calculateScoreGap(currentScore, targetScore);

        result.add({
          'urutan': p['urutan'],
          'ptn_nama': p['ptn_nama'],
          'prodi_nama': p['prodi_nama'],
          'target_score': targetScore,
          'score_gap': gap,
          'peluang': peluang,
          'color': getPeluangColor(peluang),
        });
      }

      return result;
    } catch (e) {
      print('Error getting peluang lolos: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPassingRateAllPilihan(
    int userId,
  ) async {
    try {
      final pilihan = await getPilihanWithDetails(userId);

      List<Map<String, dynamic>> result = [];

      for (var p in pilihan) {
        final dayaTampung = p['daya_tampung'] as int;
        final peminat = p['peminat'] as int;
        final passingRate = calculatePassingRate(dayaTampung, peminat);

        result.add({
          'urutan': p['urutan'],
          'ptn_nama': p['ptn_nama'],
          'prodi_nama': p['prodi_nama'],
          'daya_tampung': dayaTampung,
          'peminat': peminat,
          'passing_rate': passingRate,
          'difficulty': getProdiDifficultyRecommendation(passingRate),
        });
      }

      return result;
    } catch (e) {
      print('Error getting passing rate: $e');
      return [];
    }
  }
}
