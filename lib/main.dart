import 'package:estike/models/purchase.dart';
import 'package:estike/widgets/main_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';
import 'models/product.dart';
import 'models/user.dart';
import 'package:estike/config.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initDatabase();
  await initProducts();
  await initUsers();
  await initPurchases();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('last_updated')) {
    lastUpdatedAt = prefs.getString('last_updated')!;
  } else {
    prefs.setString('last_updated',
        DateTime.parse('2021-01-01 00:00:00').toIso8601String());
    lastUpdatedAt = DateTime.parse('2021-01-01 00:00:00').toIso8601String();
  }
  if (prefs.containsKey('admin_password')) {
    adminPassword = prefs.getString('admin_password')!;
  } else {
    prefs.setString('admin_password', adminPassword);
  }
  if (prefs.containsKey('add_user_password')) {
    addUserPassword = prefs.getString('add_user_password')!;
  } else {
    prefs.setString('add_user_password', addUserPassword);
  }
  if (prefs.containsKey('app_url')) {
    APP_URL = prefs.getString('app_url')!;
  } else {
    prefs.setString('app_url', APP_URL);
  }
  if (prefs.containsKey('recycled_can_price')) {
    recycledCanPrice = prefs.getInt('recycled_can_price')!;
  } else {
    prefs.setInt('recycled_can_price', recycledCanPrice);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.orange, brightness: Brightness.dark);
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('hu'),
      ],
      debugShowCheckedModeBanner: false,
      title: 'Estike',
      theme: ThemeData.from(
        colorScheme: colorScheme,
        useMaterial3: true,
      ).copyWith(
        listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
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
