import 'dart:convert';
import 'dart:io' as ioo;

import 'package:loko_media/models/Album.dart';
import 'package:loko_media/services/MyLocal.dart';
import 'package:loko_media/view_model/folder_model.dart';
import 'package:sqflite/sqflite.dart';

class AlbumDataBase {
  static const String _albumDatabaseName = 'albumdatabase9.db';
  static const String albumTableName = 'albums';
  static const String mediaTableName = 'medias';
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

      await db.execute('''CREATE TABLE IF NOT EXISTS $mediaTableName ( 
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           album_id INTEGER,
           name TEXT, 
           miniName TEXT,
           fileType VARCHAR(10),
           path TEXT,
           isPublic BOOLEAN DEFAULT false NOT NULL,
           url TEXT DEFAULT '' NOT NULL,
           api_id INTEGER DEFAULT 0 NOT NULL,
           date TEXT,
           settings TEXT,
           latitude REAL DEFAULT 0 NOT NULL,
           longitude REAL DEFAULT 0 NOT NULL,
           altitude REAL DEFAULT 0 NOT NULL, 
           status BOOLEAN DEFAULT true NOT NULL) ''');
      db.close();
    });
  }

  static insertAlbum(Album album) async {
    Database database = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    int lastid = await database.insert(albumTableName, album.toJson());

    await MyLocal.setIntData('aktifalbum', lastid);
    //albüm oluşturulurken albümün id bilgisini aldığında bu albüms klasörünü içerisinde album-(id) olacak şekilde bir klasör oluştur
    await FolderModel.createFolder('albums/album-${lastid}');

    database.close();
    return lastid;
  }

  static insertFile(Medias media, String minipath, Function callback) async {
    Album? album = await getAAlbum(media.album_id!);
    album?.itemCount = album.itemCount! + 1;
    album?.image = minipath;
    int deger = await updateAAlbum(album!);
    Database database = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    int lastid = await database.insert(mediaTableName, media.toJson());
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

  static Future<List<Album>> getAlbums() async {
    List<Album> liste = [];
    Database db = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    List<Map> albumMaps = await db.query(
      albumTableName,
      orderBy: 'id desc',
    );

    db.close();
    if (albumMaps.length > 0) {
      liste = albumMaps.map((e) => Album.fromJson(e)).toList();
    }
    return liste;
  }

  static getFiles(int album_id) async {
    List<Medias> liste = [];
    Database db = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    List<Map> fileMaps = await db.query(mediaTableName,
        orderBy: 'id desc', where: 'album_id= ?', whereArgs: [album_id]);
    db.close();
    if (fileMaps.length > 0) {
      liste = fileMaps.map((e) => Medias.fromJson(e)).toList();
    }

    return liste;
  }

// silindikten sonraki son albümü aktif etme
  static getLastAlbum() async {
    List<Album> liste = [];
    Database db = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    List<Map> albumMaps =
        await db.query(albumTableName, orderBy: 'id desc', limit: 1);
    if (albumMaps.length > 0) {
      liste = albumMaps.map((e) => Album.fromJson(e)).toList();
    }
    if (liste.length == 1) {
      return liste[0].id;
    } else {
      return -1;
    }
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
          "date",
          "itemCount",
          "status",
        ],
        where: 'id = ?',
        whereArgs: [id]);
    db.close();
    if (maps.length > 0) {
      return Album.fromJson(maps.first);
    }
    return null;
  }

  static getAFile(int id) async {
    Database db = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});

    List<Map> maps = await db.query(mediaTableName,
        columns: [
          "id",
          "album_id",
          "name",
          "fileType",
          "path",
          "isPublic",
          "url",
          "api_id",
          "date",
          "latitude"
              "longitude",
          "altitude",
          "status"
        ],
        where: 'id = ?',
        whereArgs: [id]);
    db.close();
    if (maps.length > 0) {
      return Medias.fromJson(maps.first);
    }
    return null;
  }

  static getPublicAlbums() {
    // geri dönüş değerli List<Album> olacak
  }

  static getPublicFiles() {
    // geri dönüş değerli List<Files> olacak
  }

// id bilgisi üzerinden album  silme
  static albumDelete(int id) async {
    Database db = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    int result =
        await db.delete(albumTableName, where: 'id = ?', whereArgs: [id]);
    db.close();
    return result;
  }

  //album_id üzerinden veritabanına kayıtlı dosyaları silme
  static mediaDelete(int album_id) async {
    Database db = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    int result = await db
        .delete(mediaTableName, where: 'album_id = ?', whereArgs: [album_id]);
    db.close();
    return result;
  }

  // medya'yı veritabanından siler ve , silinen kayıt sayısını verir
  static mediaADelete(int id) async {
    Database db = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    int result =
        await db.delete(mediaTableName, where: 'id=?', whereArgs: [id]);
    db.close();
    return result;
  }

  // albüm yokken bir medya yüklenmek istenirse otomatik albüm oluşturmak için hazırlanmıştır.
  static createAlbumIfTableEmpty(String albumName) async {
    String userString = await MyLocal.getStringData('user');
    dynamic user = json.decode(userString);
    List<Album> list = await getAlbums();
    if (list.length == 0) {
      Album album = Album();
      album.insertData(albumName, user['uid']);
      await insertAlbum(album);
    }
  }

  // media listesi olarak verilmiş olan kayıtları hem fiziksel hem de veritabanından siler.
  static mediaMultiDelete(List<int> selecteds) async {
    List<Medias> liste = [];
    Database db = await openDatabase(_albumDatabaseName,
        version: _version, onCreate: (Database db, int version) async {});
    List<Map> list = await db.query(mediaTableName,
        where: 'id IN (${List.filled(selecteds.length, '?').join(',')})',
        whereArgs: selecteds);
    liste = list.map((e) => Medias.fromJson(e)).toList();
    for (int i = 0; i < liste.length; i++) {
      ioo.File(liste[i].path!).delete();
    }
    int silinenDosyaSayisi = await db.delete(mediaTableName,
        where: 'id IN (${List.filled(selecteds.length, '?').join(',')})',
        whereArgs: selecteds);
    db.close();
    return silinenDosyaSayisi;
  }
}

/* static benAsenkronDegilim(String parametre1, Function parametre2) {
    //işlemler yaptım
    // bir değer döndürmem lazım ancak return ile değil
    //o zaman geri döndürmem gereken değeri parametre2 fonksiyonunu kullanarak geri gönderebilirim
    // aşağıda elde ettiğimi farzettiğim bir veriyi geri göndermeyi sağladım
    parametre2(parametre1);
  }

  //bu fonksiyonu dışarda bir yerde çalıştırman durumunda
  //benAsenkronDegilim fonksiyonunu çalıştırır,
  // benAsenkronDegilim fonksiyonu da işlemini yaptığında parametre2'yi köprü olarak kullanır ve veri gönderir
  // birIslemYap foksiyonu içinde (geridonendeger){} hrangi bir isim verebilirdik genelde (result){} deriz
  // yukardaki değeri alır ve içinde kullanır.
  //anladın mı ? anladım peki return ile yapmak varken neden callback yani hangi durumlarda kullanmak zorunda kalıyorum

  // tamam anlatıyim. await ne demek ? "bekle" demekdeğilmi ?evet
  // await olunca yazılım bekliyor aynen
  // kullanıcı beklesin ister misin ? değil tabiki az bekel bi
  // kullanıcıyı boş yere bekletmemek için bazen await kullanmayız yani asenkron yapmayız
  // diğer türlü kullanıcı programın çok yavaş çalıştığını düşünecek
  // await kullanımı kolaydır insan aklının rahat alabileceği bir işlem çünkü herşey adım adım ilerliyor değil mi ?
  //evet, ama işte bazen kullanıcı beklemesin diye böyle callbackler kullanıyoruz. anlamişko ? yani bir nevi asenkron yapıyor fonksiyonu
  // asenkdron yapmıyor, diyor ki benim 100 tane çalışanım var hepsine bir iş vericem
  // eğer biri bitirince diğer gitsin dersen  100 kişiyi o işi yapması için bekleyeceksin
  // diyelimki bir kişinin bir işi yapması 1 dk sürsün. 100 kişi gönder 100dk sürer bitmesi değil mi ?
  // evet
  // ama callback ile yapsan 100'ünü de gönderirsin aynı anda sen işini bitirince bana dönersin diyorsun
  // 100'ü de işe gidiyor kimisi 1dk da kimisi 2dk da işini bitiriyor
  // bir bakıyorsun ki 100'ü toplamda 5dk da dönmüş
  // ne olmuş oluyor 100dk beklemiyorsun da 5dk bekliyorsun. bu bir kazançtır.anladım
  // asenkronu yönetmek kolaydır. adım adım yaptırıyorsun. bazen gereklidir.
  // ancak callback te sana hız katar esneklik katar. eski yazılımcılar hep asenkron çalışır
  // yeni nesil hıza önem verdiğ için böyle callback gibi bir mantıkla çalışır
  // ancak callback ler okunurluğu azaltıyor. yani birisinin anlamasını zorlaştırıyor.
  // anladın mı ? anladım
  // aslında callback diye bir şey yok, parametreye fonksiyon veriyorsun. fonksiyonu çalıştırınca oraya düşüyor.
  // eskiden parametreye fonksiyon verilmiyordu. artık verilebildiği için güzel bişey.evet güzel
  // evet çok asenkdon kullandık ancak projemiz zaten küçük. endişlenmene gerek yok.anbladım ben bazen hangi
  //fonksiyon asenkron olmalı tam bilemiyorum
  //sanırım şöyle öncelikle o işin yapılması gerekn durumlarda yani sen şunu yap basşka bişeyle uğraşma sonra diğerlerine
  //gecersin gibi demiT E?Vet 100% doğru
  // bu arada kelimeleri yanlış kullanıyoruz. :) senkron, asenkron
  // senkron -> await, async li kısım

  static birIslemYap() {
    benAsenkronDegilim('Ali', (geridonendeger) {
      SBBildirim.bilgi(geridonendeger);
    });
  }*/
