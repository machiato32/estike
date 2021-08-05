import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'search_person_page.dart';
import 'package:flutter/widgets.dart';
import 'database_helper.dart';
import 'models/drink.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await DatabaseHelper.instance.initDatabase();
    //'seeder'
    List<Drink> drinks = [
      Drink('Soproni 1895', 300, DrinkType.beer),
      Drink('Soproni', 280, DrinkType.beer),
      Drink('Heineken', 320, DrinkType.beer),
      Drink('Soproni meggy', 350, DrinkType.beer),
      Drink('Bak', 300, DrinkType.beer),
      Drink('Estike koktel', 800, DrinkType.cocktail),
    ];
    for (Drink drink in drinks) {
      drink.insert();
    }
    //'seeder ends'
    initDrinks();
    // deleteDatabase(join(await getDatabasesPath(), 'estike_database.db'));
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
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
