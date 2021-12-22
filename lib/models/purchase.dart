import 'package:estike/database_helper.dart';
import 'package:estike/models/product.dart';
import 'package:estike/models/user.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class Purchase {
  static int maxId = 0;
  static List<Purchase> allPurchases = [];
  late int id;
  int userId;
  int productId;
  double amount;
  late DateTime createdAt;
  late DateTime updatedAt;
  Purchase({
    int? id,
    required this.userId,
    required this.productId,
    required this.amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (id == null) {
      this.id = maxId;
      maxId++;
    } else {
      this.id = id;
    }

    if (createdAt == null) {
      this.createdAt = DateTime.now();
    } else {
      this.createdAt = createdAt;
    }
    if (updatedAt == null) {
      this.updatedAt = DateTime.now();
    } else {
      this.updatedAt = updatedAt;
    }
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'],
      userId: map['user_id'],
      productId: map['product_id'],
      amount: map['amount'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
  @override
  String toString() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': createdAt.toIso8601String(),
    }.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'amount': amount,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  Future<void> insert() async {
    // Get a reference to the database.
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'purchases',
      this.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update() async {
    Database db = await DatabaseHelper.instance.database;
    this.updatedAt = DateTime.now();
    return await db.update(
      'purchases',
      this.toMap(),
      where: 'id = ?',
      whereArgs: [this.id],
    );
  }

  Future<int> delete() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      'purchases',
      where: 'id = ?',
      whereArgs: [this.id],
    );
  }
}

Future<void> initPurchases() async {
  Purchase.allPurchases = await queryProductsUsers();
  if (Purchase.allPurchases.length != 0) {
    Purchase.maxId = Purchase.allPurchases.last.id + 1;
  }
  // print(Purchase.allPurchases);
  // print(Purchase.maxId);
  for (Purchase purchase in Purchase.allPurchases) {
    try {
      addPeopleBuying(purchase);
    } on StateError {
      print('No user or product found');
      //TODO
    }
  }
}
void addPeopleBuying(Purchase purchase) {
  User user =
          User.allUsers.firstWhere((element) => element.id == purchase.userId);
      Product product = Product.allProducts
          .firstWhere((element) => element.id == purchase.productId);
      if (user.productsBought.containsKey(product.id)) {
        user.productsBought[product.id] = user.productsBought[product.id]! + 1;
      } else {
        user.productsBought[product.id] = 1;
      }
      if (product.peopleBuying.containsKey(user)) {
        product.peopleBuying[user.id] = product.peopleBuying[user.id]! + 1;
      } else {
        product.peopleBuying[user.id] = 1;
      }
}
Future<List<Purchase>> queryProductsUsers() async {
  try {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> productsUsers = await db.query('purchases');
    return productsUsers.map((e) => Purchase.fromMap(e)).toList();
  } catch (_) {
    throw _;
  }
}

Future<bool> addPurchase(int userId, int productId, double amount) async {
  try {
    Purchase purchase =
        Purchase(userId: userId, productId: productId, amount: amount);
    Purchase.allPurchases.add(purchase);
    if(productId!=-1){
      addPeopleBuying(purchase);
    }
    await purchase.insert();
    return true;
  } catch (_) {
    throw _;
  }
}
