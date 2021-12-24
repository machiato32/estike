import 'package:estike/models/purchase.dart';
import 'package:estike/widgets/main_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'database_helper.dart';
import 'models/product.dart';
import 'models/user.dart';
import 'package:estike/config.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString('last_updated')==null){
      prefs.setString('last_updated', DateTime.parse('2021-01-01 00:00:00').toIso8601String());
    }else{
      lastUpdatedAt=prefs.getString('last_updated')!;
    }

  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          color: Colors.orange,
          foregroundColor: Colors.black,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        cardTheme: CardTheme(
          margin: EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
      },
    );
  }
}
