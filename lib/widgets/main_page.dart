import 'dart:convert';

import 'package:estike/http_handler.dart';
import 'package:estike/widgets/future_success_dialog.dart';
import 'package:estike/widgets/split_view.dart';
import 'package:estike/widgets/user/add_user_page.dart';
import 'package:estike/widgets/user/modify_balance.dart';
import 'package:estike/widgets/user/search_person_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../database_helper.dart';
import '../models/product.dart';
import '../models/purchase.dart';
import '../models/user.dart';
import 'history/history_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Widget drawer;
  bool tapped = false;
  bool doubleTapped = false;
  TextEditingController passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    drawer = ListView(
      controller: ScrollController(),
      children: [
        GestureDetector(
          onTap: () {
            tapped = !tapped;
          },
          onDoubleTap: () {
            if (tapped) {
              doubleTapped = !doubleTapped;
            }
          },
          onLongPress: () {
            if (tapped && doubleTapped) {
              tapped = false;
              doubleTapped = false;
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          adminMode
                              ? 'Kilépés admin módból'
                              : 'Belépés admin módba',
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.center,
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          autofocus: true,
                          decoration: InputDecoration(
                            label: Text('Jelszó'),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          onPressed: () {
                            if (passwordController.text == adminPassword) {
                              Navigator.pop(context);
                              passwordController.text = '';
                              setState(() {
                                adminMode = !adminMode;
                              });
                            }
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Image.asset('assets/estike_logo.png'),
            ),
          ),
        ),
        Visibility(
          visible: adminMode,
          child: ListTile(
            tileColor: Colors.green,
            leading: Icon(Icons.admin_panel_settings),
            title: Text('Admin mód'),
          ),
        ),
        Visibility(
          visible: debugMode,
          child: ListTile(
            tileColor: Colors.green,
            leading: Icon(Icons.bug_report),
            title: Text('Debug mód'),
          ),
        ),
        Visibility(
          visible: cleaningMode,
          child: ListTile(
            tileColor: Colors.green,
            leading: Icon(Icons.cleaning_services),
            title: Text('Takarító mód'),
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(
            Icons.attach_money,
          ),
          title: Text(
            "Egyenleg szerkesztése",
          ),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ModifyBalance()))
                .then((value) => resetAll());
          },
        ),
        ListTile(
          leading: Icon(
            Icons.person_add,
          ),
          title: Text(
            "Felhasználó hozzáadása",
          ),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddUserPage()))
                .then((value) => resetAll());
          },
        ),
        ListTile(
          leading: Icon(
            Icons.history,
          ),
          title: Text(
            "Előzmények",
          ),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HistoryPage()));
          },
        ),
        ListTile(
          leading: Icon(
            Icons.arrow_circle_down_outlined,
          ),
          title: Text(
            "Letöltés",
          ),
          onTap: () async {
            DateTime lastUpdated = DateTime.parse(lastUpdatedAt);
            print(Purchase.allPurchases);
            if (User.allUsers
                        .where(
                            (element) => element.createdAt.isAfter(lastUpdated))
                        .length ==
                    0 &&
                Purchase.allPurchases
                        .where(
                            (element) => element.createdAt.isAfter(lastUpdated))
                        .length ==
                    0) {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => FutureSuccessDialog(
                        future: _downloadData(),
                      ));
            } else {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Előbb töltsd fel az adatokat!',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  });
            }
          },
        ),
        ListTile(
          leading: Icon(
            Icons.arrow_circle_up_outlined,
          ),
          title: Text(
            "Feltöltés",
          ),
          onTap: () async {
            if (debugMode == false) {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => FutureSuccessDialog(
                  future: _uploadData(),
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Debug modban nem lehet feltolteni'),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
        Visibility(
          visible: debugMode || adminMode,
          child: ListTile(
            leading: Icon(Icons.restart_alt),
            title: Text('Minden adat törlése'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Biztos ki akarsz törölni minden adatot?'),
                        TextButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => FutureSuccessDialog(
                                    future: _deleteEverything()));
                          },
                          child: Text('Igen'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Visibility(
          visible: debugMode || adminMode,
          child: ListTile(
            leading: Icon(Icons.cleaning_services),
            title: Text(cleaningMode ? 'Már nem takarítunk!' : 'Takarítunk!'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => FutureSuccessDialog(
                  future: Future.delayed(Duration(milliseconds: 300)).then(
                    (value) {
                      Navigator.pop(context);
                      cleaningMode = !cleaningMode;
                      if (cleaningMode) {
                        adminMode = false;
                      }
                      setState(() {});
                      return true;
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
    double width = MediaQuery.of(context).size.width;
    bool big = width > 1200;
    return Scaffold(
      appBar: big
          ? null
          : AppBar(
              title: Text('Estike'),
            ),
      drawer: big
          ? null
          : Drawer(
              child: drawer,
            ),
      body: SplitView(
        drawer: drawer,
        rightWidget: SearchPersonPage(
          width: big ? width * 0.8 : width,
        ),
      ),
    );
  }

  Future<bool> _deleteEverything() async {
    lastUpdatedAt = DateTime.now().toIso8601String();
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('last_updated', lastUpdatedAt);
    await DatabaseHelper.instance.deleteDb();
    User.allUsers = [];
    Product.allProducts = [];
    Purchase.allPurchases = [];
    Product.maxId = 0;
    Future.delayed(Duration(milliseconds: 300))
        .then((value) => _onDeleteEverything());
    await DatabaseHelper.instance.initDatabase();
    return true;
  }

  void _onDeleteEverything() {
    Navigator.pop(context);
    Navigator.pop(context);
    setState(() {});
  }

  Future<bool> _downloadData() async {
    http.Response response = await httpGet(context: context, uri: '/import');
    dynamic decoded = jsonDecode(response.body);
    print(decoded['users'][0]['name']);
    List<dynamic> users = decoded['users'];
    List<dynamic> products = decoded['products'];
    print(decoded['products']);
    // await DatabaseHelper.instance.deleteDb();
    User.allUsers = [];
    for (Product product in Product.allProducts) {
      await product.delete(onlyFromDb: true);
    }
    Product.allProducts = [];
    Purchase.allPurchases = []; //ez nem biztos hogy kell
    for (Map<String, dynamic> user in users) {
      await addUser(user['name'], user['id'],
          balance: user['balance'],
          createdAt: user['created_at'] != null
              ? DateTime.parse(user['created_at'])
              : DateTime.now(),
          updatedAt: user['updated_at'] != null
              ? DateTime.parse(user['updated_at'])
              : DateTime.now());
    }
    for (Map<String, dynamic> product in products) {
      await addProduct(product['name'], product['price'],
          productTypeFromString(product['type']),
          id: product['id'],
          createdAt: product['created_at'] != null
              ? DateTime.parse(product['created_at'])
              : DateTime.now(),
          updatedAt: product['updated_at'] != null
              ? DateTime.parse(product['updated_at'])
              : DateTime.now(),
          enabled: product['deleted_at'] == null);
    }
    initPurchases();
    Future.delayed(Duration(milliseconds: 300))
        .then((value) => _onDownloadData());
    return true;
  }

  void _onDownloadData() {
    Navigator.pop(context);
    setState(() {});
  }

  Future<bool> _uploadData() async {
    // lastUpdatedAt="2019-01-01T00:00:00.000Z";
    Map<String, dynamic> body = {
      'users': User.allUsers
          .where((element) =>
              element.updatedAt.isAfter(DateTime.parse(lastUpdatedAt)))
          .map((user) => {
                'name': user.name,
                'id': user.id,
                'balance': user.balance,
                'updated_at': user.updatedAt.toIso8601String(),
                'created_at': user.createdAt.toIso8601String()
              })
          .toList(),
      'purchases': Purchase.allPurchases
          .where((element) =>
              element.updatedAt.isAfter(DateTime.parse(lastUpdatedAt)))
          .map((purchase) => {
                'user_id': purchase.userId == -1 ? null : purchase.userId,
                'product_id':
                    purchase.productId == -1 ? null : purchase.productId,
                'amount': purchase.amount,
                'created_at': purchase.createdAt.toIso8601String(),
                'updated_at': purchase.updatedAt.toIso8601String()
              })
          .toList(),
    };
    print(body);
    await httpPost(context: context, uri: '/export', body: body);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lastUpdatedAt = DateTime.now().toIso8601String();
    prefs.setString('last_updated', lastUpdatedAt);
    Future.delayed(Duration(milliseconds: 300))
        .then((value) => _onUploadData());
    return true;
  }

  void _onUploadData() {
    Navigator.pop(context);
    setState(() {});
  }

  void resetAll() {
    setState(() {});
  }
}
