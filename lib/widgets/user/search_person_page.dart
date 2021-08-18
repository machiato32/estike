import 'dart:convert';

import 'package:estike/http_handler.dart';
import 'package:estike/widgets/history_page.dart';
import 'package:estike/widgets/product/modify_product_page.dart';
import 'package:estike/widgets/user/modify_balance.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../../models/user.dart';
import 'add_user_page.dart';
import 'user_card.dart';

class SearchPersonPage extends StatefulWidget {
  SearchPersonPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _SearchPersonPageState createState() => _SearchPersonPageState();
}

class _SearchPersonPageState extends State<SearchPersonPage> {
  String searchWord = '';
  TextEditingController controller = TextEditingController();
  Future<List<User>>? _users;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
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
        ),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _generateBody(),
      ),
    );
  }

  @override
  void initState() {
    if (isOnline) {
      _users = null;
      _users = _getUsers();
    }
    super.initState();
  }

  void resetAll() {
    if (isOnline) {
      _users = null;
      _users = _getUsers();
    }
    setState(() {
      controller.clear();
      searchWord = '';
    });
  }

  Widget _generateBody() {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(10),
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              searchWord = value;
            });
          },
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Keresés',
          ),
        ),
        isOnline
            ? FutureBuilder(
                future: _users,
                builder: (context, AsyncSnapshot<List<User>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return _generateGrid(snapshot.data!);
                    } else {
                      //TODO
                    }
                  }
                  return Center(child: CircularProgressIndicator());
                },
              )
            : _generateGrid(User.allUsers),
        SizedBox(
          height: 200,
        ),
      ],
    );
  }

  Future<List<User>> _getUsers() async {
    try {
      http.Response response =
          await httpGet(context: context, uri: generateUri(GetUriKeys.users));
      List<Map<String, dynamic>> decoded = jsonDecode(response.body);
      List<User> users = [];
      for (Map<String, dynamic> decodedUser in decoded) {
        User user = User(
          decodedUser['id'],
          decodedUser['name'],
          decodedUser['balance'],
          createdAt: DateTime.parse(decodedUser['created_at']),
          updatedAt: DateTime.parse(decodedUser['updated_at']),
        );
        user.productsBought = decodedUser['products_bought'];
        users.add(user);
      }
      return users;
    } catch (_) {
      throw _;
    }
  }

  Widget _generateGrid(List<User> users) {
    users.sort((user1, user2) => -user1.productsBought.values
        .toList()
        .fold(0, (previous, current) => (previous as int) + current)
        .compareTo(user2.productsBought.values.toList().fold(
            0,
            (previous, current) =>
                previous + current))); //sorts based on number of items bought
    if (searchWord != "") {
      users = users
          .where((element) =>
              element.id.toString().contains(searchWord) ||
              element.name.toLowerCase().contains(searchWord.toLowerCase()))
          .toList();
    }
    if (users.length == 0) return Container();
    double width = MediaQuery.of(context).size.width;
    bool small = false;
    int count = (width / 200).floor();
    if (width < 400) {
      small = true;
      count = (width / 150).floor();
    }
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: count,
      children: users.map<Widget>(
        (e) {
          return UserCard(
            resetTextField: resetAll,
            user: e,
            small: small,
          );
        },
      ).toList(),
    );
  }
}
