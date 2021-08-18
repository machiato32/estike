import 'package:estike/models/purchase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'database_helper.dart';
import 'models/product.dart';
import 'models/user.dart';
import 'widgets/user/search_person_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await DatabaseHelper.instance.initDatabase();
    //'seeder'
    // List<Product> drinks = [
    //   Product('Soproni 1895', 300, ProductType.beer),
    //   Product('Soproni', 280, ProductType.beer),
    //   Product('Heineken', 320, ProductType.beer),
    //   Product('Soproni meggy', 350, ProductType.beer),
    //   Product('Bak', 300, ProductType.beer),
    //   Product('Estike koktel', 800, ProductType.cocktail),
    // ];
    // for (Product drink in drinks) {
    //   drink.insert();
    // }
    // List<User> users = [
    //   User(0, 'Hapak Jozsef', 0),
    //   User(1895, 'Bondici Laszlo', 0),
    //   User(33, 'Zsiga Tamas', 0)
    // ];
    // for (User user in users) {
    //   user.insert();
    // }
    // //'seeder' ends
    await initProducts();
    await initUsers();
    await initPurchases();
    // // deleteDatabase(join(await getDatabasesPath(), 'estike_database.db'));
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        cardTheme: CardTheme(
          margin: EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SearchPersonPage(title: 'Estike számla'),
      },
    );
  }
}
