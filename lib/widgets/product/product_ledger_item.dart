import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductLedgerItem extends StatelessWidget {
  final Function(Product product) removeProductFromList;
  final Function(Product product) addProductToList;
  final Product product;
  final int itemNum;
  const ProductLedgerItem({
    required this.product,
    required this.itemNum,
    required this.removeProductFromList,
    required this.addProductToList,
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
              itemNum.toString() + ' x ' + product.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  removeProductFromList(product);
                },
                icon: Icon(Icons.remove),
              ),
              IconButton(
                onPressed: () {
                  addProductToList(product);
                },
                icon: Icon(Icons.add),
              ),
              Container(
                width: 90,
                child: Text(
                  (product.price * itemNum).toString() + '🐪',
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
