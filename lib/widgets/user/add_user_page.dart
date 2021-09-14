import 'package:estike/config.dart';
import 'package:estike/http_handler.dart';
import 'package:estike/models/user.dart';
import 'package:estike/widgets/future_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController balanceController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Felhasználó hozzáadása"),
      ),
      body: Form(
        key: key,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? text) {
                if (text == null) {
                  return 'Jaj!';
                }
                if (text == '') {
                  return 'Nem lehet üres!';
                }
                return null;
              },
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Név',
              ),
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? text) {
                if (text == null) {
                  return 'Jaj!';
                }
                if (text == '') {
                  return 'Nem lehet üres!';
                }
                int? id = int.tryParse(text);
                if (id == null) {
                  return 'Csak szám lehet!';
                }
                if (User.allUsers.where((user) => user.id == id).isNotEmpty) {
                  //TODO: online? -> le kell kerni az osszes userId-t
                  return 'Már foglalt!';
                }
                return null;
              },
              controller: idController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: InputDecoration(
                labelText: 'Kód',
              ),
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? text) {
                if (text == null) {
                  return 'Jaj!';
                }
                int? id = int.tryParse(text);
                if (id == null && text != '') {
                  return 'Csak szám lehet!';
                }
                return null;
              },
              controller: balanceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: InputDecoration(
                labelText: 'Kezdőtőke',
              ),
            ),
            TextField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Jelszó',
                hintText: 'Admin jelszó',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (passwordController.text == masterPassword) {
                    if (key.currentState!.validate()) {
                      String name = nameController.text;
                      int id = int.parse(idController.text);
                      int balance = 0;
                      if (balanceController.text != '') {
                        balance = int.parse(balanceController.text);
                      }
                      showDialog(
                        context: context,
                        builder: (context) {
                          return FutureSuccessDialog(
                            future: _postUser(name, id, balance),
                          );
                        },
                      );
                    }
                  } else {
                    //TODO: this
                  }
                },
                child: Icon(Icons.send),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _postUser(String name, int id, int balance) async {
    try {
      if (isOnline) {
        Map<String, dynamic> body = {
          'name': name,
          'id': id,
          'balance': balance,
        };
        await httpPost(
            context: context, uri: generateUri(GetUriKeys.users), body: body);
      } else {
        await addUser(name, id, balance: balance);
      }
      Future.delayed(Duration(milliseconds: 300))
          .then((value) => _onPostUser());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onPostUser() {
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
