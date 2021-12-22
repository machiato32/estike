import 'dart:convert';

import 'package:estike/http_handler.dart';
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
    double width = widget.width;
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
