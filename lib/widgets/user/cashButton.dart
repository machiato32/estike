import 'package:estike/models/user.dart';
import 'package:estike/widgets/product/product_page.dart';
import 'package:flutter/material.dart';

class CashButton extends StatelessWidget {
  final bool smallText;
  final bool isVisible;
  final int columnCount;
  final Function() resetAll;
  CashButton(
      {required this.smallText,
      required this.isVisible,
      required this.columnCount,
      required this.resetAll});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: AspectRatio(
        aspectRatio: columnCount.toDouble() * 2,
        child: Card(
          color: Theme.of(context).colorScheme.primary,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) =>
                          ProductPage(user: User(-1, 'Készpénz', 0))))
                  .then((value) => resetAll());
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
                          "Készpénz",
                          style: smallText
                              ? Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)
                              : Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                          textAlign: TextAlign.center,
                        ),
                        Flexible(
                          child: Icon(
                            Icons.attach_money,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: smallText ? 20 : 30,
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
}
