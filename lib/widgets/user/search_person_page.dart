import 'dart:convert';
import 'dart:math';

import 'package:estike/http_handler.dart';
import 'package:estike/widgets/product/product_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../../models/user.dart';
import 'user_card.dart';

class SearchPersonPage extends StatefulWidget {
  final double width;
  SearchPersonPage({Key? key, required this.width}) : super(key: key);

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
      child: ListView(
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
                        return Text(snapshot.error.toString());
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

  Future<List<User>> _getUsers() async {
    try {
      http.Response response =
          await httpGet(context: context, uri: generateUri(GetUriKeys.users));
      dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List<User> users = [];
      for (Map<String, dynamic> decodedUser in decoded) {
        User user = User(
          decodedUser['id'],
          decodedUser['name'],
          decodedUser['balance'],
        );
        // user.productsBought = decodedUser['products_bought'];
        users.add(user);
      }
      return users;
    } catch (_) {
      throw _;
    }
  }

  Widget _generateGrid(List<User> users) {
    if (searchWord != "") {
      users = users
          .where((element) =>
              element.id.toString().contains(searchWord) ||
              element.name.toLowerCase().contains(searchWord.toLowerCase()))
          .toList();
    }
    //sorts based on number of items bought
    users.sort((user1, user2) => -user1.productsBought.values
        .toList()
        .fold(0, (previous, current) => (previous as int) + current)
        .compareTo(user2.productsBought.values.toList().fold(
            0,
            (previous, current) =>
                previous + current))); 
    if (users.length == 0) return Container();
    double width = widget.width;
    bool small = false;
    int count = (width / 200).floor();
    if (width < 400) {
      small = true;
      count = (width / 150).floor();
    }
    int usersLength=max(users.length,(count/2).ceil());
    
    count=min(count, usersLength);
    return Column(
      children: [
        Visibility(
          visible: searchWord=="",
          child: AspectRatio(
            aspectRatio: count.toDouble()*2, 
            child: Card(
              color: Theme.of(context).colorScheme.primary,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => ProductPage(user: User(-1, 'Készpénz', 0))))
                      .then((value) => resetAll());
                },
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      Material(
                        color: Colors.transparent,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Készpénz",
                              style: small
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.headline4!.copyWith(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            Flexible(
                              child: Icon(
                                Icons.attach_money,
                                color: Colors.black,
                                size: small
                                    ? 20
                                    : 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
          ), 
          itemCount: min(users.length, 30),
          itemBuilder: (BuildContext context, int index){
            return UserCard(
              user: users[index],
              small: small,
              resetTextField: resetAll,
            );
          }
        ),
      ],
    );
  }
}
