import 'dart:convert';

import 'package:estike/database_helper.dart';
import 'package:estike/http_handler.dart';
import 'package:estike/widgets/product/add_product_page.dart';
import 'package:estike/widgets/product/modify_product_page.dart';
import 'package:estike/widgets/split_view.dart';
import 'package:estike/widgets/user/add_user_page.dart';
import 'package:estike/widgets/user/modify_balance.dart';
import 'package:estike/widgets/user/search_person_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import 'history/history_page.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/purchase.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Widget drawer;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    drawer = ListView(
      controller: ScrollController(),
      children: [
        DrawerHeader(
          child: Center(
            child: Text(
              'Estike',
              style: Theme.of(context).textTheme.headline3,
            ),
          ),
        ),
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
        Visibility(
          visible: isOnline,
          child: ListTile(
            leading: Icon(
              Icons.add,
            ),
            title: Text(
              "Ital hozzáadása",
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddProductPage()));
            },
          ),
        ),
        Visibility(
          visible: isOnline,
          child: ListTile(
            leading: Icon(
              Icons.edit,
            ),
            title: Text(
              "Italok szerkesztése",
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ModifyProductPage()));
            },
          ),
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
            DateTime lastUpdated=DateTime.parse(lastUpdatedAt);

            if(User.allUsers.where((element) => element.createdAt.isAfter(lastUpdated)).length==0 && Purchase.allPurchases.where((element) => element.createdAt.isAfter(lastUpdated)).length==0){
              http.Response response = await httpGet(context: context, uri: '/import');
              dynamic decoded = jsonDecode(response.body);
              print(decoded['users'][0]['name']);
              List<dynamic> users = decoded['users'];
              List<dynamic> products = decoded['products'];

              // await DatabaseHelper.instance.deleteDb();
              User.allUsers=[];
              Product.allProducts=[];
              // Purchase.allPurchases=[];//ez nem biztos hogy kell
              for (Map<String, dynamic> user in users) {
                await addUser(user['name'], user['id'], balance: user['balance'], createdAt: user['created_at']!=null?DateTime.parse(user['created_at']):DateTime.now(), updatedAt: user['updated_at']!=null?DateTime.parse(user['updated_at']):DateTime.now());
              }
              for(Map<String, dynamic> product in products) {
                await addProduct(product['name'], product['price'], productTypeFromString(product['type']), id: product['id'], createdAt: product['created_at']!=null?DateTime.parse(product['created_at']):DateTime.now(), updatedAt: product['updated_at']!=null?DateTime.parse(product['updated_at']):DateTime.now());
              }

              setState(() {
                
              });
            }else{
              //TODO
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
            Map<String, dynamic> body={
              'users': User.allUsers.where((element) => element.createdAt.isAfter(DateTime.parse(lastUpdatedAt))).map((user) => {
                'name': user.name,
                'id': user.id,
                'balance': user.balance,
                'updated_at': user.updatedAt.toIso8601String(),
                'created_at': user.createdAt.toIso8601String()
              }).toList(),
              'purchases': Purchase.allPurchases.where((element) => element.createdAt.isAfter(DateTime.parse(lastUpdatedAt))).map((purchase) => {
                'user_id': purchase.userId,
                'product_id': purchase.productId==-1?null:purchase.productId,
                'amount': purchase.amount,
                'created_at': purchase.createdAt.toIso8601String(),
                'updated_at': purchase.updatedAt.toIso8601String()
              }).toList(),
            };
            print(body);
            await httpPost(context: context, uri: '/export', body: body);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('last_updated', lastUpdatedAt);
            lastUpdatedAt=DateTime.now().toIso8601String();
            
            setState(() {
              
            });
          },
        ),
      ],
    );
    double width = MediaQuery.of(context).size.width;
    bool big = width > 1200;
    return Scaffold(
      appBar: AppBar(
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
          width: big ? width * 0.7 : width,
        ),
      ),
    );
  }

  void resetAll() {
    setState(() {});
  }
}
