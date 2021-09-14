import 'dart:convert';

import 'package:estike/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../../http_handler.dart';
import '../future_success_dialog.dart';

class ModifyProductPage extends StatefulWidget {
  const ModifyProductPage({Key? key}) : super(key: key);

  @override
  _ModifyProductPageState createState() => _ModifyProductPageState();
}

class _ModifyProductPageState extends State<ModifyProductPage> {
  var key = GlobalKey<FormState>();
  Product? selectedProduct;
  ProductType? typeDropdownValue;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<List<Product>> _getProducts() async {
    //this page is only available in online mode
    try {
      http.Response response = await httpGet(
          context: context, uri: generateUri(GetUriKeys.products));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ital szerkesztése"),
      ),
      body: Form(
        key: key,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            FutureBuilder(
              future: _getProducts(),
              builder: (context, AsyncSnapshot<List<Product>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Center(
                      child: DropdownButton(
                        items: snapshot.data!
                            .map<DropdownMenuItem<Product>>(
                              (product) => DropdownMenuItem<Product>(
                                child: Text(product.name),
                                value: product,
                              ),
                            )
                            .toList(),
                        hint: Text('Válaszd ki a terméket!'),
                        value: selectedProduct,
                        onChanged: (Product? newProduct) {
                          setState(() {
                            this.selectedProduct = newProduct;
                            typeDropdownValue = selectedProduct!.type;
                            nameController.text = selectedProduct!.name;
                            priceController.text =
                                selectedProduct!.price.toString();
                          });
                        },
                      ),
                    );
                  } else {
                    //TODO
                  }
                }
                return CircularProgressIndicator();
              },
            ),
            Visibility(
              visible: selectedProduct != null,
              child: Column(
                children: [
                  DropdownButton(
                    items: ProductType.values
                        .map<DropdownMenuItem<ProductType>>(
                          (type) => DropdownMenuItem<ProductType>(
                            child: Text(
                              humanReadableProductType(type),
                            ),
                            value: type,
                          ),
                        )
                        .toList(),
                    value: typeDropdownValue,
                    onChanged: (ProductType? type) {
                      setState(() {
                        typeDropdownValue = type!;
                      });
                    },
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? text) {
                      if (text == null) {
                        return 'Jaj!';
                      }
                      if (text == '') {
                        return 'Nem lehet üres!';
                      }
                      return null;
                    },
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Név',
                    ),
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? text) {
                      if (text == null) {
                        return 'Nem lehet üres!';
                      }
                      int? id = int.tryParse(text);
                      if (id == null) {
                        return 'Csak szám lehet!';
                      }
                      return null;
                    },
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Kód',
                    ),
                  ),
                  TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Jelszó',
                      hintText: 'Admin jelszó',
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (passwordController.text == masterPassword) {
                          if (key.currentState!.validate()) {
                            String name = nameController.text;
                            int price = int.parse(priceController.text);
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return FutureSuccessDialog(
                                  future: _updateProduct(name, price),
                                );
                              },
                            );
                          }
                        } else {
                          //TODO: this
                        }
                      },
                      child: Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _updateProduct(String name, int price) async {
    try {
      Map<String, dynamic> body = {
        'name': name,
        'price': price,
        'type': generateProductTypeString(typeDropdownValue!),
      };
      await httpPut(
        context: context,
        uri: '/product/' + selectedProduct!.id.toString(),
        body: body,
      );
      Future.delayed(Duration(milliseconds: 300))
          .then((value) => _onUpdateProduct());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onUpdateProduct() {
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
