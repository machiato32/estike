import 'dart:math';

import 'package:estike/widgets/product/product_page.dart';
import 'package:estike/widgets/user/cashButton.dart';
import 'package:flutter/material.dart';

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
  List<User> _users = User.allUsers;
  FocusNode _focusNode = FocusNode();
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
          TextFormField(
            autofocus: true,
            focusNode: _focusNode,
            onChanged: (value) {
              setState(() {
                searchWord = value;
              });
            },
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Keresés',
            ),
            onFieldSubmitted: (String? text) {
              if (text != null && text != '' && _users.length != 0) {
                User user = _users[0];
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => ProductPage(user: user)))
                    .then((value) => resetAll());
              }
            },
          ),
          _generateGrid(),
          SizedBox(
            height: 200,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void resetAll() {
    setState(() {
      controller.clear();
      searchWord = '';
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  Widget _generateGrid() {
    _users = User.allUsers;
    if (searchWord != "") {
      _users = _users
          .where((element) =>
              element.id.toString().contains(searchWord) ||
              element.name.toLowerCase().contains(searchWord.toLowerCase()))
          .toList();
    }
    //sorts based on number of items bought
    _users.sort((user1, user2) => -user1.productsBought.values
        .toList()
        .fold(0, (previous, current) => (previous as int) + current)
        .compareTo(user2.productsBought.values
            .toList()
            .fold(0, (previous, current) => previous + current)));
    if (_users.length == 0) return Container();
    double widgetWidth = widget.width;
    bool smallText = false;
    int columnCount = (widgetWidth / 200).floor();
    if (widgetWidth < 400) {
      smallText = true;
      columnCount = (widgetWidth / 150).floor();
    }
    int usersLength = max(_users.length, (columnCount / 2).ceil());

    columnCount = min(columnCount, usersLength);
    return Column(
      children: [
        CashButton(
            smallText: smallText,
            isVisible: searchWord == "",
            columnCount: columnCount,
            resetAll: resetAll),
        GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount,
            ),
            itemCount: min(_users.length, 30),
            itemBuilder: (BuildContext context, int index) {
              return UserCard(
                user: _users[index],
                small: smallText,
                resetTextField: resetAll,
              );
            }),
      ],
    );
  }
}
