import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseVersion = 2;

  // make this a singleton class
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();
  // only have a single app-wide reference to the database
  static late Database _database;
  Future<Database> get database async {
    return _database;
  }

  ///Initialize database. Has to be called before using the database.
  Future<void> initDatabase() async {
    String? path;
    
    // deleteDatabase(join(await getDatabasesPath(), 'estike_database.db'));
    if(Platform.isWindows || Platform.isLinux){
      sqfliteFfiInit();
      path= join((await getApplicationDocumentsDirectory()).path, 'estike_database.db');
      databaseFactory = databaseFactoryFfi;
    }else if(Platform.isAndroid || Platform.isIOS){
      path = join(await getDatabasesPath(), 'estike_database.db');
    }
    if(path!=null){
      _database = await databaseFactory.openDatabase(
      path, options: OpenDatabaseOptions(version: _databaseVersion, onCreate: _onCreate));
    }
    
  }

  Future deleteDb() async {
    String? path;
    if(Platform.isWindows || Platform.isLinux){
      path= join((await getApplicationDocumentsDirectory()).path, 'estike_database.db');
    }else if(Platform.isAndroid || Platform.isIOS){
      path = join(await getDatabasesPath(), 'estike_database.db');
    }
    if(path!=null){
      await databaseFactory.deleteDatabase(path);
    }
    
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute(
        '''CREATE TABLE products(id INTEGER PRIMARY KEY, name TEXT NOT NULL, price INTEGER, productType TEXT, updated_at INTEGER,
        created_at INTEGER)''');
    await db.execute(
        '''CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT NOT NULL, balance INT NOT NULL, updated_at INTEGER,
        created_at INTEGER)''');
    await db.execute('''CREATE TABLE purchases(id INTEGER PRIMARY KEY, 
        product_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL, 
        amount REAL, 
        updated_at INTEGER,
        created_at INTEGER,
        FOREIGN KEY (product_id) REFERENCES products (id) 
          ON DELETE NO ACTION ON UPDATE NO ACTION,
        FOREIGN KEY (user_id) REFERENCES users (id) 
          ON DELETE NO ACTION ON UPDATE NO ACTION)''');
  }

//   // Helper methods

//   // Inserts a row in the database where each key in the Map is a column name
//   // and the value is the column value. The return value is the id of the
//   // inserted row.
//   Future<int> insert(Map<String, dynamic> row) async {
//     Database db = await instance.database;
//     return await db.insert(table, row);
//   }

//   // All of the rows are returned as a list of maps, where each map is
//   // a key-value list of columns.
//   Future<List<Map<String, dynamic>>> queryAllRows() async {
//     Database db = await instance.database;
//     return await db.query(table);
//   }

//   // All of the methods (insert, query, update, delete) can also be done using
//   // raw SQL commands. This method uses a raw query to give the row count.
//   Future<int?> queryRowCount() async {
//     Database db = await instance.database;
//     return Sqflite.firstIntValue(
//         await db.rawQuery('SELECT COUNT(*) FROM $table'));
//   }

//   // We are assuming here that the id column in the map is set. The other
//   // column values will be used to update the row.
//   Future<int> update(Map<String, dynamic> row) async {
//     Database db = await instance.database;
//     int id = row[columnId];
//     return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
//   }

//   // Deletes the row specified by the id. The number of affected rows is
//   // returned. This should be 1 as long as the row exists.
//   Future<int> delete(int id) async {
//     Database db = await instance.database;
//     return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
//   }
}
