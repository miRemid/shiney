import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


class ImageItem {
  final String href;
  final String url;

  ImageItem({
    this.href,
    this.url
});
}

class DBProvider {
  DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    print(documentsDirectory.path);
    String dbpath = path.join(documentsDirectory.path, "shiney.db");
    // !!!!!!!!!!!!!!DEBUG!!!!!!!!!!!!!!!!!!!
    deleteDatabase(dbpath);
    return await openDatabase(dbpath, version: 1, onOpen: (db){
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE IMAGE (id INTEGER PRIMARY KEY AUTOINCREMENT, href CHAR(10), url VARCHAR(120))");
    });
  }

  insertImage(String href, String url) async {
    final db = await database;
    var res = await db.rawInsert(
      "INSERT INTO IMAGE (href, url) VALUES ('$href', '$url');"
    );
    return res;
  }

  getImages(String href) async {
    final db = await database;
    var res = await db.rawQuery(
      "SELECT href, url FROM IMAGE WHERE href = '$href';"
    );
    List<ImageItem> list = res.isNotEmpty ? res.map((e) => ImageItem(href: e['href'],url: e['url'])).toList() : [];
    return list;
  }

  static final DBProvider db = DBProvider._();
}