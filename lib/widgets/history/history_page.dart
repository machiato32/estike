import 'package:estike/config.dart';
import 'package:estike/models/product.dart';
import 'package:estike/widgets/history/history_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: _generatePurchases(context),
      ),
    );
  }

  List<Widget> _generatePurchases(BuildContext context) {
    List<Purchase> purchases = Purchase.allPurchases;
    if (purchases
            .where((element) => element.productId != Product.modifiedBalanceId)
            .length !=
        0) {
      Map<int, List<Purchase>> groupedPurchases = {};
      int i = 0;
      Purchase lastPurchase = purchases[i];
      while (lastPurchase.productId == Product.modifiedBalanceId) {
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
        } else if (purchase.productId != Product.modifiedBalanceId) {
          lastPurchase = purchase;
          purchaseId++;
          groupedPurchases[purchaseId] = [lastPurchase];
        }
      }
      bool alreadyDrawnLine = false;
      return groupedPurchases.values
          .map((purchases) {
            if (!alreadyDrawnLine &&
                purchases[0].updatedAt.isAfter(DateTime.parse(lastUpdatedAt))) {
              alreadyDrawnLine = true;
              return Column(
                children: [
                  HistoryEntry(purchases: purchases),
                  Stack(
                    children: [
                      Divider(
                        height: 35,
                        color: Colors.red,
                        thickness: 3,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Text(
                            'Utolsó feltöltés: ' +
                                DateFormat('yyyy-MM-dd - HH:mm')
                                    .format(DateTime.parse(lastUpdatedAt)),
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.red),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              );
            }
            return HistoryEntry(purchases: purchases);
          })
          .toList()
          .reversed
          .toList();
    }
    return [Container()];
  }
}
