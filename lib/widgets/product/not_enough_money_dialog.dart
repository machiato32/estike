import 'package:estike/config.dart';
import 'package:estike/models/product.dart';
import 'package:estike/models/purchase.dart';
import 'package:estike/models/user.dart';
import 'package:flutter/material.dart';

import '../future_success_dialog.dart';

class NotEnoughMoneyDialog extends StatefulWidget {
  final User user;
  final Map<Product, double>? productsToBuy;
  final double? amount;
  const NotEnoughMoneyDialog(
      {required this.user, this.productsToBuy, this.amount});

  @override
  State<NotEnoughMoneyDialog> createState() => _NotEnoughMoneyDialogState();
}

class _NotEnoughMoneyDialogState extends State<NotEnoughMoneyDialog> {
  bool showPasswordField = false;
  TextEditingController controller = TextEditingController();
  void onPasswordCorrect() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return FutureSuccessDialog(
          future: widget.amount != null
              ? _postAmount()
              : _postPurchases(usesCash: widget.user.id == User.cashUserId),
        );
      },
    );
  }

  Future<bool> _postAmount() async {
    await widget.user.modifyBalance(-widget.amount!.ceil());
    addPurchase(widget.user.id, Product.modifiedBalanceId, -widget.amount!);
    Future.delayed(Duration(milliseconds: 600))
        .then((value) => _onPostPurchases());
    return true;
  }

  Future<bool> _postPurchases({bool usesCash = false}) async {
    try {
      if (widget.productsToBuy != null) {
        if (usesCash) {
          for (Product product in widget.productsToBuy!.keys) {
            await addPurchase(
                widget.user.id, product.id, widget.productsToBuy![product]!);
          }
        } else {
          for (Product product in widget.productsToBuy!.keys) {
            widget.user.addBoughProduct(product,
                number: widget.productsToBuy![product]!.ceil());
            product.addPersonBuying(
                widget.user, widget.productsToBuy![product]!.ceil());
            await addPurchase(
                widget.user.id, product.id, widget.productsToBuy![product]!);
          }
          await widget.user.modifyBalance(-sum(widget.productsToBuy!).ceil());
        }

        Future.delayed(Duration(milliseconds: 600))
            .then((value) => _onPostPurchases());

        return true;
      }
      return false;
    } catch (_) {
      throw _;
    }
  }

  void _onPostPurchases() {
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    if (widget.amount != null) {
      Navigator.pop(context);
    }
  }

  double sum(Map<Product, double> products) {
    double sum = 0;
    for (Product product in products.keys) {
      sum += product.price * products[product]!;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nincs elég pénz a számlán!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
            Visibility(
              visible: showPasswordField,
              child: TextFormField(
                decoration: InputDecoration(label: Text('Jelszó')),
                controller: controller,
                autofocus: true,
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value != null && value != adminPassword) {
                    return 'Nem jó';
                  }
                  return null;
                },
                onFieldSubmitted: (String value) {
                  if (value == adminPassword) {
                    onPasswordCorrect();
                  }
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                if (!showPasswordField) {
                  setState(() {
                    showPasswordField = true;
                  });
                } else {
                  if (controller.text == adminPassword) {
                    onPasswordCorrect();
                  }
                }
              },
              child: Text('De!'),
            ),
          ],
        ),
      ),
    );
  }
}
