import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Function(Product product) addProductToList;
  final Product product;
  final bool small;
  final FocusNode node;
  const ProductCard(
      {required this.product,
      required this.node,
      this.small = false,
      required this.addProductToList});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        child: InkWell(
          focusNode: node,
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            addProductToList(product);
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Stack(
              children: [
                product.imageURL != null //TODO
                    ? Container()
                    : Container(),
                Material(
                  color: Colors.transparent,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        product.name,
                        style: small
                            ? Theme.of(context).textTheme.headline5
                            : Theme.of(context).textTheme.headline4,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        product.price.toString() + '🐪',
                        style: small
                            ? Theme.of(context).textTheme.headline6
                            : Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}