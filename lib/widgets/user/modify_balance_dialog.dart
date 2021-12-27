import 'package:estike/models/purchase.dart';
import 'package:estike/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../future_success_dialog.dart';

class ModifyBalanceDialog extends StatefulWidget {
  final User selectedUser;
  const ModifyBalanceDialog({ Key? key , required this.selectedUser}) : super(key: key);

  @override
  _ModifyBalanceDialogState createState() => _ModifyBalanceDialogState();
}

class _ModifyBalanceDialogState extends State<ModifyBalanceDialog> {
  TextEditingController plusController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.selectedUser.name, style: Theme.of(context).textTheme.headline6),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: plusController,
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
                int? balance = int.tryParse(plusController.text);
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
    );
  }

  Future<bool> _updateBalance(int balance) async {
    try {
      widget.selectedUser.balance += balance;
      await addPurchase(widget.selectedUser.id, -1,
          balance.toDouble()); // productId -1 means, that this was a balance modification
      await widget.selectedUser.update();
      
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
    Navigator.pop(context);
  }
}