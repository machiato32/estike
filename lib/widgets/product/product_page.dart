import 'dart:convert';

import 'package:estike/models/purchase.dart';
import 'package:estike/widgets/future_success_dialog.dart';
import 'package:estike/widgets/product/product_ledger_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<FocusNode> nodes = [];
  int nodeNum = 0;
  Map<Product, double> productsToBuy = {};
  bool small = false;
  Future<List<Product>>? _products;

  Map<ProductType, bool> whichToShow = {
    ProductType.beer:false,
    ProductType.wine:false,
    ProductType.cocktail:false,
    ProductType.long:false,
    ProductType.shot:false,
    ProductType.other:false,
    ProductType.meal:false,
    ProductType.soda:false,    
  };

  @override
  void initState() {
    if (isOnline) {
      _products = null;
      _products = _getProducts();
    }
    super.initState();
  }

  void resetAll() {
    if (isOnline) {
      _products = null;
      _products = _getProducts();
    }
  }

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
                          future: _products,
                          builder:
                              (context, AsyncSnapshot<List<Product>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return _generateLeftUpperPart(snapshot.data!);
                              } else {
                                return Text(snapshot.error.toString());
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
                0: FractionColumnWidth(0.6),
                1: FractionColumnWidth(0.4),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: isOnline
                          ? FutureBuilder(
                              future: _products,
                              builder: (context,
                                  AsyncSnapshot<List<Product>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return _generateLeftUpperPart(
                                        snapshot.data!);
                                  } else {
                                    return Text(snapshot.error.toString());
                                  }
                                }
                                return CircularProgressIndicator();
                              },
                            )
                          : _generateLeftUpperPart(Product.allProducts.where((element) => element.enabled).toList()),
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
      http.Response response = await httpGet(
          context: context, uri: generateUri(GetUriKeys.products));
      dynamic decoded = jsonDecode(response.body);
      List<Product> products = [];
      for (Map<String, dynamic> decodedProduct in decoded) {
        Product product = Product(
          decodedProduct['name'],
          decodedProduct['price'],
          productTypeFromString(decodedProduct['type']),
          id: decodedProduct['id'],
          enabled: decodedProduct['deleted_at']==null
        );
        // product.peopleBuying = decodedProduct['people_buying'];
        products.add(product);
      }
      return products;
    } catch (_) {
      throw _;
    }
  }

  void halfProductOnList(Product product){
    setState(() {
      if (productsToBuy.containsKey(product)) {
        if(productsToBuy[product]!<=0.5){
          productsToBuy.remove(product);
        }else{
          productsToBuy[product] = productsToBuy[product]! - 1/2;
        }
      } else {
        productsToBuy[product] = 0.5;
      }
    });
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
              onPressed: () async {
                if (productsToBuy.keys.length != 0) {
                  // if (sum(productsToBuy) <= widget.user.balance) {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return FutureSuccessDialog(future: _postPurchases(usesCash: widget.user.id==-1));
                      },
                    );
                  // }
                }
              },
              child: Icon(
                Icons.send,
                color: Colors.black,
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
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        )),
    );
  }

  Future<bool> _postPurchases({bool usesCash=false}) async {
    try {
      if (isOnline) {
        Map<String, dynamic> body = {
          'customerId': widget.user.id,
          'products': productsToBuy.keys.map((product) {
            return {
              'productId': product.id,
              'quantity': productsToBuy[product],
            };
          }).toList(),
          'happenedAt': DateTime.now().toIso8601String(),
        };
        print(body);
        await httpPost(context: context, uri: '/purchase', body: body);
      } else {
        if(usesCash){
          for (Product product in productsToBuy.keys) {
            await addPurchase(
                  widget.user.id, product.id, productsToBuy[product]!);
          }
        }else{
          for (Product product in productsToBuy.keys) {
            widget.user.addBoughProduct(product, number: productsToBuy[product]!.ceil());
            product.addPersonBuying(widget.user, productsToBuy[product]!.ceil());
            await addPurchase(
                widget.user.id, product.id, productsToBuy[product]!);
          }
          widget.user.balance -= sum(productsToBuy).ceil();
          await widget.user.update();
        }
        
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
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      width = 6 * width / 10;
    }
    small = false;
    int count = (width / 200).floor();
    if (width < 400) {
      small = true;
      count = (width / 150).floor();
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
                style: Theme.of(context).textTheme.headline3,
              ),
              _generateGrid(null, products, count),
            ],
          ),
        ),
        _productTypeWidget(products, count, ProductType.beer),
        _productTypeWidget(products, count, ProductType.long),
        _productTypeWidget(products, count, ProductType.shot),
        _productTypeWidget(products, count, ProductType.wine),
        _productTypeWidget(products, count, ProductType.cocktail),
        _productTypeWidget(products, count, ProductType.soda),
        _productTypeWidget(products, count, ProductType.meal),        
        _otherButton(count),
        SizedBox(
          height: 200,
        ),
      ],
    );
  }
  Widget _productTypeWidget(List<Product> products, int count, ProductType type) {
    String name='';
    switch(type){
      case ProductType.beer:
        name='Sörök';
        break;
      case ProductType.long:
        name='Hosszú italok';
        break;
      case ProductType.shot:
        name='Rövid italok';
        break;
      case ProductType.wine:
        name='Borok';
        break;
      case ProductType.cocktail:
        name='Koktélok';
        break;
      case ProductType.soda:
        name='Üdítők';
        break;
      case ProductType.meal:
        name='Ételek';
        break;
      case ProductType.other:
        name='Egyebek';
        break;
    }
    return Column(
      children: [
        TextButton(
          onPressed: (){
            setState(() {
              whichToShow[type]=!whichToShow[type]!;
            });
          },
          child: 
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headline3,
              ),
              Icon(
                whichToShow[type]!?Icons.expand_less:Icons.expand_more,
                size: 50,
              )
            ],
          ),
        ),
        Visibility(
          visible: whichToShow[type]!,
          child: _generateGrid(type, products, count)
        ),
      ],
    );
  }

  Widget _otherButtonDialog(TextEditingController controller){
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Vonj le valamennyit!', style: Theme.of(context).textTheme.headline5,),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Összeg',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              validator: (String? text){
                if(text==null || text.isEmpty){
                  return 'Kérlek írd be az összeget!';
                }
                if(double.tryParse(text)==null){
                  return 'Kérlek írj számot!';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              child: Icon(Icons.send),
              onPressed: (){
                if(controller.text!='' && int.tryParse(controller.text) != null){
                  double amount = double.parse(controller.text);
                  widget.user.balance-=amount.ceil();
                  addPurchase(widget.user.id, -1, -amount);
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _otherButton(int count){
    return Visibility(
          visible: widget.user.id!=-1,
          child: AspectRatio(
            aspectRatio: count.toDouble()*2, 
            child: Card(
              color: Theme.of(context).colorScheme.primary,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  TextEditingController controller = TextEditingController();
                  showDialog(
                    context: context, 
                    builder: (context){
                      return _otherButtonDialog(controller);
                    }
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      Material(
                        color: Colors.transparent,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Egyéni",
                              style: small
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.headline4!.copyWith(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            Flexible(
                              child: Icon(
                                Icons.construction,
                                color: Colors.black,
                                size: small
                                    ? 20
                                    : 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }

  Widget _generateGrid(ProductType? type, List<Product> allProducts, int count) {
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
