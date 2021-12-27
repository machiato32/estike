import 'dart:convert';
import 'dart:math';

import 'package:estike/config.dart';
import 'package:estike/models/user.dart';
import 'package:estike/widgets/user/modify_balance_dialog.dart';
import 'package:estike/widgets/user/user_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../http_handler.dart';

class ModifyBalance extends StatefulWidget {
  const ModifyBalance({Key? key}) : super(key: key);

  @override
  _ModifyBalanceState createState() => _ModifyBalanceState();
}

class _ModifyBalanceState extends State<ModifyBalance> {
  User? selectedUser;
  TextEditingController controller = TextEditingController();
  TextEditingController plusController = TextEditingController();
  late Future<List<User>>? _users;
  String searchWord='';
  @override
  void initState() {
    _users = null;
    _users = _getUsers();
    super.initState();
  }

  Future<List<User>> _getUsers() async {
    try {
      if (isOnline) {
        http.Response response =
            await httpGet(context: context, uri: generateUri(GetUriKeys.users));
        print(response.body);
        List<dynamic> decoded = jsonDecode(response.body);
        List<User> users = [];
        for (Map<String, dynamic> decodedUser in decoded) {
          User user = User(
            decodedUser['id'],
            decodedUser['name'],
            decodedUser['balance'],
          );
          users.add(user);
        }
        return users;
      } else {
        return User.allUsers;
      }
    } catch (_) {
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Egyenleg módosítása"),
      ),
      body: ListView(
        padding: EdgeInsets.all(30),
        children: [
          FutureBuilder(
            future: _users,
            builder: (context, AsyncSnapshot<List<User>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data != null) {
                  List<User> users = snapshot.data!;
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
                  double width = MediaQuery.of(context).size.width;
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
                            onTap: (context){
                              setState(() {
                                selectedUser = users[index];
                                showDialog(
                                  context: context,
                                  builder: (context){
                                    return ModifyBalanceDialog(selectedUser: selectedUser!);
                                  }
                                );
                              });
                            },
                            resetTextField: () {
                              setState(() {
                                searchWord = '';
                              });
                            },
                          );
                        }
                      ),
                    ],
                  );
                } else {
                  return Text(snapshot.error.toString());
                  //TODO
                }
              }
              return CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }

  
}
