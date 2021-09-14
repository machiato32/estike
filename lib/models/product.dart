import 'dart:async';

import 'package:estike/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'user.dart';

enum ProductType { beer, long, short, cocktail, wine, soda, meal, other }

class Product {
  static List<Product> allProducts = [];
  static int maxId = 0;
  late int id;
  int price;
  String name;
  ProductType type;
  String? imageURL;
  late DateTime createdAt;
  late DateTime updatedAt;
  Map<int, int> peopleBuying = {}; // userId, timesBought

  Product(this.name, this.price, this.type,
      {int? id, this.imageURL, DateTime? createdAt, DateTime? updatedAt}) {
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

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      map['name'],
      map['price'],
      productTypeFromString(map['productType']),
      id: map['id'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  @override
  String toString() {
    return {
      'id': id,
      'price': price,
      'name': name,
      'productType': generateProductTypeString(type),
      'created_at': DateFormat('MM-dd - kk:mm').format(createdAt),
      'updated_at': DateFormat('MM-dd - kk:mm').format(updatedAt),
    }.toString();
  }

  void addPersonBuying(User user, int number) {
    if (peopleBuying[user.id] != null) {
      peopleBuying[user.id] = peopleBuying[user.id]! + 1;
    } else {
      peopleBuying[user.id] = 1;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'price': price,
      'name': name,
      'productType': generateProductTypeString(type),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  Future<void> insert() async {
    // Get a reference to the database.
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'products',
      this.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update('products', this.toMap(),
        where: 'id = ?', whereArgs: [this.id]);
  }

  Future<int> delete() async {
    allProducts.removeWhere((element) => element.id == this.id);
    Database db = await DatabaseHelper.instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [this.id]);
  }
}

String humanReadableProductType(ProductType type) {
  switch (type) {
    case ProductType.beer:
      return 'Sör';
    case ProductType.long:
      return 'Long drink';
    case ProductType.short:
      return 'Rövid ital';
    case ProductType.cocktail:
      return 'Koktél';
    case ProductType.other:
      return 'Egyéb';
    case ProductType.wine:
      return 'Bor';
    case ProductType.soda:
      return 'Üdítő';
    case ProductType.meal:
      return 'Étel';
  }
}

String generateProductTypeString(ProductType type) {
  switch (type) {
    case ProductType.beer:
      return 'beer';
    case ProductType.long:
      return 'long';
    case ProductType.short:
      return 'short';
    case ProductType.cocktail:
      return 'cocktail';
    case ProductType.other:
      return 'other';
    case ProductType.wine:
      return 'wine';
    case ProductType.soda:
      return 'soda';
    case ProductType.meal:
      return 'meal';
  }
}

ProductType productTypeFromString(String s) {
  switch (s) {
    case 'beer':
      return ProductType.beer;
    case 'long':
      return ProductType.long;
    case 'shortdrink':
      return ProductType.short;
    case 'cocktail':
      return ProductType.cocktail;
    case 'wine':
      return ProductType.wine;
    case 'soda':
      return ProductType.soda;
    case 'meal':
      return ProductType.meal;
    default:
      return ProductType.other;
  }
}

Future<void> initProducts() async {
  Product.allProducts = await queryProducts();
  if (Product.allProducts.length != 0) {
    Product.maxId = Product.allProducts.last.id + 1;
  }
}

Future<List<Product>> queryProducts() async {
  Database db = await DatabaseHelper.instance.database;
  List<Map<String, dynamic>> products = await db.query('products');
  return products.map((e) => Product.fromMap(e)).toList();
}

Future<bool> addProduct(String name, int price, ProductType type,
    {String? imageURL}) async {
  Product product = Product(name, price, type, imageURL: imageURL);
  await product.insert();
  Product.allProducts.add(product);
  return true;
}

Future<bool> updateProduct(
    int id, String name, int price, ProductType type) async {
  Product.allProducts.removeWhere((element) => element.id == id);
  Product product = Product(name, price, type, id: id);
  Product.allProducts.add(product);
  await product.update();
  return true;
}
