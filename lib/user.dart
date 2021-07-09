import 'drink.dart';

class User {
  String name;
  int id;
  int balance;
  Map<Drink, int> drinksBought = {};
  User(this.name, this.id, this.balance);
  void addBoughtDrink(Drink drink, {int number = 1}) {
    if (drinksBought.containsKey(drink)) {
      drinksBought[drink] = drinksBought[drink]! + number;
    } else {
      drinksBought[drink] = number;
    }
  }
}

List<User> allUsers = [
  User('Hapak Jozsef', 69, 0),
  User('Bondici Laszlo', 1895, 1500),
  User('Zsiga Tamás', 3, -3000)
]; //TODO from save
addUser(String name, int id, {int balance = 0}) {
  allUsers.add(User(name, id, balance));
}
