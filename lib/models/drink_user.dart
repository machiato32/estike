import 'package:estike/models/drink.dart';
import 'package:sqflite/sqflite.dart';
import 'package:estike/database_helper.dart';

class DrinkUser {
  static List<DrinkUser> allDrinksUsers = [];
  int userId;
  String drinkName;
  int timesBought;
  DrinkUser({
    required this.userId,
    required this.drinkName,
    required this.timesBought,
  });

  factory DrinkUser.fromMap(Map<String, dynamic> map) {
    return DrinkUser(
      userId: map['user_id'],
      drinkName: map['drink_name'],
      timesBought: map['times_bought'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'drink_name': drinkName,
      'times_bought': timesBought,
    };
  }

  Future<void> insert() async {
    // Get a reference to the database.
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'drinks',
      this.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      'drinks_users',
      this.toMap(),
      where: 'user_id = ? and drink_name = ?',
      whereArgs: [this.userId, this.drinkName],
    );
  }

  Future<int> delete() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      'drinks_users',
      where: 'user_id = ? and drink_name = ?',
      whereArgs: [this.userId, this.drinkName],
    );
  }

  static initDrinksUsers() async {
    allDrinksUsers = await queryDrinksUsers();
    //TODO: add users to drinks and other way around
  }

  static Future<List<DrinkUser>> queryDrinksUsers() async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> drinksUsers = await db.query('drinks_users');
    return drinksUsers.map((e) => DrinkUser.fromMap(e)).toList();
  }
}
