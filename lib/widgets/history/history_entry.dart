import 'package:estike/models/product.dart';
import 'package:estike/models/purchase.dart';
import 'package:estike/models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryEntry extends StatelessWidget {
  final List<Purchase> purchases;
  const HistoryEntry({required this.purchases});

  @override
  Widget build(BuildContext context) {
    List<Widget> columnWidgets = [];
    User user = User.allUsers.firstWhere(
        (element) => element.id == purchases[0].userId,
        orElse: () => User(-1, "Készpénz", 0));
    columnWidgets.add(Row(
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
              user.id != -1
                  ? Text(
                      ' - ' + user.id.toString() + '   ',
                      style: Theme.of(context).textTheme.headline6,
                    )
                  : Container(),
            ],
          ),
        ),
        Text(
          DateFormat('MM-dd - HH:mm').format(
            purchases[0].updatedAt,
          ),
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    ));
    for (Purchase purchase in purchases) {
      if (purchase.productId != Product.modifiedBalanceId) {
        Product productBought = Product.allProducts
            .firstWhere((element) => element.id == purchase.productId);
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
              Text((purchase.amount * productBought.price).toInt().toString() +
                  '🐪'),
            ],
          ),
        );
        columnWidgets.add(row);
      }
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: columnWidgets,
        ),
      ),
    );
  }
}