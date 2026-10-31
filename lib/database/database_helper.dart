import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/place_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(join(dbPath, 'place_db.db'), version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE places ADD COLUMN imagePath TEXT NOT NULL DEFAULT 'assets/images/1.jpg'");
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
  CREATE TABLE places (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    rating REAL NOT NULL,
    phone TEXT NOT NULL,
    address TEXT NOT NULL,
    imagePath TEXT NOT NULL DEFAULT 'assets/images/1.jpg'
  )
''');
        // Du lieu minh hoa duoc them duy nhat khi tao CSDL lan dau.
        final samples = <Map<String, Object>>[
          {'name': 'Ho Guom', 'rating': 4.8, 'phone': '', 'address': 'Hoan Kiem, Ha Noi'},
          {'name': 'Pho co Hoi An', 'rating': 4.9, 'phone': '', 'address': 'Hoi An, Da Nang'},
          {'name': 'Ba Na Hills', 'rating': 4.7, 'phone': '', 'address': 'Hoa Vang, Da Nang'},
          {'name': 'Ho Xuan Huong', 'rating': 4.6, 'phone': '', 'address': 'Da Lat, Lam Dong'},
          {'name': 'Cho Ben Thanh', 'rating': 4.5, 'phone': '', 'address': 'Phuong Ben Thanh, TP. Ho Chi Minh'},
          {'name': 'Dai Noi Hue', 'rating': 4.8, 'phone': '', 'address': 'Phu Xuan, Hue'},
          {'name': 'Vinh Ha Long', 'rating': 4.9, 'phone': '', 'address': 'Quang Ninh'},
          {'name': 'Nha Trang', 'rating': 4.7, 'phone': '', 'address': 'Khanh Hoa'},
        ];
        for (final sample in samples) {
          await db.insert('places', {...sample, 'imagePath': 'assets/images/${(samples.indexOf(sample) % 12) + 1}.jpg'});
        }
      });
    return _database!;
  }

  Future<int> insertPlace(Place place) async =>
      (await database).insert('places', place.toMap());

  Future<List<Place>> getAllPlaces() async {
    final rows = await (await database).query('places', orderBy: 'id DESC');
    return rows.map((row) => Place.fromMap(row)).toList();
  }

  Future<int> deletePlace(int id) async =>
      (await database).delete('places', where: 'id = ?', whereArgs: [id]);
}
