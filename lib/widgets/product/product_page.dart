import 'dart:convert';

import 'package:estike/models/purchase.dart';
import 'package:estike/widgets/future_success_dialog.dart';
import 'package:estike/widgets/product/product_ledger_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../../http_handler.dart';
import '../../models/product.dart';
import '../../models/user.dart';
import 'product_card.dart';

class ProductPage extends StatefulWidget {
  final User user;
  const ProductPage({required this.user});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  ScrollController controller = ScrollController();
  List<FocusNode> nodes = [];
  int nodeNum = 0;
  Map<Product, int> productsToBuy = {};
  bool small = false;
  @override
  Widget build(BuildContext context) {
    small = MediaQuery.of(context).size.width <= 1200;
    nodes = [];
    return Scaffold(
      appBar: AppBar(
        title: Text('Ital kiválasztása'),
      ),
      body: small
          ? Column(
              children: [
                Expanded(
                  child: isOnline
                      ? FutureBuilder(
                          future: _getProducts(),
                          builder:
                              (context, AsyncSnapshot<List<Product>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return _generateLeftUpperPart(snapshot.data!);
                              } else {
                                //TODO
                              }
                            }
                            return CircularProgressIndicator();
                          },
                        )
                      : _generateLeftUpperPart(Product.allProducts),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                    ),
                  ),
                  height: MediaQuery.of(context).size.height / 3.3,
                  child: _generateRightLower(),
                ),
              ],
            )
          : Table(
              columnWidths: {
                0: FractionColumnWidth(0.7),
                1: FractionColumnWidth(0.3),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: isOnline
                          ? FutureBuilder(
                              builder: (context,
                                  AsyncSnapshot<List<Product>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return _generateLeftUpperPart(
                                        snapshot.data!);
                                  } else {
                                    //TODO
                                  }
                                }
                                return CircularProgressIndicator();
                              },
                            )
                          : _generateLeftUpperPart(Product.allProducts),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                      ),
                      child: _generateRightLower(),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<List<Product>> _getProducts() async {
    try {
      http.Response response =
          await httpGet(context: context, uri: generateUri(GetUriKeys.drinks));
      List<Map<String, dynamic>> decoded = jsonDecode(response.body);
      List<Product> products = [];
      for (Map<String, dynamic> decodedProduct in decoded) {
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
      return products;
    } catch (_) {
      throw _;
    }
  }

  void addProductToList(Product product) {
    setState(() {
      if (productsToBuy.containsKey(product)) {
        productsToBuy[product] = productsToBuy[product]! + 1;
      } else {
        productsToBuy[product] = 1;
      }
    });
  }

  void removeProductFromList(Product product) {
    setState(() {
      productsToBuy[product] = productsToBuy[product]! - 1;
      if (productsToBuy[product] == 0) {
        productsToBuy.remove(product);
      }
    });
  }

  int sum(Map<Product, int> products) {
    int sum = 0;
    for (Product product in products.keys) {
      sum += product.price * products[product]!;
    }
    return sum;
  }

  Widget _generateRightLower() {
    return ListView(
      padding: EdgeInsets.all(10),
      shrinkWrap: true,
      children: [
        Visibility(
          visible: productsToBuy.keys.length > 0,
          child: Center(
            child: ElevatedButton(
              onPressed: () async {
                if (productsToBuy.keys.length != 0) {
                  if (sum(productsToBuy) <= widget.user.balance) {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return FutureSuccessDialog(future: _postPurchases());
                      },
                    );
                  }
                }
              },
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_circle_sharp,
                    color: Theme.of(context).primaryColor,
                    size: 35,
                  ),
                  Flexible(
                    child: Row(
                      children: [
                        Text(
                          widget.user.id.toString() + ' - ',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Flexible(
                          child: Text(
                            widget.user.name,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.user.balance.toString() + '🐪',
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
      ]
        ..addAll(productsToBuy.keys.map(
          (product) => ProductLedgerItem(
            addProductToList: addProductToList,
            removeProductFromList: removeProductFromList,
            product: product,
            itemNum: productsToBuy[product]!,
          ),
        ))
        ..add(Visibility(
          visible: productsToBuy.keys.length > 0,
          child: Column(
            children: [
              Divider(),
              Text(
                'Összesen: ' + sum(productsToBuy).toString() + '🐪',
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        )),
    );
  }

  Future<bool> _postPurchases() async {
    try {
      if (isOnline) {
        Map<String, dynamic> body = {
          'user_id': widget.user.id,
          'product_ids': productsToBuy.keys.map((e) => e.id).toList(),
        };
        await httpPost(context: context, uri: '/purchases', body: body);
      } else {
        for (Product product in productsToBuy.keys) {
          widget.user.addBoughProduct(product, number: productsToBuy[product]!);
          product.addPersonBuying(widget.user, productsToBuy[product]!);
          await addPurchase(
              widget.user.id, product.id, productsToBuy[product]!);
        }
        widget.user.balance -= sum(productsToBuy);
        await widget.user.update();
      }
      Future.delayed(Duration(milliseconds: 300))
          .then((value) => _onPostPurchases());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onPostPurchases() {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget _generateLeftUpperPart(List<Product> products) {
    return ListView(
      controller: controller,
      padding: EdgeInsets.all(10),
      shrinkWrap: true,
      children: [
        Visibility(
          visible: widget.user.productsBought.keys.length != 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajánlott',
                style: Theme.of(context).textTheme.headline3,
              ),
              _generateGrid(null, products),
            ],
          ),
        ),
        Text(
          'Sörök',
          style: Theme.of(context).textTheme.headline3,
        ),
        _generateGrid(ProductType.beer, products),
        Text(
          'Hosszú italok',
          style: Theme.of(context).textTheme.headline3,
        ),
        _generateGrid(ProductType.long, products),
        Text(
          'Rövid italok',
          style: Theme.of(context).textTheme.headline3,
        ),
        _generateGrid(ProductType.short, products),
        Text(
          'Borok',
          style: Theme.of(context).textTheme.headline3,
        ),
        _generateGrid(ProductType.wine, products),
        Text(
          'Koktélok',
          style: Theme.of(context).textTheme.headline3,
        ),
        _generateGrid(ProductType.cocktail, products),
        Text(
          'Üdítők',
          style: Theme.of(context).textTheme.headline3,
        ),
        _generateGrid(ProductType.soda, products),
        Text(
          'Ételek',
          style: Theme.of(context).textTheme.headline3,
        ),
        _generateGrid(ProductType.meal, products),
        SizedBox(
          height: 200,
        ),
      ],
    );
  }

  Widget _generateGrid(ProductType? type, List<Product> allProducts) {
    List<Product> products = [];
    if (type == null) {
      var mapEntries = widget.user.productsBought.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      Map<int, int> sortedProducts = {};
      sortedProducts.addEntries(mapEntries);
      List<int> productIds = sortedProducts.keys.take(5).toList();
      products = allProducts
          .where((element) => productIds.contains(element.id))
          .toList();
    } else {
      products = allProducts.where((element) => element.type == type).toList();
    }

    if (products.length == 0) return Container();
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      width = 7 * width / 10;
    }
    bool small = false;
    int count = (width / 200).floor();
    if (width < 400) {
      small = true;
      count = (width / 150).floor();
    }
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: count,
      children: products.map<Widget>(
        (e) {
          FocusNode node = FocusNode();
          nodes.add(node);
          return ProductCard(
            addProductToList: addProductToList,
            node: node,
            product: e,
            small: small,
          );
        },
      ).toList(),
    );
  }
}
