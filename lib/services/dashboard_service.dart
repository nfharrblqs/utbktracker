
import 'package:utbktracker/db/db.dart';
import 'package:sqflite/sqflite.dart';

class DashboardService {
  static DashboardService? _instance;
  DashboardService._internal();

  factory DashboardService() {
    _instance ??= DashboardService._internal();
    return _instance!;
  }

  Future<Database> get database async => await DB.database;

  
  Future<bool> savePilihan({
    required int userId,
    required int urutan,
    required int ptnId,
    required int prodiId,
  }) async {
    final db = await database;
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
          where: 'user_id = ? AND urutan = ?',
          whereArgs: [userId, urutan],
        );
      } else {
        
        await db.insert('pilihan', {
          'user_id': userId,
          'urutan': urutan,
          'ptn_id': ptnId,
          'prodi_id': prodiId,
          'tanggal_input': DateTime.now().toIso8601String(),
        });
      }
      return true;
    } catch (e) {
      print('Error saving pilihan: $e');
      return false;
    }
  }

  
  Future<List<Map<String, dynamic>>> getPilihanByUser(int userId) async {
    final db = await database;
    try {
      final result = await db.rawQuery(
        '''
        SELECT 
          p.id,
          p.urutan,
          p.ptn_id,
          p.prodi_id,
          p.tanggal_input,
          ptn.nama as ptn_nama,
          ptn.kota,
          ptn.akreditasi,
          prodi.nama as prodi_nama,
          prodi.jenjang,
          prodi.daya_tampung,
          prodi.peminat,
          prodi.target_score
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
      print('Error getting pilihan: $e');
      return [];
    }
  }

  
  Future<Map<String, dynamic>?> getPilihanByUrutan(
    int userId,
    int urutan,
  ) async {
    final db = await database;
    try {
      final result = await db.rawQuery(
        '''
        SELECT 
          p.urutan,
          p.ptn_id,
          p.prodi_id,
          ptn.nama as ptn_nama,
          ptn.kota,
          prodi.nama as prodi_nama,
          prodi.jenjang,
          prodi.target_score,
          prodi.daya_tampung,
          prodi.peminat
        FROM pilihan p
        JOIN ptn ON p.ptn_id = ptn.id
        JOIN prodi ON p.prodi_id = prodi.id
        WHERE p.user_id = ? AND p.urutan = ?
      ''',
        [userId, urutan],
      );

      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting pilihan by urutan: $e');
      return null;
    }
  }

  
  Future<bool> deletePilihan(int userId, int urutan) async {
    final db = await database;
    try {
      await db.delete(
        'pilihan',
        where: 'user_id = ? AND urutan = ?',
        whereArgs: [userId, urutan],
      );
      return true;
    } catch (e) {
      print('Error deleting pilihan: $e');
      return false;
    }
  }

  
  Future<bool> deleteAllPilihan(int userId) async {
    final db = await database;
    try {
      await db.delete('pilihan', where: 'user_id = ?', whereArgs: [userId]);
      return true;
    } catch (e) {
      print('Error deleting all pilihan: $e');
      return false;
    }
  }

  
  Map<String, dynamic> hitungPeluang({
    required int currentScore,
    required int targetScore,
    required int dayaTampung,
    required int peminat,
  }) {
    final selisih = targetScore - currentScore;
    final passingRate = peminat > 0 ? (dayaTampung / peminat) * 100 : 0;

    String statusPeluang;
    String rekomendasi;

    if (selisih <= 0) {
      statusPeluang = 'Tinggi';
      rekomendasi = 'Skor Anda sudah memenuhi target! Pertahankan performa.';
    } else if (selisih <= 50) {
      statusPeluang = 'Cukup';
      rekomendasi =
          'Perlu peningkatan $selisih poin. Fokus pada tryout rutin.';
    } else if (selisih <= 100) {
      statusPeluang = 'Rendah';
      rekomendasi =
          'Butuh peningkatan $selisih poin. Ikuti bimbingan belajar.';
    } else {
      statusPeluang = 'Sangat Rendah';
      rekomendasi = 'Pertimbangkan prodi lain atau persiapan lebih matang.';
    }

    return {
      'statusPeluang': statusPeluang,
      'selisih': selisih,
      'passingRate': passingRate,
      'rekomendasi': rekomendasi,
      'targetScore': targetScore,
    };
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
}
