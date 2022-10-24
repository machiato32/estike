import 'package:estike/models/product.dart';
import 'package:estike/models/purchase.dart';
import 'package:estike/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../future_success_dialog.dart';

class ModifyBalanceDialog extends StatefulWidget {
  final User selectedUser;
  const ModifyBalanceDialog({Key? key, required this.selectedUser})
      : super(key: key);

  @override
  _ModifyBalanceDialogState createState() => _ModifyBalanceDialogState();
}

class _ModifyBalanceDialogState extends State<ModifyBalanceDialog> {
  TextEditingController plusController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.selectedUser.name,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              autofocus: true,
              controller: plusController,
              decoration: InputDecoration(
                labelText: 'Plusz',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
              ],
              onFieldSubmitted: (String? text) {
                _submit();
              },
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                await _submit();
              },
              child: Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  Future _submit() async {
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
  }

  Future<bool> _updateBalance(int balance) async {
    try {
      await addPurchase(widget.selectedUser.id, Product.modifiedBalanceId,
          balance.toDouble());
      await widget.selectedUser.modifyBalance(balance);

      Future.delayed(Duration(milliseconds: 600))
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
