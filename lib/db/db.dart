import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            nama TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE ptn (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            kota TEXT,
            akreditasi TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE prodi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ptn_id INTEGER,
            nama TEXT NOT NULL,
            jenjang TEXT,
            daya_tampung INTEGER,
            peminat INTEGER,
            target_score INTEGER DEFAULT 600,
            FOREIGN KEY (ptn_id) REFERENCES ptn(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE score (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            penalaran_umum INTEGER,
            pengetahuan_pemahaman_umum INTEGER,
            pemahaman_bacaan_menulis INTEGER,
            pengetahuan_kuantitatif INTEGER,
            literasi_bahasa_indonesia INTEGER,
            literasi_bahasa_inggris INTEGER,
            penalaran_matematika INTEGER,
            total_score INTEGER,
            tanggal_input DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE pilihan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            urutan INTEGER NOT NULL,
            ptn_id INTEGER NOT NULL,
            prodi_id INTEGER NOT NULL,
            tanggal_input DATETIME DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(user_id, urutan),
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (ptn_id) REFERENCES ptn(id),
            FOREIGN KEY (prodi_id) REFERENCES prodi(id)
          )
        ''');

        await db.insert('ptn', {
          'nama': 'ITS',
          'kota': 'Surabaya',
          'akreditasi': 'A',
        });

        await db.insert('ptn', {
          'nama': 'UI',
          'kota': 'Depok',
          'akreditasi': 'A',
        });

        await db.insert('ptn', {
          'nama': 'UGM',
          'kota': 'Yogyakarta',
          'akreditasi': 'A',
        });

        await db.insert('ptn', {
          'nama': 'ITB',
          'kota': 'Bandung',
          'akreditasi': 'A',
        });

        await db.insert('ptn', {
          'nama': 'UNAIR',
          'kota': 'Surabaya',
          'akreditasi': 'A',
        });

        await db.insert('ptn', {
          'nama': 'UNBRAW',
          'kota': 'Malang',
          'akreditasi': 'A',
        });

        await db.insert('prodi', {
          'ptn_id': 1,
          'nama': 'Teknik Informatika',
          'jenjang': 'S1',
          'daya_tampung': 120,
          'peminat': 3500,
          'target_score': 680,
        });
        await db.insert('prodi', {
          'ptn_id': 1,
          'nama': 'Teknik Elektro',
          'jenjang': 'S1',
          'daya_tampung': 100,
          'peminat': 2800,
          'target_score': 650,
        });
        await db.insert('prodi', {
          'ptn_id': 1,
          'nama': 'Sistem Informasi',
          'jenjang': 'S1',
          'daya_tampung': 90,
          'peminat': 4200,
          'target_score': 690,
        });
        await db.insert('prodi', {
          'ptn_id': 1,
          'nama': 'Teknik Mesin',
          'jenjang': 'S1',
          'daya_tampung': 110,
          'peminat': 2000,
          'target_score': 630,
        });

        await db.insert('prodi', {
          'ptn_id': 2,
          'nama': 'Ilmu Komputer',
          'jenjang': 'S1',
          'daya_tampung': 150,
          'peminat': 5000,
          'target_score': 700,
        });
        await db.insert('prodi', {
          'ptn_id': 2,
          'nama': 'Kedokteran',
          'jenjang': 'S1',
          'daya_tampung': 60,
          'peminat': 8000,
          'target_score': 750,
        });
        await db.insert('prodi', {
          'ptn_id': 2,
          'nama': 'Hukum',
          'jenjang': 'S1',
          'daya_tampung': 200,
          'peminat': 4500,
          'target_score': 640,
        });
        await db.insert('prodi', {
          'ptn_id': 2,
          'nama': 'Psikologi',
          'jenjang': 'S1',
          'daya_tampung': 120,
          'peminat': 6000,
          'target_score': 670,
        });

        await db.insert('prodi', {
          'ptn_id': 3,
          'nama': 'Teknik Sipil',
          'jenjang': 'S1',
          'daya_tampung': 140,
          'peminat': 3000,
          'target_score': 660,
        });
        await db.insert('prodi', {
          'ptn_id': 3,
          'nama': 'Farmasi',
          'jenjang': 'S1',
          'daya_tampung': 80,
          'peminat': 7000,
          'target_score': 720,
        });
        await db.insert('prodi', {
          'ptn_id': 3,
          'nama': 'Ekonomi',
          'jenjang': 'S1',
          'daya_tampung': 180,
          'peminat': 5500,
          'target_score': 650,
        });

        await db.insert('prodi', {
          'ptn_id': 4,
          'nama': 'Teknik Mesin',
          'jenjang': 'S1',
          'daya_tampung': 110,
          'peminat': 4000,
          'target_score': 670,
        });
        await db.insert('prodi', {
          'ptn_id': 4,
          'nama': 'Teknik Informatika',
          'jenjang': 'S1',
          'daya_tampung': 100,
          'peminat': 6500,
          'target_score': 730,
        });
        await db.insert('prodi', {
          'ptn_id': 4,
          'nama': 'Arsitektur',
          'jenjang': 'S1',
          'daya_tampung': 90,
          'peminat': 5000,
          'target_score': 680,
        });

        await db.insert('prodi', {
          'ptn_id': 5,
          'nama': 'Kedokteran',
          'jenjang': 'S1',
          'daya_tampung': 100,
          'peminat': 6000,
          'target_score': 710,
        });
        await db.insert('prodi', {
          'ptn_id': 5,
          'nama': 'Farmasi',
          'jenjang': 'S1',
          'daya_tampung': 90,
          'peminat': 4500,
          'target_score': 680,
        });

        await db.insert('prodi', {
          'ptn_id': 6,
          'nama': 'Teknik Informatika',
          'jenjang': 'S1',
          'daya_tampung': 80,
          'peminat': 3000,
          'target_score': 640,
        });
        await db.insert('prodi', {
          'ptn_id': 6,
          'nama': 'Sistem Informasi',
          'jenjang': 'S1',
          'daya_tampung': 70,
          'peminat': 2500,
          'target_score': 630,
        });

        await db.insert('users', {
          'email': 'admin@mail.com',
          'password': '123456',
          'nama': 'Administrator',
        });

        await db.insert('users', {
          'email': 'budi@mail.com',
          'password': 'budi123',
          'nama': 'Budi Santoso',
        });

        await db.insert('users', {
          'email': 'siti@mail.com',
          'password': 'siti123',
          'nama': 'Siti Aisyah',
        });

        await db.insert('users', {
          'email': 'andi@mail.com',
          'password': 'andi123',
          'nama': 'Andi Wijaya',
        });

        await db.insert('users', {
          'email': 'dewi@mail.com',
          'password': 'dewi123',
          'nama': 'Dewi Kartika',
        });

        await db.insert('users', {
          'email': 'rudi@mail.com',
          'password': 'rudi123',
          'nama': 'Rudi Hermawan',
        });

        await db.insert('score', {
          'user_id': 2,
          'penalaran_umum': 650,
          'pengetahuan_pemahaman_umum': 700,
          'pemahaman_bacaan_menulis': 680,
          'pengetahuan_kuantitatif': 720,
          'literasi_bahasa_indonesia': 750,
          'literasi_bahasa_inggris': 700,
          'penalaran_matematika': 680,
          'total_score': 697,
          'tanggal_input': '2024-01-15 10:00:00',
        });
        await db.insert('score', {
          'user_id': 2,
          'penalaran_umum': 700,
          'pengetahuan_pemahaman_umum': 720,
          'pemahaman_bacaan_menulis': 700,
          'pengetahuan_kuantitatif': 750,
          'literasi_bahasa_indonesia': 780,
          'literasi_bahasa_inggris': 720,
          'penalaran_matematika': 700,
          'total_score': 724,
          'tanggal_input': '2024-02-10 10:00:00',
        });
        await db.insert('score', {
          'user_id': 2,
          'penalaran_umum': 750,
          'pengetahuan_pemahaman_umum': 750,
          'pemahaman_bacaan_menulis': 720,
          'pengetahuan_kuantitatif': 780,
          'literasi_bahasa_indonesia': 800,
          'literasi_bahasa_inggris': 750,
          'penalaran_matematika': 730,
          'total_score': 754,
          'tanggal_input': '2024-03-05 10:00:00',
        });

        await db.insert('score', {
          'user_id': 3,
          'penalaran_umum': 580,
          'pengetahuan_pemahaman_umum': 600,
          'pemahaman_bacaan_menulis': 550,
          'pengetahuan_kuantitatif': 620,
          'literasi_bahasa_indonesia': 600,
          'literasi_bahasa_inggris': 550,
          'penalaran_matematika': 580,
          'total_score': 583,
          'tanggal_input': '2024-01-20 10:00:00',
        });
        await db.insert('score', {
          'user_id': 3,
          'penalaran_umum': 600,
          'pengetahuan_pemahaman_umum': 620,
          'pemahaman_bacaan_menulis': 580,
          'pengetahuan_kuantitatif': 630,
          'literasi_bahasa_indonesia': 620,
          'literasi_bahasa_inggris': 580,
          'penalaran_matematika': 600,
          'total_score': 604,
          'tanggal_input': '2024-02-18 10:00:00',
        });

        await db.insert('score', {
          'user_id': 4,
          'penalaran_umum': 520,
          'pengetahuan_pemahaman_umum': 500,
          'pemahaman_bacaan_menulis': 480,
          'pengetahuan_kuantitatif': 550,
          'literasi_bahasa_indonesia': 500,
          'literasi_bahasa_inggris': 450,
          'penalaran_matematika': 500,
          'total_score': 500,
          'tanggal_input': '2024-01-10 10:00:00',
        });
        await db.insert('score', {
          'user_id': 4,
          'penalaran_umum': 480,
          'pengetahuan_pemahaman_umum': 450,
          'pemahaman_bacaan_menulis': 450,
          'pengetahuan_kuantitatif': 500,
          'literasi_bahasa_indonesia': 480,
          'literasi_bahasa_inggris': 420,
          'penalaran_matematika': 450,
          'total_score': 461,
          'tanggal_input': '2024-02-05 10:00:00',
        });

        await db.insert('score', {
          'user_id': 5,
          'penalaran_umum': 850,
          'pengetahuan_pemahaman_umum': 880,
          'pemahaman_bacaan_menulis': 820,
          'pengetahuan_kuantitatif': 900,
          'literasi_bahasa_indonesia': 850,
          'literasi_bahasa_inggris': 880,
          'penalaran_matematika': 850,
          'total_score': 861,
          'tanggal_input': '2024-01-25 10:00:00',
        });
        await db.insert('score', {
          'user_id': 5,
          'penalaran_umum': 880,
          'pengetahuan_pemahaman_umum': 900,
          'pemahaman_bacaan_menulis': 850,
          'pengetahuan_kuantitatif': 920,
          'literasi_bahasa_indonesia': 880,
          'literasi_bahasa_inggris': 900,
          'penalaran_matematika': 880,
          'total_score': 887,
          'tanggal_input': '2024-02-20 10:00:00',
        });
        await db.insert('score', {
          'user_id': 5,
          'penalaran_umum': 900,
          'pengetahuan_pemahaman_umum': 920,
          'pemahaman_bacaan_menulis': 880,
          'pengetahuan_kuantitatif': 950,
          'literasi_bahasa_indonesia': 900,
          'literasi_bahasa_inggris': 920,
          'penalaran_matematika': 900,
          'total_score': 910,
          'tanggal_input': '2024-03-15 10:00:00',
        });

        await db.insert('score', {
          'user_id': 6,
          'penalaran_umum': 620,
          'pengetahuan_pemahaman_umum': 580,
          'pemahaman_bacaan_menulis': 600,
          'pengetahuan_kuantitatif': 650,
          'literasi_bahasa_indonesia': 600,
          'literasi_bahasa_inggris': 550,
          'penalaran_matematika': 620,
          'total_score': 603,
          'tanggal_input': '2024-01-05 10:00:00',
        });
        await db.insert('score', {
          'user_id': 6,
          'penalaran_umum': 750,
          'pengetahuan_pemahaman_umum': 700,
          'pemahaman_bacaan_menulis': 720,
          'pengetahuan_kuantitatif': 680,
          'literasi_bahasa_indonesia': 650,
          'literasi_bahasa_inggris': 700,
          'penalaran_matematika': 750,
          'total_score': 707,
          'tanggal_input': '2024-01-28 10:00:00',
        });
        await db.insert('score', {
          'user_id': 6,
          'penalaran_umum': 550,
          'pengetahuan_pemahaman_umum': 520,
          'pemahaman_bacaan_menulis': 500,
          'pengetahuan_kuantitatif': 580,
          'literasi_bahasa_indonesia': 550,
          'literasi_bahasa_inggris': 480,
          'penalaran_matematika': 520,
          'total_score': 529,
          'tanggal_input': '2024-02-25 10:00:00',
        });
        await db.insert('score', {
          'user_id': 6,
          'penalaran_umum': 700,
          'pengetahuan_pemahaman_umum': 680,
          'pemahaman_bacaan_menulis': 650,
          'pengetahuan_kuantitatif': 720,
          'literasi_bahasa_indonesia': 680,
          'literasi_bahasa_inggris': 650,
          'penalaran_matematika': 700,
          'total_score': 683,
          'tanggal_input': '2024-03-20 10:00:00',
        });

        await db.insert('pilihan', {
          'user_id': 2,
          'urutan': 1,
          'ptn_id': 1,
          'prodi_id': 1,
        });
        await db.insert('pilihan', {
          'user_id': 2,
          'urutan': 2,
          'ptn_id': 4,
          'prodi_id': 10,
        });
        await db.insert('pilihan', {
          'user_id': 2,
          'urutan': 3,
          'ptn_id': 2,
          'prodi_id': 5,
        });

        await db.insert('pilihan', {
          'user_id': 3,
          'urutan': 1,
          'ptn_id': 2,
          'prodi_id': 7,
        });
        await db.insert('pilihan', {
          'user_id': 3,
          'urutan': 2,
          'ptn_id': 3,
          'prodi_id': 9,
        });

        await db.insert('pilihan', {
          'user_id': 4,
          'urutan': 1,
          'ptn_id': 6,
          'prodi_id': 15,
        });
        await db.insert('pilihan', {
          'user_id': 4,
          'urutan': 2,
          'ptn_id': 1,
          'prodi_id': 4,
        });

        await db.insert('pilihan', {
          'user_id': 5,
          'urutan': 1,
          'ptn_id': 2,
          'prodi_id': 6,
        });
        await db.insert('pilihan', {
          'user_id': 5,
          'urutan': 2,
          'ptn_id': 5,
          'prodi_id': 13,
        });
        await db.insert('pilihan', {
          'user_id': 5,
          'urutan': 3,
          'ptn_id': 3,
          'prodi_id': 8,
        });

        await db.insert('pilihan', {
          'user_id': 6,
          'urutan': 1,
          'ptn_id': 1,
          'prodi_id': 3,
        });
        await db.insert('pilihan', {
          'user_id': 6,
          'urutan': 2,
          'ptn_id': 6,
          'prodi_id': 16,
        });
      },
    );
  }
}
