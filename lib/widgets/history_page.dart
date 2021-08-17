import 'package:estike/models/product.dart';
import 'package:estike/models/user.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../models/purchase.dart';
import 'package:intl/intl.dart';

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
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: _generatePurchases(context),
      ),
    );
  }

  List<Widget> _generatePurchases(BuildContext context) {
    List<Purchase> purchases = Purchase.allPurchases;
    if (purchases.length != 0) {
      Map<int, List<Purchase>> groupedPurchases = {};
      Purchase lastPurchase = purchases[0];
      int purchaseId = 0;
      groupedPurchases[purchaseId] = [];
      for (Purchase purchase in purchases) {
        if (purchase.updatedAt.difference(lastPurchase.updatedAt).abs() <
                Duration(seconds: 1) &&
            purchase.userId == lastPurchase.userId) {
          groupedPurchases[purchaseId]!.add(purchase);
        } else {
          lastPurchase = purchase;
          purchaseId++;
          groupedPurchases[purchaseId] = [lastPurchase];
        }
      }
      List<Widget> widgets = [];
      for (List<Purchase> purchases in groupedPurchases.values) {
        List<Widget> widgetsInColumn = [];
        User user = User.allUsers
            .firstWhere((element) => element.id == purchases[0].userId);
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
          Product productBought = Product.allProducts
              .firstWhere((element) => element.id == purchase.productId);
          summedPrice += productBought.price * purchase.amount;
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
                Text((purchase.amount * productBought.price).toString() + '🐪'),
              ],
            ),
          );
          widgetsInColumn.add(row);
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
