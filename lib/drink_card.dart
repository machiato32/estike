import 'package:flutter/material.dart';
import 'models/drink.dart';

class DrinkCard extends StatelessWidget {
  final Function(Drink drink) addDrinkToList;
  final Drink drink;
  final bool small;
  final FocusNode node;
  const DrinkCard(
      {required this.drink,
      required this.node,
      this.small = false,
      required this.addDrinkToList});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        child: InkWell(
          focusNode: node,
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            addDrinkToList(drink);
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Stack(
              children: [
                drink.imageURL != null //TODO
                    ? Container()
                    : Container(),
                Material(
                  color: Colors.transparent,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        drink.name,
                        style: small
                            ? Theme.of(context).textTheme.headline5
                            : Theme.of(context).textTheme.headline4,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        drink.price.toString() + '🐪',
                        style: small
                            ? Theme.of(context).textTheme.headline6
                            : Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
