import 'dart:async';

import 'package:estike/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'user.dart';

enum DrinkType { beer, long, short, cocktail, other }

class Drink {
  static List<Drink> allDrinks = [];
  int price;
  String name;
  DrinkType type;
  String? imageURL;
  Map<User, int> peopleBuying = {};

  Drink(this.name, this.price, this.type, {this.imageURL});

  factory Drink.fromMap(Map<String, dynamic> map) {
    return Drink(
      map['name'],
      map['price'],
      drinkTypeFromString(map['drinkType']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'name': name,
      'drinkType': generateDrinkType(type),
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
    return await db.update('drinks', this.toMap(),
        where: 'name = ?', whereArgs: [this.name]);
  }

  Future<int> delete() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete('drinks', where: 'name = ?', whereArgs: [this.name]);
  }
}

String generateDrinkType(DrinkType type) {
  switch (type) {
    case DrinkType.beer:
      return 'beer';
    case DrinkType.long:
      return 'long';
    case DrinkType.short:
      return 'short';
    case DrinkType.cocktail:
      return 'cocktail';
    case DrinkType.other:
      return 'other';
  }
}

DrinkType drinkTypeFromString(String s) {
  switch (s) {
    case 'beer':
      return DrinkType.beer;
    case 'long':
      return DrinkType.long;
    case 'short':
      return DrinkType.short;
    case 'cocktail':
      return DrinkType.cocktail;
    default:
      return DrinkType.other;
  }
}

Future<void> initDrinks() async {
  Drink.allDrinks = await queryDrinks();
}

Future<List<Drink>> queryDrinks() async {
  Database db = await DatabaseHelper.instance.database;
  List<Map<String, dynamic>> drinks = await db.query('drinks');
  return drinks.map((e) => Drink.fromMap(e)).toList();
}

void addDrink(String name, int price, DrinkType type, {String? imageURL}) {
  Drink drink = Drink(name, price, type, imageURL: imageURL);
  drink.insert();
  Drink.allDrinks.add(drink);
}
