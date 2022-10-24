import 'dart:convert';

import 'package:estike/http_handler.dart';
import 'package:estike/widgets/admin_settings_dialog.dart';
import 'package:estike/widgets/future_success_dialog.dart';
import 'package:estike/widgets/split_view.dart';
import 'package:estike/widgets/user/add_user_page.dart';
import 'package:estike/widgets/user/modify_balance.dart';
import 'package:estike/widgets/user/search_person_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_window_close/flutter_window_close.dart';

import '../config.dart';
import '../database_helper.dart';
import '../models/product.dart';
import '../models/purchase.dart';
import '../models/user.dart';
import 'about_dialog.dart';
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
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      DateTime lastUpdated = DateTime.parse(lastUpdatedAt);
      if (!(User.allUsers
                  .where((element) => element.createdAt.isAfter(lastUpdated))
                  .length ==
              0 &&
          Purchase.allPurchases
                  .where((element) => element.createdAt.isAfter(lastUpdated))
                  .length ==
              0)) {
        return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: const Text(
                      'Töltsd fel az adatokat mielőtt bezárod a programot!'),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Add meg a jelszót!',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5,
                                          textAlign: TextAlign.center,
                                        ),
                                        TextFormField(
                                          controller: passwordController,
                                          obscureText: true,
                                          autofocus: true,
                                          decoration: InputDecoration(
                                            label: Text('Jelszó'),
                                          ),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (String? text) {
                                            if (text == null) {
                                              return 'Jaj!';
                                            }
                                            if (text != adminPassword) {
                                              return 'Helytelen jelszó!';
                                            }
                                            return null;
                                          },
                                          onFieldSubmitted: (text) {
                                            _exitAppControl();
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextButton(
                                          onPressed: _exitAppControl,
                                          child: Text('OK'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).then((value) {
                            passwordController.text = '';
                            if (value != null) Navigator.pop(context, true);
                          });
                        },
                        child: const Text('De én ki akarok lépni!')),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Rendben')),
                  ]);
            });
      }
      return Future.value(true);
    });
  }

  void _exitAppControl() {
    if (passwordController.text == adminPassword) {
      Navigator.pop(context, true);
    }
  }

  void _onAdminSubmitted() {
    if (passwordController.text == adminPassword) {
      Navigator.pop(context);
      passwordController.text = '';
      setState(() {
        adminMode = !adminMode;
      });
    }
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
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          autofocus: true,
                          decoration: InputDecoration(
                            label: Text('Jelszó'),
                          ),
                          onSubmitted: (text) => _onAdminSubmitted(),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          onPressed: _onAdminSubmitted,
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
          child: Padding(
            padding: EdgeInsets.only(right: 12),
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.tertiaryContainer,
              leading: Icon(
                Icons.admin_panel_settings,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              title: Text(
                'Admin mód',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onTertiaryContainer),
              ),
            ),
          ),
        ),
        Visibility(
          visible: debugMode,
          child: Padding(
            padding: EdgeInsets.only(right: 12),
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.tertiaryContainer,
              leading: Icon(
                Icons.bug_report,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              title: Text(
                'Debug mód',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onTertiaryContainer),
              ),
            ),
          ),
        ),
        Visibility(
          visible: cleaningMode,
          child: Padding(
            padding: EdgeInsets.only(right: 12),
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.tertiaryContainer,
              leading: Icon(
                Icons.cleaning_services,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              title: Text(
                'Takarító mód',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onTertiaryContainer),
              ),
            ),
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: ListTile(
            leading: Icon(Icons.attach_money,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: Text(
              "Egyenleg szerkesztése",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            onTap: () {
              Navigator.of(context)
                  .push(
                      MaterialPageRoute(builder: (context) => ModifyBalance()))
                  .then((value) => resetAll());
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: ListTile(
            leading: Icon(
              Icons.person_add,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              "Felhasználó hozzáadása",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AddUserPage()))
                  .then((value) => resetAll());
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: ListTile(
            leading: Icon(Icons.history,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: Text(
              "Előzmények",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => HistoryPage()));
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: ListTile(
            leading: Icon(Icons.arrow_circle_down_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: Text(
              "Letöltés",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            onTap: () async {
              DateTime lastUpdated = DateTime.parse(lastUpdatedAt);
              if (User.allUsers
                          .where((element) =>
                              element.createdAt.isAfter(lastUpdated))
                          .length ==
                      0 &&
                  Purchase.allPurchases
                          .where((element) =>
                              element.createdAt.isAfter(lastUpdated))
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant),
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
        ),
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: ListTile(
            leading: Icon(Icons.arrow_circle_up_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: Text(
              "Feltöltés",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                          Text(
                            'Debug modban nem lehet feltolteni',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: ListTile(
            leading: Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              "Infó",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return OwnAboutDialog();
                  });
            },
          ),
        ),
        Visibility(
          visible: debugMode || adminMode || cleaningMode,
          child: Divider(),
        ),
        Visibility(
          visible: adminMode || debugMode,
          child: Padding(
            padding: EdgeInsets.only(right: 12),
            child: ListTile(
              leading: Icon(Icons.settings,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              title: Text('Admin beállítások',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AdminSettingsDialog();
                    });
              },
            ),
          ),
        ),
        Visibility(
          visible: debugMode || adminMode,
          child: Padding(
            padding: EdgeInsets.only(right: 12),
            child: ListTile(
              leading: Icon(Icons.restart_alt,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              title: Text(
                'Minden adat törlése',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Biztos ki akarsz törölni minden adatot?',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                          ),
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
        ),
        Visibility(
          visible: adminMode,
          child: Padding(
            padding: EdgeInsets.only(right: 12),
            child: ListTile(
              leading: Icon(Icons.logout,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              title: Text(
                'Kilépés admin módból',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => FutureSuccessDialog(
                    future: Future.delayed(Duration(milliseconds: 600)).then(
                      (value) {
                        Navigator.pop(context);
                        adminMode = false;
                        setState(() {});
                        return true;
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Visibility(
          visible: debugMode || adminMode || cleaningMode,
          child: Padding(
            padding: EdgeInsets.only(right: 12),
            child: ListTile(
              leading: Icon(Icons.cleaning_services,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              title: Text(
                cleaningMode ? 'Már nem takarítunk!' : 'Takarítunk!',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => FutureSuccessDialog(
                    future: Future.delayed(Duration(milliseconds: 600)).then(
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
        ),
      ],
    );
    double width = MediaQuery.of(context).size.width;
    bool big = width > 600;
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
    Future.delayed(Duration(milliseconds: 600))
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
    print(decoded);
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lastUpdatedAt = DateTime.now().toIso8601String();
    prefs.setString('last_updated', lastUpdatedAt);
    Future.delayed(Duration(milliseconds: 600))
        .then((value) => _onDownloadData());
    return true;
  }

  void _onDownloadData() {
    Navigator.pop(context);
    setState(() {});
  }

  Future<bool> _uploadData() async {
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
    Future.delayed(Duration(milliseconds: 600))
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
