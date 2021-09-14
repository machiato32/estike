import 'package:estike/http_handler.dart';
import 'package:estike/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config.dart';
import '../future_success_dialog.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  var key = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ProductType? typeDropdownValue;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ital hozzáadása'),
        ),
        body: ListView(
          padding: EdgeInsets.all(15),
          children: [
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
                  return 'Jaj!';
                }
                if (text == '') {
                  return 'Nem lehet üres!';
                }
                int? id = int.tryParse(text);
                if (id == null) {
                  return 'Csak szám lehet!';
                }
                return null;
              },
              controller: costController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: InputDecoration(
                labelText: 'Ár',
              ),
            ),
            Center(
              child: DropdownButton(
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
                hint: Text('Az ital típusa'),
                onChanged: (ProductType? type) {
                  setState(() {
                    typeDropdownValue = type!;
                  });
                },
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
                onPressed: () {
                  if (passwordController.text == masterPassword) {
                    if (key.currentState!.validate() &&
                        typeDropdownValue != null) {
                      String name = nameController.text;
                      int cost = int.parse(costController.text);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return FutureSuccessDialog(
                            future:
                                _postProduct(name, cost, typeDropdownValue!),
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
    );
  }

  Future<bool> _postProduct(String name, int cost, ProductType type) async {
    try {
      if (isOnline) {
        Map<String, dynamic> body = {
          'name': name,
          'price': cost,
          'type': generateProductTypeString(type),
        };
        await httpPost(
            context: context,
            uri: generateUri(GetUriKeys.products),
            body: body);
      } else {
        Product product = Product(name, cost, type);
        Product.allProducts.add(product);
        await product.insert();
      }
      Future.delayed(delayTime()).then((value) => _onPostProduct());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onPostProduct() {
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
