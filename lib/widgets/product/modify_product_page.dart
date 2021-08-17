import 'package:estike/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config.dart';

class ModifyProductPage extends StatefulWidget {
  const ModifyProductPage({Key? key}) : super(key: key);

  @override
  _ModifyProductPageState createState() => _ModifyProductPageState();
}

class _ModifyProductPageState extends State<ModifyProductPage> {
  var key = GlobalKey<FormState>();
  Product? product;
  ProductType? typeDropdownValue;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
            Center(
              child: DropdownButton(
                items: Product.allProducts
                    .map<DropdownMenuItem<Product>>(
                      (product) => DropdownMenuItem<Product>(
                          child: Text(
                            product.name,
                          ),
                          value: product),
                    )
                    .toList(),
                hint: Text('Válaszd ki a terméket!'),
                value: product,
                onChanged: (Product? newProduct) {
                  setState(() {
                    this.product = newProduct;
                    typeDropdownValue = product!.type;
                    nameController.text = product!.name;
                    priceController.text = product!.price.toString();
                  });
                },
              ),
            ),
            Visibility(
              visible: product != null,
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
                            updateProduct(
                                product!.id, name, price, typeDropdownValue!);
                            Navigator.pop(context); //TODO: FutureSuccessDialog
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
}
