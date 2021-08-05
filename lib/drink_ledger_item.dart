import 'package:flutter/material.dart';
import 'models/drink.dart';

class DrinkLedgerItem extends StatelessWidget {
  final Function(Drink drink) removeDrinkFromList;
  final Function(Drink drink) addDrinkToList;
  final Drink drink;
  final int itemNum;
  const DrinkLedgerItem({
    required this.drink,
    required this.itemNum,
    required this.removeDrinkFromList,
    required this.addDrinkToList,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              itemNum.toString() + ' x ' + drink.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  removeDrinkFromList(drink);
                },
                icon: Icon(Icons.remove),
              ),
              IconButton(
                onPressed: () {
                  addDrinkToList(drink);
                },
                icon: Icon(Icons.add),
              ),
              Container(
                width: 90,
                child: Text(
                  (drink.price * itemNum).toString() + '🐪',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
