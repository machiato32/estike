import 'package:estike/widgets/product/add_product_page.dart';
import 'package:estike/widgets/product/modify_product_page.dart';
import 'package:estike/widgets/split_view.dart';
import 'package:estike/widgets/user/add_user_page.dart';
import 'package:estike/widgets/user/modify_balance.dart';
import 'package:estike/widgets/user/search_person_page.dart';
import 'package:flutter/material.dart';

import '../config.dart';
import 'history/history_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var key = GlobalKey<State>();
  late SearchPersonPage searchPersonPage;
  @override
  void initState() {
    searchPersonPage = SearchPersonPage(
      key: key,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplitView(
          drawer: ListView(
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
                      .push(MaterialPageRoute(
                          builder: (context) => ModifyBalance()))
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
                      .push(MaterialPageRoute(
                          builder: (context) => AddUserPage()))
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
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddProductPage()));
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
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ModifyProductPage()));
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
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HistoryPage()));
                },
              ),
            ],
          ),
          rightWidget: searchPersonPage),
    );
  }
}
