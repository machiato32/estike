import 'package:estike/config.dart';
import 'package:estike/models/user.dart';
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
                  return 'Nem lehet üres!';
                }
                int? id = int.tryParse(text);
                if (id == null) {
                  return 'Csak szám lehet!';
                }
                if (User.allUsers.where((user) => user.id == id).isNotEmpty) {
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
                      addUser(name, id);
                      Navigator.pop(context); //TODO: FutureSuccessDialog
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
}
