import 'dart:math';

import 'package:estike/models/user.dart';
import 'package:estike/to_english_alphabet_extension.dart';
import 'package:estike/widgets/user/modify_balance_dialog.dart';
import 'package:estike/widgets/user/user_card.dart';
import 'package:flutter/material.dart';

class ModifyBalance extends StatefulWidget {
  const ModifyBalance({Key? key}) : super(key: key);

  @override
  _ModifyBalanceState createState() => _ModifyBalanceState();
}

class _ModifyBalanceState extends State<ModifyBalance> {
  User? selectedUser;
  TextEditingController controller = TextEditingController();
  TextEditingController plusController = TextEditingController();
  String searchWord = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<User> users = User.allUsers;
    if (searchWord != "") {
      users = users
          .where((element) =>
              element.id.toString().contains(searchWord) ||
              element.name.toLowerCase().contains(searchWord.toLowerCase()) ||
              element.name
                  .toLowerCase()
                  .toEnglishAlphabet()
                  .contains(searchWord.toLowerCase().toEnglishAlphabet()))
          .toList();
    }
    //sorts based on number of items bought
    users.sort((user1, user2) => -user1.productsBought.values
        .toList()
        .fold(0, (previous, current) => (previous as int) + current)
        .compareTo(user2.productsBought.values
            .toList()
            .fold(0, (previous, current) => previous + current)));
    double width = MediaQuery.of(context).size.width;
    bool small = false;
    int count = (width / 200).floor();
    if (width < 400) {
      small = true;
      count = (width / 150).floor();
    }
    int usersLength = max(users.length, (count / 2).ceil());

    count = min(count, usersLength);
    return Scaffold(
      appBar: AppBar(
        title: Text("Egyenleg módosítása"),
      ),
      body: ListView(
        padding: EdgeInsets.all(30),
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
          SizedBox(
            height: 10,
          ),
          Visibility(
            visible: users.length != 0,
            child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                ),
                itemCount: min(users.length, 30),
                itemBuilder: (BuildContext context, int index) {
                  return UserCard(
                    user: users[index],
                    small: small,
                    onTap: (context) {
                      setState(() {
                        selectedUser = users[index];
                        showDialog(
                            context: context,
                            builder: (context) {
                              return ModifyBalanceDialog(
                                  selectedUser: selectedUser!);
                            });
                      });
                    },
                    resetTextField: () {
                      setState(() {
                        searchWord = '';
                      });
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}
