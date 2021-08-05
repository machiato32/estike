import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import 'drink.dart';

class User {
  static List<User> allUsers = [];
  String name;
  int id;
  int balance;
  Map<Drink, int> drinksBought = {};

  User(this.name, this.id, this.balance);
  factory User.fromMap(Map<String, dynamic> map) {
    return User(map['name'], map['id'], map['balance']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
    };
  }

  void addBoughtDrink(Drink drink, {int number = 1}) {
    if (drinksBought.containsKey(drink)) {
      drinksBought[drink] = drinksBought[drink]! + number;
    } else {
      drinksBought[drink] = number;
    }
  }

  void initUsers() async {
    allUsers = await queryUsers();
  }

  Future<List<User>> queryUsers() async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> users = await db.query('users');
    return users.map((e) => User.fromMap(e)).toList();
  }
}

addUser(String name, int id, {int balance = 0}) {
  User.allUsers.add(User(name, id, balance));
}
