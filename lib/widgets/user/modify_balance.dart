import 'package:estike/config.dart';
import 'package:estike/models/user.dart';
import 'package:estike/widgets/future_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart';

class ModifyBalance extends StatefulWidget {
  const ModifyBalance({Key? key}) : super(key: key);

  @override
  _ModifyBalanceState createState() => _ModifyBalanceState();
}

class _ModifyBalanceState extends State<ModifyBalance> {
  User? selectedUser;
  TextEditingController controller = TextEditingController();
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
          DropdownSearch<User>(
            selectedItem: selectedUser,
            items: User.allUsers,
            hint: 'Felhasználó kiválasztása',
            onChanged: (newUser) {
              setState(() {
                selectedUser = newUser;
              });
            },
            showSearchBox: true,
            filterFn: (user, filter) {
              return user.name.toLowerCase().contains(filter.toLowerCase()) ||
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
                      selectedUser!.balance += balance;
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return FutureSuccessDialog(
                            future: _updateBalance(),
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

  Future<bool> _updateBalance() async {
    try {
      if (!isOnline) {
        //TODO save as purchase
        await selectedUser!.update();
      } else {
        //TODO
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
