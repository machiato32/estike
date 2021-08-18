import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:estike/config.dart';
import 'package:estike/models/user.dart';
import 'package:estike/widgets/future_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late Future<List<User>>? _users;
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
      } else {
        return User.allUsers;
      }
    } catch (_) {
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(selectedUser == null);
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
                  return DropdownSearch<User>(
                    selectedItem: selectedUser,
                    items: snapshot.data,
                    hint: 'Felhasználó kiválasztása',
                    onChanged: (newUser) {
                      setState(() {
                        selectedUser = newUser;
                      });
                    },
                    showSearchBox: true,
                    filterFn: (user, filter) {
                      return user.name
                              .toLowerCase()
                              .contains(filter.toLowerCase()) ||
                          user.id.toString().contains(filter);
                    },
                    popupItemBuilder: (context, user, isSelected) {
                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.id.toString()),
                      );
                    },
                    dropdownBuilder: (context, user, itemDesignation) {
                      if (user == null) {
                        return Container();
                      }
                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.id.toString()),
                      );
                    },
                  );
                } else {
                  //TODO
                }
              }
              return CircularProgressIndicator();
            },
          ),
          Visibility(
            visible: selectedUser != null,
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Plusz',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    int? balance = int.tryParse(controller.text);
                    if (balance != null) {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return FutureSuccessDialog(
                            future: _updateBalance(balance),
                          );
                        },
                      );
                    } else {
                      //TODO
                    }
                  },
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _updateBalance(int balance) async {
    try {
      if (!isOnline) {
        //TODO save as purchase
        selectedUser!.balance += balance;
        await selectedUser!.update();
      } else {
        Map<String, dynamic> body = {
          'balance_to_add': balance,
        };
        await httpPut(
            context: context,
            uri: '/user/' + selectedUser!.id.toString(),
            body: body);
      }
      Future.delayed(Duration(milliseconds: 300))
          .then((value) => _onUpdateBalance());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onUpdateBalance() {
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
