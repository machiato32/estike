import 'package:flutter/widgets.dart';

enum DrinkType { beer, long, short, cocktail, other }

class Drink {
  int price;
  String name;
  DrinkType type;
  String? imageURL;
  Drink(this.name, this.price, this.type, {this.imageURL});
}

List<Drink> allDrinks = [
  Drink(
    'Soproni 1895',
    300,
    DrinkType.beer,
    imageURL: 'assets/soproni.png',
  ),
  Drink('Soproni', 280, DrinkType.beer),
  Drink('Heineken', 320, DrinkType.beer),
  Drink('Soproni meggy', 350, DrinkType.beer),
  Drink('Bak', 300, DrinkType.beer),
  Drink('Estike koktel', 800, DrinkType.cocktail)
]; //TODO: from save
void addDrink(String name, int price, DrinkType type, {String? imageURL}) {
  allDrinks.add(Drink(name, price, type, imageURL: imageURL));
  //TODO: save
}
