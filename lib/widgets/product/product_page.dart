import 'package:estike/models/purchase.dart';
import 'package:estike/widgets/future_success_dialog.dart';
import 'package:estike/widgets/product/not_enough_money_dialog.dart';
import 'package:estike/widgets/product/product_ledger_item.dart';
import 'package:estike/widgets/product/product_page_other_button.dart';
import 'package:estike/widgets/user/modify_balance.dart';
import 'package:estike/widgets/user/modify_balance_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config.dart';
import '../../models/product.dart';
import '../../models/user.dart';
import 'product_card.dart';

class PopIntent extends Intent {
  const PopIntent();
}

class BuyProductIntent extends Intent {
  const BuyProductIntent();
}

class ProductPage extends StatefulWidget {
  final User user;
  const ProductPage({required this.user});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Map<Product, double> productsToBuy = {};
  bool smallScreen = false;

  Map<ProductType, bool> whichToShow = {
    ProductType.beer: false,
    ProductType.wine: false,
    ProductType.cocktail: false,
    ProductType.long: false,
    ProductType.shot: false,
    ProductType.other: false,
    ProductType.meal: false,
    ProductType.soda: false,
  };

  @override
  Widget build(BuildContext context) {
    smallScreen = MediaQuery.of(context).size.width <= 800;
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.escape): PopIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): BuyProductIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PopIntent: CallbackAction<PopIntent>(
            onInvoke: (PopIntent intent) => Navigator.pop(context),
          ),
          BuyProductIntent: CallbackAction<BuyProductIntent>(
            onInvoke: (BuyProductIntent intent) => buyProducts(),
          )
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Ital kiválasztása'),
              actions: widget.user.id == User.cashUserId
                  ? []
                  : [
                      TextButton(
                        child: Row(
                          children: [
                            Text(
                              "Visszaváltás (50)",
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.recycling,
                            ),
                          ],
                        ),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) =>
                            FutureSuccessDialog(
                              future: addRecycledCanPrice(),
                            ),
                        ),
                      ),
                      TextButton(
                        child: Row(
                          children: [
                            Text(
                              "Feltöltés",
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.payments,
                            ),
                          ],
                        ),
                        onPressed: () => showDialog(
                            context: context,
                            builder: (context) =>
                                ModifyBalanceDialog(selectedUser: widget.user)),
                      ),
                    ],
            ),
            body: smallScreen
                ? Column(
                    children: [
                      Expanded(
                        child: _generateLeftUpperPart(),
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
                      0: FractionColumnWidth(0.6),
                      1: FractionColumnWidth(0.4),
                    },
                    children: [
                      TableRow(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height,
                            child: _generateLeftUpperPart(),
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
          ),
        ),
      ),
    );
  }

  void halfProductOnList(Product product) {
    setState(() {
      if (productsToBuy.containsKey(product)) {
        if (productsToBuy[product]! <= 0.5) {
          productsToBuy.remove(product);
        } else {
          productsToBuy[product] = productsToBuy[product]! - 1 / 2;
        }
      } else {
        productsToBuy[product] = 0.5;
      }
    });
  }

  Future<bool> addRecycledCanPrice() async {
    try {
      await addPurchase(widget.user.id, Product.modifiedBalanceId,
          recycledCanPrice.toDouble());
      await widget.user.modifyBalance(recycledCanPrice);

      Future.delayed(Duration(milliseconds: 600))
          .then((value) {Navigator.pop(context); Navigator.pop(context);});

      return true;
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
      if (productsToBuy.containsKey(product) && productsToBuy[product]! <= 0) {
        productsToBuy.remove(product);
      }
    });
  }

  double sum(Map<Product, double> products) {
    double sum = 0;
    for (Product product in products.keys) {
      sum += product.price * products[product]!;
    }
    return sum;
  }

  void buyProducts() async {
    if (productsToBuy.keys.length != 0) {
      if (widget.user.id != User.cashUserId) {
        if (widget.user.balance < sum(productsToBuy)) {
          return showDialog(
            context: context,
            builder: (context) {
              return NotEnoughMoneyDialog(
                  user: widget.user, productsToBuy: productsToBuy);
            },
          );
        }
      }
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return FutureSuccessDialog(
              future:
                  _postPurchases(usesCash: widget.user.id == User.cashUserId));
        },
      );
    }
  }

  Widget _generateRightLower() {
    return ListView(
      controller: ScrollController(),
      padding: EdgeInsets.all(10),
      shrinkWrap: true,
      children: [
        Visibility(
          visible: productsToBuy.keys.length > 0,
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary),
              onPressed: () {
                buyProducts();
              },
              child: Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.onPrimary,
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
                    color: Theme.of(context).colorScheme.primary,
                    size: 35,
                  ),
                  Flexible(
                    child: Row(
                      children: [
                        Text(
                          widget.user.id.toString() + ' - ',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface),
                        ),
                        Flexible(
                          child: Text(
                            widget.user.name,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
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
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ]
        ..addAll(productsToBuy.keys.map(
          (product) => ProductLedgerItem(
            addProductToList: addProductToList,
            removeProductFromList: removeProductFromList,
            halfProductOnList: halfProductOnList,
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
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        )),
    );
  }

  Future<bool> _postPurchases({bool usesCash = false}) async {
    try {
      if (usesCash) {
        for (Product product in productsToBuy.keys) {
          await addPurchase(
              widget.user.id, product.id, productsToBuy[product]!);
        }
      } else {
        for (Product product in productsToBuy.keys) {
          widget.user
              .addBoughProduct(product, number: productsToBuy[product]!.ceil());
          product.addPersonBuying(widget.user, productsToBuy[product]!.ceil());
          await addPurchase(
              widget.user.id, product.id, productsToBuy[product]!);
        }
        await widget.user.modifyBalance(-sum(productsToBuy).ceil());
      }

      Future.delayed(Duration(milliseconds: 600))
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

  Widget _generateLeftUpperPart() {
    List<Product> products =
        Product.allProducts.where((element) => element.enabled).toList();
    double usablePartWidth = MediaQuery.of(context).size.width;
    if (!smallScreen) {
      usablePartWidth = 6 * usablePartWidth / 10;
    }
    bool smallText = false;
    int columnCount = (usablePartWidth / 200).floor();
    if (usablePartWidth < 600) {
      smallText = true;
      columnCount = (usablePartWidth / 150).floor();
    }
    return ListView(
      controller: ScrollController(),
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
                style: Theme.of(context).textTheme.displaySmall,
              ),
              _generateGrid(null, products, columnCount, smallText),
            ],
          ),
        ),
        _productTypeWidget(products, columnCount, ProductType.beer, smallText),
        _productTypeWidget(products, columnCount, ProductType.long, smallText),
        _productTypeWidget(products, columnCount, ProductType.shot, smallText),
        _productTypeWidget(products, columnCount, ProductType.wine, smallText),
        _productTypeWidget(
            products, columnCount, ProductType.cocktail, smallText),
        _productTypeWidget(products, columnCount, ProductType.soda, smallText),
        _productTypeWidget(products, columnCount, ProductType.meal, smallText),
        _productTypeWidget(products, columnCount, ProductType.other, smallText),
        OtherButton(
            user: widget.user,
            productColumnCount: columnCount,
            smallScreen: smallText),
        SizedBox(
          height: 200,
        ),
      ],
    );
  }

  Widget _productTypeWidget(
      List<Product> products, int count, ProductType type, bool smallText) {
    String name = '';
    switch (type) {
      case ProductType.beer:
        name = 'Sörök';
        break;
      case ProductType.long:
        name = 'Hosszú italok';
        break;
      case ProductType.shot:
        name = 'Rövid italok';
        break;
      case ProductType.wine:
        name = 'Borok';
        break;
      case ProductType.cocktail:
        name = 'Koktélok';
        break;
      case ProductType.soda:
        name = 'Üdítők';
        break;
      case ProductType.meal:
        name = 'Ételek';
        break;
      case ProductType.other:
        name = 'Egyebek';
        break;
    }
    return Visibility(
      visible: products.any((element) => element.type == type),
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                whichToShow[type] = !whichToShow[type]!;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    ' ' + name,
                    style: Theme.of(context).textTheme.displaySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  whichToShow[type]! ? Icons.expand_less : Icons.expand_more,
                  size: 50,
                )
              ],
            ),
          ),
          Visibility(
            visible: whichToShow[type]!,
            child: _generateGrid(type, products, count, smallText),
          ),
        ],
      ),
    );
  }

  Widget _generateGrid(ProductType? type, List<Product> allProducts,
      int columnCount, bool smallText) {
    List<Product> products = [];
    if (type == null) {
      //Ajanlott
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
      products
          .sort((product1, product2) => product1.name.compareTo(product2.name));
    }

    if (products.length == 0) return Container();

    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: columnCount,
      children: products.map<Widget>(
        (e) {
          return ProductCard(
            addProductToList: addProductToList,
            product: e,
            small: smallText,
          );
        },
      ).toList(),
    );
  }
}
