import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductLedgerItem extends StatelessWidget {
  final Function(Product product) removeProductFromList;
  final Function(Product product) addProductToList;
  final Function(Product product) halfProductOnList;
  final Product product;
  final double itemNum;
  const ProductLedgerItem({
    required this.product,
    required this.itemNum,
    required this.removeProductFromList,
    required this.addProductToList,
    required this.halfProductOnList,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              (itemNum%1==0?itemNum.toStringAsFixed(0):itemNum.toString()) + ' x ' + product.name,
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
              TextButton(onPressed: (){
                halfProductOnList(product);
              }, child: Text('½', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),),
              IconButton(
                onPressed: () {
                  addProductToList(product);
                },
                icon: Icon(Icons.add),
              ),
              Container(
                width: 90,
                child: Text(
                  (product.price * itemNum).ceil().toString() + '🐪',
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
