import 'dart:math';

import 'package:estike/models/product.dart';
import 'package:estike/models/purchase.dart';
import 'package:estike/widgets/product/product_page.dart';
import 'package:estike/widgets/user/cashButton.dart';
import 'package:flutter/material.dart';

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

  void sortUsers() {
    _users.sort((user1, user2) => compareUsers(user1, user2));
    if (cleaningMode) {
      List<User> bartenders =
          _users.where((element) => element.id == User.bartenderId).toList();
      if (bartenders.isNotEmpty) {
        User bartender = bartenders.first;
        _users.remove(bartender);
        _users.insert(0, bartender);
      }
    }
  }

  int compareUsers(User user1, User user2) {
    double value1 = userValue(user1);
    double value2 = userValue(user2);
    return value2.compareTo(value1);
  }

  double userValue(User user) {
    double value = (100000 - user.id) / 1000000;
    List<Purchase> purchases = Purchase.allPurchases
        .where((element) =>
            element.userId == user.id &&
            element.productId != Product.modifiedBalanceId)
        .toList();
    for (Purchase purchase in purchases) {
      value += purchase.amount;
    }
    if (purchases.isNotEmpty) {
      DateTime now = DateTime.now();
      purchases = purchases
          .where((element) =>
              now.difference(element.createdAt) < Duration(days: 1))
          .toList();
      for (Purchase purchase in purchases) {
        value += purchase.amount * 3;
      }
    }
    return value;
  }

  Widget _generateGrid() {
    _users = User.allUsers.toList();
    if (!cleaningMode) {
      _users = _users
          .where((element) => element.id != User.bartenderId)
          .toList(); //Show csapos user only when cleaning
    }
    if (searchWord != "") {
      _users = _users
          .where((element) =>
              element.id.toString().contains(searchWord) ||
              element.name.toLowerCase().contains(searchWord.toLowerCase()))
          .toList();
    }
    sortUsers();
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
