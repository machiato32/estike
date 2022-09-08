import 'package:estike/models/product.dart';
import 'package:estike/models/purchase.dart';
import 'package:estike/models/user.dart';
import 'package:estike/widgets/future_success_dialog.dart';
import 'package:estike/widgets/product/not_enough_money_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtherButton extends StatelessWidget {
  final User user;
  final int productColumnCount;
  final bool smallScreen;
  final TextEditingController otherTextController = TextEditingController();
  OtherButton(
      {required this.user,
      required this.productColumnCount,
      required this.smallScreen});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: user.id != User.cashUserId,
      child: AspectRatio(
        aspectRatio: productColumnCount.toDouble() * 2,
        child: Card(
          color: Theme.of(context).colorScheme.primary,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return _otherButtonDialog(context);
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Stack(
                children: [
                  Material(
                    color: Colors.transparent,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Egyéni",
                          style: (smallScreen
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.headline4)!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                          textAlign: TextAlign.center,
                        ),
                        Flexible(
                          child: Icon(
                            Icons.construction,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: smallScreen ? 20 : 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _otherButtonDialog(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vonj le valamennyit!',
              style: Theme.of(context).textTheme.headline5,
            ),
            TextFormField(
              controller: otherTextController,
              decoration: InputDecoration(
                labelText: 'Összeg',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              validator: (String? text) {
                if (text == null || text.isEmpty) {
                  return 'Kérlek írd be az összeget!';
                }
                if (double.tryParse(text) == null) {
                  return 'Kérlek írj számot!';
                }
                return null;
              },
              autofocus: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onFieldSubmitted: (text) {
                otherButtonSubmit(context);
              },
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              child: Icon(Icons.send),
              onPressed: () => otherButtonSubmit(context),
            )
          ],
        ),
      ),
    );
  }

  void otherButtonSubmit(BuildContext context) {
    if (otherTextController.text != '' &&
        int.tryParse(otherTextController.text) != null) {
      double amount = double.parse(otherTextController.text);
      if (user.balance >= amount) {
        showDialog(
            context: context,
            builder: (context) =>
                FutureSuccessDialog(future: _postPurchase(amount, context)));
      } else {
        showDialog(
          context: context,
          builder: (context) => NotEnoughMoneyDialog(
            user: user,
            amount: amount,
          ),
        );
      }
    }
  }

  Future<bool> _postPurchase(double amount, BuildContext context) async {
    await user.modifyBalance(-amount.ceil());
    addPurchase(user.id, Product.modifiedBalanceId, -amount);
    Future.delayed(Duration(milliseconds: 300))
        .then((value) => _onPostPurchases(context));
    return true;
  }

  void _onPostPurchases(BuildContext context) {
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
