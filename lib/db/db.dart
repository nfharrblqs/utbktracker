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
            password TEXT
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

        await db.insert('users', {
          'email': 'admin@mail.com',
          'password': '123456',
        });

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
          'ptn_id': 3,
          'nama': 'Teknik Sipil',
          'jenjang': 'S1',
          'daya_tampung': 140,
          'peminat': 3000,
          'target_score': 660,
        });

        await db.insert('prodi', {
          'ptn_id': 3,
          'nama': 'Psikologi',
          'jenjang': 'S1',
          'daya_tampung': 120,
          'peminat': 6000,
          'target_score': 700,
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
      },
    );
  }
}
