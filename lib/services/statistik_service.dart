import 'package:utbktracker/db/db.dart';
import 'dart:math';

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

  Future<int?> getUserCurrentScore(int userId) async {
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
        return result.first['total_score'] as int?;
      }
      return null;
    } catch (e) {
      print('Error getting user current score: $e');
      return null;
    }
  }

  Future<bool> hasUserScore(int userId) async {
    final score = await getUserCurrentScore(userId);
    return score != null;
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

  Future<double?> getMeanScore(int userId) async {
    final history = await getUserScoreHistory(userId);

    if (history.isEmpty) {
      return null;
    }

    int total = 0;
    for (var score in history) {
      total += score['total_score'] as int;
    }
    return total / history.length;
  }

  Future<double> getNationalAverageImprovement() async {
    final db = await DB.database;
    try {
      final result = await db.rawQuery('''
        SELECT 
          user_id,
          MIN(total_score) as first_score,
          MAX(total_score) as last_score,
          COUNT(*) as total_tryout
        FROM score
        GROUP BY user_id
        HAVING total_tryout >= 2
      ''');

      if (result.isEmpty) return 0.05;

      double totalImprovement = 0;
      int validUsers = 0;

      for (var user in result) {
        int first = user['first_score'] as int;
        int last = user['last_score'] as int;
        if (first > 0) {
          double improvement = (last - first) / first;
          totalImprovement += improvement;
          validUsers++;
        }
      }

      return validUsers > 0 ? totalImprovement / validUsers : 0.05;
    } catch (e) {
      print('Error getting national average improvement: $e');
      return 0.05;
    }
  }

  Future<double?> getNationalStdDeviation() async {
    final db = await DB.database;
    try {
      final result = await db.rawQuery('''
        SELECT 
          AVG(total_score) as mean_score,
          COUNT(*) as total_data
        FROM score
      ''');

      if (result.isEmpty || result.first['mean_score'] == null) return null;

      double mean = result.first['mean_score'] as double;

      final varianceResult = await db.rawQuery(
        '''
        SELECT SUM((total_score - ?) * (total_score - ?)) as sum_squared
        FROM score
      ''',
        [mean, mean],
      );

      if (varianceResult.isEmpty) return null;

      double sumSquared = varianceResult.first['sum_squared'] as double;
      int totalData = result.first['total_data'] as int;

      if (totalData < 2) return null;

      return sqrt(sumSquared / totalData);
    } catch (e) {
      print('Error getting national std deviation: $e');
      return null;
    }
  }

  Future<double?> getNationalMeanScore() async {
    final db = await DB.database;
    try {
      final result = await db.rawQuery('''
        SELECT AVG(total_score) as avg_score FROM score
      ''');

      if (result.isNotEmpty && result.first['avg_score'] != null) {
        return result.first['avg_score'] as double;
      }
      return null;
    } catch (e) {
      print('Error getting national mean score: $e');
      return null;
    }
  }

  Future<double?> getUserPercentileNational(int userId, int userScore) async {
    final db = await DB.database;
    try {
      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) as count_below 
        FROM score 
        WHERE total_score < ?
      ''',
        [userScore],
      );

      final totalResult = await db.rawQuery('''
        SELECT COUNT(*) as total FROM score
      ''');

      int countBelow = result.first['count_below'] as int;
      int total = totalResult.first['total'] as int;

      if (total == 0) return 50;
      return (countBelow / total) * 100;
    } catch (e) {
      print('Error getting user percentile national: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> calculatePeluangStatistika({
    required int currentScore,
    required int targetScore,
    required int userId,
    required int dayaTampung,
    required int peminat,
  }) async {
    final hasScore = await hasUserScore(userId);
    if (!hasScore) {
      return null;
    }

    final userHistory = await getUserScoreHistory(userId);
    List<int> userScores =
        userHistory.map((s) => s['total_score'] as int).toList();

    final nationalMean = await getNationalMeanScore();
    final nationalStdDev = await getNationalStdDeviation();
    final nationalTrend = await getNationalAverageImprovement();
    final userPercentile = await getUserPercentileNational(
      userId,
      currentScore,
    );

    print('=== DEBUG STATISTIK NASIONAL ===');
    print('National Mean: $nationalMean');
    print('National Std Dev: $nationalStdDev');
    print('National Trend: $nationalTrend');
    print('User Percentile: $userPercentile%');

    double faktorNilai;
    int selisih = targetScore - currentScore;

    if (selisih <= 0) {
      faktorNilai = 1.0;
    } else {
      faktorNilai = 1.0 - (selisih / targetScore).clamp(0.0, 0.8);
    }

    double faktorTrend = 0.5;
    if (userPercentile != null) {
      if (userPercentile >= 80)
        faktorTrend = 0.9;
      else if (userPercentile >= 60)
        faktorTrend = 0.7;
      else if (userPercentile >= 40)
        faktorTrend = 0.5;
      else if (userPercentile >= 20)
        faktorTrend = 0.3;
      else
        faktorTrend = 0.1;
    }

    double faktorKonsistensi = 0.5;
    if (nationalMean != null && nationalStdDev != null) {
      double zScore = (currentScore - nationalMean) / nationalStdDev;

      if (zScore >= 1.5)
        faktorKonsistensi = 0.9;
      else if (zScore >= 0.5)
        faktorKonsistensi = 0.7;
      else if (zScore >= -0.5)
        faktorKonsistensi = 0.5;
      else if (zScore >= -1.5)
        faktorKonsistensi = 0.3;
      else
        faktorKonsistensi = 0.1;

      print('Z-Score User: $zScore, faktorKonsistensi: $faktorKonsistensi');
    }

    double passingRate = peminat > 0 ? (dayaTampung / peminat) * 100 : 0;
    double faktorPersaingan;
    if (passingRate > 15)
      faktorPersaingan = 0.9;
    else if (passingRate > 10)
      faktorPersaingan = 0.7;
    else if (passingRate > 5)
      faktorPersaingan = 0.5;
    else if (passingRate > 2)
      faktorPersaingan = 0.3;
    else
      faktorPersaingan = 0.1;

    double totalPeluang =
        ((faktorNilai * 0.4) +
            (faktorTrend * 0.2) +
            (faktorKonsistensi * 0.2) +
            (faktorPersaingan * 0.2)) *
        100;

    totalPeluang = totalPeluang.clamp(0.0, 100.0);

    String kategori;
    if (totalPeluang >= 80)
      kategori = 'Sangat Tinggi';
    else if (totalPeluang >= 60)
      kategori = 'Tinggi';
    else if (totalPeluang >= 40)
      kategori = 'Sedang';
    else if (totalPeluang >= 20)
      kategori = 'Rendah';
    else
      kategori = 'Sangat Rendah';

    String rekomendasi = _generateNationalRecommendation(
      currentScore: currentScore,
      targetScore: targetScore,
      selisih: selisih,
      faktorNilai: faktorNilai,
      faktorTrend: faktorTrend,
      faktorKonsistensi: faktorKonsistensi,
      passingRate: passingRate,
      totalPeluang: totalPeluang,
      userPercentile: userPercentile,
      nationalMean: nationalMean,
    );

    return {
      'peluang': kategori,
      'persentase': totalPeluang.toStringAsFixed(1),
      'selisih': selisih,
      'faktorNilai': (faktorNilai * 100).toStringAsFixed(0),
      'faktorTrend': (faktorTrend * 100).toStringAsFixed(0),
      'faktorKonsistensi': (faktorKonsistensi * 100).toStringAsFixed(0),
      'faktorPersaingan': (faktorPersaingan * 100).toStringAsFixed(0),
      'passingRate': passingRate.toStringAsFixed(1),
      'rekomendasi': rekomendasi,
      'color': _getColorByPercentage(totalPeluang),
      'userPercentile': userPercentile?.toStringAsFixed(1) ?? 'N/A',
      'nationalMean': nationalMean?.toStringAsFixed(0) ?? 'N/A',
    };
  }

  String _generateNationalRecommendation({
    required int currentScore,
    required int targetScore,
    required int selisih,
    required double faktorNilai,
    required double faktorTrend,
    required double faktorKonsistensi,
    required double passingRate,
    required double totalPeluang,
    required double? userPercentile,
    required double? nationalMean,
  }) {
    List<String> rekomendasi = [];

    if (faktorNilai < 0.5) {
      rekomendasi.add(
        'Target nilai terlalu tinggi. Butuh peningkatan ${selisih.abs()} poin.',
      );
    } else if (faktorNilai < 0.8) {
      rekomendasi.add('Perlu peningkatan ${selisih.abs()} poin lagi.');
    } else {
      rekomendasi.add('Nilai Anda sudah memenuhi target!');
    }

    if (userPercentile != null) {
      if (userPercentile >= 80) {
        rekomendasi.add(
          'Anda berada di ${userPercentile.toStringAsFixed(0)}% teratas nasional!',
        );
      } else if (userPercentile >= 60) {
        rekomendasi.add('Anda berada di atas rata-rata nasional.');
      } else if (userPercentile >= 40) {
        rekomendasi.add('Anda berada di sekitar rata-rata nasional.');
      } else if (userPercentile >= 20) {
        rekomendasi.add('Anda berada di bawah rata-rata nasional.');
      } else {
        rekomendasi.add(
          'Peringkat Anda masih rendah. Perlu peningkatan signifikan.',
        );
      }
    }

    if (faktorKonsistensi > 0.7) {
      rekomendasi.add('Nilai Anda sangat kompetitif secara nasional!');
    } else if (faktorKonsistensi < 0.3) {
      rekomendasi.add('Nilai Anda masih perlu ditingkatkan untuk bersaing.');
    }

    if (passingRate < 5) {
      rekomendasi.add(
        'Prodi ini sangat kompetitif (persaingan ${passingRate.toStringAsFixed(1)}%).',
      );
    } else if (passingRate > 10) {
      rekomendasi.add('Prodi ini memiliki peluang lebih besar.');
    }

    if (nationalMean != null && currentScore < nationalMean) {
      rekomendasi.add(
        'Targetkan nilai minimal ${nationalMean.toStringAsFixed(0)} (rata-rata nasional).',
      );
    }

    return rekomendasi.join(' ');
  }

  String _getColorByPercentage(double percentage) {
    if (percentage >= 80) return '#4CAF50';
    if (percentage >= 60) return '#8BC34A';
    if (percentage >= 40) return '#FFC107';
    if (percentage >= 20) return '#FF9800';
    return '#F44336';
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

  Future<Map<String, dynamic>> loadAllStatistikData(int userId) async {
    try {
      final currentScore = await getUserCurrentScore(userId);
      final ptnList = await getAllPTN();
      final existingPilihan = await getPilihanWithDetails(userId);

      Map<int, List<Map<String, dynamic>>> prodiMap = {};
      for (var pilihan in existingPilihan) {
        final ptnId = pilihan['ptn_id'] as int;
        if (!prodiMap.containsKey(ptnId)) {
          prodiMap[ptnId] = await getProdiByPTN(ptnId);
        }
      }

      return {
        'currentScore': currentScore,
        'ptnList': ptnList,
        'existingPilihan': existingPilihan,
        'prodiMap': prodiMap,
      };
    } catch (e) {
      print('Error loading all statistik data: $e');
      return {};
    }
  }

  Future<int?> loadCurrentScore(int userId) async {
    return await getUserCurrentScore(userId);
  }

  Future<List<Map<String, dynamic>>> loadPTNList() async {
    return await getAllPTN();
  }

  Future<List<Map<String, dynamic>>> loadUserPilihan(int userId) async {
    return await getPilihanWithDetails(userId);
  }

  Future<List<Map<String, dynamic>>> loadProdiByPTN(int ptnId) async {
    return await getProdiByPTN(ptnId);
  }

  Future<int?> getTargetScoreByProdiId(int prodiId) async {
    final prodi = await getProdiById(prodiId);
    if (prodi != null && prodi.containsKey('target_score')) {
      return prodi['target_score'] as int;
    }
    return null;
  }

  Future<Map<int, Map<String, dynamic>>> processUserPilihan(int userId) async {
    final pilihan = await loadUserPilihan(userId);
    Map<int, Map<String, dynamic>> result = {};

    for (var p in pilihan) {
      final urutan = p['urutan'] as int;
      final ptnId = p['ptn_id'] as int;
      final prodiId = p['prodi_id'] as int;
      final targetScore = p['target_score'] as int;
      final prodiList = await loadProdiByPTN(ptnId);

      result[urutan] = {
        'ptnId': ptnId,
        'prodiId': prodiId,
        'targetScore': targetScore,
        'prodiList': prodiList,
        'ptnNama': p['ptn_nama'],
        'prodiNama': p['prodi_nama'],
      };
    }

    return result;
  }

  bool isPilihanValid(Map<int, Map<String, dynamic>> pilihanData) {
    return pilihanData.isNotEmpty;
  }

  Future<bool> saveAllPilihan(
    int userId,
    Map<int, Map<String, dynamic>> pilihanData,
  ) async {
    try {
      for (var entry in pilihanData.entries) {
        final urutan = entry.key;
        final data = entry.value;
        final ptnId = data['ptnId'] as int;
        final prodiId = data['prodiId'] as int;

        await savePilihan(userId, urutan, ptnId, prodiId);
      }
      return true;
    } catch (e) {
      print('Error saving all pilihan: $e');
      return false;
    }
  }
}
