import 'package:loko_media/models/Album.dart';
import 'package:sqflite/sqflite.dart';

class AlbumDataBase {
  static const String _albumDatabaseName = 'albumdatabase4.db';
  static const String albumTableName = 'albums';
  static const String fileTableName = 'files';
  static const int _version = 1;
  late Database database;

  static createTables() async {
    await openDatabase(_albumDatabaseName, version: _version,
        onCreate: (Database db, int version) async {
      await db.execute('''CREATE TABLE IF NOT EXISTS $albumTableName ( 
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           uid TEXT,
           name TEXT, 
           isPublic BOOLEAN DEFAULT false NOT NULL,
           url TEXT DEFAULT '' NOT NULL,
           image TEXT,
           date TEXT,
           status BOOLEAN DEFAULT true NOT NULL) ''');

      await db.execute('''CREATE TABLE IF NOT EXISTS $fileTableName ( 
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           album_id INTEGER,
           name TEXT, 
           fileType VARCHAR(10),
           path TEXT,
           isPublic BOOLEAN DEFAULT false NOT NULL,
           url TEXT DEFAULT '' NOT NULL,
           api_id INTEGER DEFAULT 0 NOT NULL,
           date TEXT,
           status BOOLEAN DEFAULT true NOT NULL) ''');
      db.close();
    });
  }

  static insertAlbum(Album album, Function callback) async {
    Database database = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    int lastid = await database.insert(albumTableName, album.toJson());
    callback(lastid);
  }

  static insertFile() {}

  /* Future<List<Map<String, Object?>>> getAlbums() async {
    var result = await database.query("Album", columns: [
      "id",
      "uid",
      "albumName",
      "isPublic",
      "url",
      "image",
      "status"
    ]);
    return result.toList();
  }*/

  Future<List<Album>> getAlbums() async {
    List<Album> liste = [];
    Database db = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    List<Map> albumMaps = await db.query(albumTableName);
    if (albumMaps.length > 0) {
      liste = albumMaps.map((e) => Album.fromJson(e)).toList();
    }
    return liste;
  }

  static getFiles() {
    // geri dönüş değerli List<Files> olacak
  }

  Future<Album?> getAAlbum(int id) async {
    List<Map> maps = await database.query(albumTableName,
        columns: [
          "id",
          "uid",
          "albumName",
          "isPublic",
          "url",
          "image",
          "status"
        ],
        where: 'id = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Album.fromJson(maps.first);
    }
    return null;
  }

  static getAFile(int id) {
    // geri dönüş değerli Files olacak
  }

  static getPublicAlbums() {
    // geri dönüş değerli List<Album> olacak
  }

  static getPublicFiles() {
    // geri dönüş değerli List<Files> olacak
  }
}
