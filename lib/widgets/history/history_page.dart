import 'dart:convert';
import 'dart:io';

import 'package:estike/http_handler.dart';
import 'package:estike/models/product.dart';
import 'package:estike/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../config.dart';
import '../../models/purchase.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Előzmények'),
        actions: [
          IconButton(
              onPressed: () async {
                print('itt');
                //TODO: export
                try {
                  if (await Permission.storage.request().isGranted) {
                    String path = '/storage/emulated/0/Download';
                    print(path);
                    File file = File(path + '/users.txt');
                    await file.writeAsString(User.allUsers.join('\n'));
                    print('1');
                    file = File(path + '/products.txt');
                    await file.writeAsString(Product.allProducts.join('\n'));
                    file = File(path + '/purchases.txt');
                    await file.writeAsString(Purchase.allPurchases.join('\n'));
                    print('vege');
                  }
                } catch (_) {
                  throw _;
                }
              },
              icon: Icon(Icons.call_merge)),
        ],
      ),
      body: isOnline
          ? FutureBuilder(
              future: _getHistory(),
              builder: (context, AsyncSnapshot<List> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return ListView(
                      children: _generatePurchases(context, snapshot.data![0],
                          snapshot.data![1], snapshot.data![2]),
                    );
                  } else {
                    //TODO
                  }
                }
                return CircularProgressIndicator();
              },
            )
          : ListView(
              padding: EdgeInsets.all(15),
              children: _generatePurchases(context, User.allUsers,
                  Purchase.allPurchases, Product.allProducts),
            ),
    );
  }

  Future<List> _getHistory() async {
    try {
      http.Response response =
          await httpGet(context: context, uri: generateUri(GetUriKeys.history));
      Map<String, List<Map<String, dynamic>>> decoded =
          jsonDecode(response.body);
      List<Product> products = [];
      if (decoded['products'] != null) {
        for (Map<String, dynamic> decodedProduct in decoded['products']!) {
          Product product = Product(
            decodedProduct['name'],
            decodedProduct['price'],
            productTypeFromString(decodedProduct['type']),
            id: decodedProduct['id'],
            createdAt: DateTime.parse(decodedProduct['created_at']),
            updatedAt: DateTime.parse(decodedProduct['updated_at']),
          );
          product.peopleBuying = decodedProduct['people_buying'];
          products.add(product);
        }
      } else {
        throw 'null on products';
      }
      List<User> users = [];
      if (decoded['users'] != null) {
        for (Map<String, dynamic> decodedUser in decoded['users']!) {
          User user = User(
            decodedUser['id'],
            decodedUser['name'],
            decodedUser['balance'],
            createdAt: DateTime.parse(decodedUser['created_at']),
            updatedAt: DateTime.parse(decodedUser['updated_at']),
          );
          user.productsBought = decodedUser['products_bought'];
          users.add(user);
        }
      } else {
        throw 'null on users';
      }
      List<Purchase> purchases = [];
      if (decoded['purchases'] != null) {
        for (Map<String, dynamic> decodedPurchase in decoded['purchases']!) {
          Purchase purchase = Purchase(
            id: decodedPurchase['id'],
            userId: decodedPurchase['userId'],
            productId: decodedPurchase['productId'],
            amount: decodedPurchase['amount'],
            createdAt: DateTime.parse(decodedPurchase['created_at']),
            updatedAt: DateTime.parse(decodedPurchase['updated_at']),
          );
          purchases.add(purchase);
        }
      } else {
        throw 'null on purchases';
      }

      return [users, purchases, products];
    } catch (_) {
      throw _;
    }
  }

  List<Widget> _generatePurchases(BuildContext context, List<User> allUsers,
      List<Purchase> allPurchases, List<Product> allProducts) {
    List<Purchase> purchases = allPurchases;
    if (purchases.where((element) => element.productId != -1).length != 0) {
      Map<int, List<Purchase>> groupedPurchases = {};
      int i = 0;
      Purchase lastPurchase = purchases[i];
      while (lastPurchase.productId == -1) {
        i++;
        if (i < purchases.length) {
          lastPurchase = purchases[i];
        } else {
          return [];
        }
      }
      int purchaseId = 0;
      groupedPurchases[purchaseId] = [];
      for (Purchase purchase in purchases) {
        if (purchase.updatedAt.difference(lastPurchase.updatedAt).abs() <
                Duration(seconds: 1) &&
            purchase.userId == lastPurchase.userId) {
          groupedPurchases[purchaseId]!.add(purchase);
        } else if (purchase.productId != -1) {
          lastPurchase = purchase;
          purchaseId++;
          groupedPurchases[purchaseId] = [lastPurchase];
        }
      }
      List<Widget> widgets = [];
      for (List<Purchase> purchases in groupedPurchases.values) {
        List<Widget> widgetsInColumn = [];
        User user =
            allUsers.firstWhere((element) => element.id == purchases[0].userId);
        widgetsInColumn.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      user.name,
                      style: Theme.of(context).textTheme.headline6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    ' - ' + user.id.toString() + '   ',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
            ),
            Text(
              DateFormat('MM-dd - kk:mm').format(
                purchases[0].updatedAt,
              ),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ));
        int summedPrice = 0;
        for (Purchase purchase in purchases) {
          if (purchase.productId != -1) {
            Product productBought = allProducts
                .firstWhere((element) => element.id == purchase.productId);
            summedPrice += (productBought.price * purchase.amount).ceil();
            Padding row = Padding(
              padding: EdgeInsets.all(7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      purchase.amount.toString() + ' x ' + productBought.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text((purchase.amount * productBought.price).toString() +
                      '🐪'),
                ],
              ),
            );
            widgetsInColumn.add(row);
          }
        }
        widgetsInColumn.add(Divider());
        widgetsInColumn.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Összesen',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(summedPrice.toString() + '🐪'),
          ],
        ));
        Card card = Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: widgetsInColumn,
            ),
          ),
        );
        widgets.add(card);
      }
      return widgets;
    }
    return [Container()];
  }
}
