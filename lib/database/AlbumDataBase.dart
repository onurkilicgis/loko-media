import 'package:loko_media/models/Album.dart';
import 'package:loko_media/services/MyLocal.dart';
import 'package:loko_media/view_model/folder_model.dart';
import 'package:sqflite/sqflite.dart';

class AlbumDataBase {
  static const String _albumDatabaseName = 'albumdatabase6.db';
  static const String albumTableName = 'albums';
  static const String fileTableName = 'medias';
  static const int _version = 1;

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
           itemCount INTEGER DEFAULT 0 NOT NULL,
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
           latitude REAL DEFAULT 0 NOT NULL,
           longitude REAL DEFAULT 0 NOT NULL,
           altitude REAL DEFAULT 0 NOT NULL, 
           status BOOLEAN DEFAULT true NOT NULL) ''');
      db.close();
    });
  }

  static insertAlbum(Album album, Function callback) async {
    Database database = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    int lastid = await database.insert(albumTableName, album.toJson());

    await MyLocal.setIntData('aktifalbum', lastid);
    //albüm oluşturulurken albümün id bilgisini aldığında bu albüms klasörünü içerisinde album-(id) olacak şekilde bir klasör oluştur
    await FolderModel.createFolder('albums/album-${lastid}');

    database.close();
    callback(lastid);
  }

  static insertFile(Medias media, Function callback) async {
    Album? album = await getAAlbum(media.album_id!);
    album?.itemCount = album.itemCount! + 1;
    album?.image = media.path;
    String asd = 'Asd';
    int deger = await updateAAlbum(album!);
    Database database = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    int lastid = await database.insert(fileTableName, media.toJson());
    database.close();
    callback(lastid);
  }

  static Future<int> updateAAlbum(Album album) async {
    Database db = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    int deger = await db.update(albumTableName, album.toJson(),
        where: 'id = ?', whereArgs: [album.id]);
    db.close();
    return deger;
  }

  Future<List<Album>> getAlbums() async {
    List<Album> liste = [];
    Database db = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    List<Map> albumMaps = await db.query(albumTableName, orderBy: 'id desc');
    db.close();
    if (albumMaps.length > 0) {
      liste = albumMaps.map((e) => Album.fromJson(e)).toList();
    }
    return liste;
  }

  static getFiles() {
    // geri dönüş değerli List<Files> olacak
  }

  static Future<Album?> getAAlbum(int id) async {
    Database db = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});

    List<Map> maps = await db.query(albumTableName,
        columns: [
          "id",
          "uid",
          "name",
          "isPublic",
          "url",
          "image",
          "status",
          "itemCount",
        ],
        where: 'id = ?',
        whereArgs: [id]);
    db.close();
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
