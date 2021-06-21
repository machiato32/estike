import 'drink.dart';

class User {
  String name;
  int id;
  Map<Drink, int> drinksBought = {};
  User(this.name, this.id);
  void addBoughtDrink(Drink drink, {int number = 1}) {
    if (drinksBought.containsKey(drink)) {
      drinksBought[drink] = drinksBought[drink]! + number;
    } else {
      drinksBought[drink] = number;
    }
  }
}

List<User> allUsers = [
  User('Hapak Jozsef', 69),
  User('Bondici Laszlo', 1895),
  User('Zsiga Tamás', 3)
]; //TODO from save
addUser(String name, int id) {
  allUsers.add(User(name, id));
}
