import 'package:estike/config.dart';
import 'package:estike/models/purchase.dart';
import 'package:estike/models/user.dart';
import 'package:estike/widgets/future_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/product.dart';

class PopIntent extends Intent {
  const PopIntent();
}

class AddUserIntent extends Intent {
  const AddUserIntent();
}

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
  void initState() {
    super.initState();

    int firstFreeId = 100;
    for (User user in User.allUsers
      ..sort((user1, user2) => user1.id.compareTo(user2.id))) {
      if (user.id < 10000 && user.id == firstFreeId) {
        firstFreeId = user.id + 1;
      }
    }
    print(firstFreeId);
    idController.text = firstFreeId.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.escape): PopIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): AddUserIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PopIntent: CallbackAction<PopIntent>(
            onInvoke: (PopIntent intent) => Navigator.pop(context),
          ),
          AddUserIntent: CallbackAction<AddUserIntent>(
            onInvoke: (AddUserIntent intent) => _addUser(),
          )
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
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
                      if (User.allUsers
                          .where((user) => user.id == id)
                          .isNotEmpty) {
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
                      hintText: '0',
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
                      onPressed: _addUser,
                      child: Icon(
                        Icons.send,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addUser() {
    if (passwordController.text == addUserPassword) {
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
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hibás jelszó 😢',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Kérdezd meg Dominikot 😎',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Ha te vagy Dominik, akkor ajánlom, hogy ilyen állapotban ne adj hozzá embereket a számlához',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 8),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<bool> _postUser(String name, int id, int balance) async {
    try {
      await addUser(name, id, balance: balance);
      await addPurchase(id, Product.modifiedBalanceId, balance.toDouble());

      Future.delayed(Duration(milliseconds: 600))
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
