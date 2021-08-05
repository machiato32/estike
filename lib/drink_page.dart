import 'package:estike/drink_ledger_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/drink.dart';
import 'drink_card.dart';
import 'models/user.dart';

class DrinkPage extends StatefulWidget {
  final User user;
  const DrinkPage({required this.user});

  @override
  _DrinkPageState createState() => _DrinkPageState();
}

class _DrinkPageState extends State<DrinkPage> {
  ScrollController controller = ScrollController();
  List<FocusNode> nodes = [];
  int nodeNum = 0;
  Map<Drink, int> drinksToBuy = {};
  @override
  Widget build(BuildContext context) {
    bool small = MediaQuery.of(context).size.width <= 1200;
    nodes = [];
    return FocusableActionDetector(
      autofocus: true,
      actions: _initActions(),
      shortcuts: _initShortcuts(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ital kiválasztása'),
        ),
        body: small
            ? Column(
                children: [
                  Expanded(
                    child: _generateLeftUpperPart(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[300]!,
                        ),
                      ),
                    ),
                    height: MediaQuery.of(context).size.height / 3.3,
                    child: _generateRightLower(),
                  ),
                ],
              )
            : Table(
                columnWidths: {
                  0: FractionColumnWidth(0.7),
                  1: FractionColumnWidth(0.3),
                },
                children: [
                  TableRow(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        child: _generateLeftUpperPart(),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Colors.grey[300]!,
                              // width: 5,
                            ),
                          ),
                        ),
                        child: _generateRightLower(),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  void addDrinkToList(Drink drink) {
    setState(() {
      if (drinksToBuy.containsKey(drink)) {
        drinksToBuy[drink] = drinksToBuy[drink]! + 1;
      } else {
        drinksToBuy[drink] = 1;
      }
    });
  }

  void removeDrinkFromList(Drink drink) {
    setState(() {
      drinksToBuy[drink] = drinksToBuy[drink]! - 1;
      if (drinksToBuy[drink] == 0) {
        drinksToBuy.remove(drink);
      }
    });
  }

  int sum(Map<Drink, int> drinks) {
    int sum = 0;
    for (Drink drink in drinks.keys) {
      sum += drink.price * drinks[drink]!;
    }
    return sum;
  }

  Widget _generateRightLower() {
    return ListView(
      padding: EdgeInsets.all(10),
      shrinkWrap: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_circle_sharp,
                    color: Theme.of(context).primaryColor,
                    size: 45,
                  ),
                  Flexible(
                    child: Text(
                      widget.user.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.user.id.toString(),
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
      ]
        ..addAll(drinksToBuy.keys.map(
          (drink) => DrinkLedgerItem(
            addDrinkToList: addDrinkToList,
            removeDrinkFromList: removeDrinkFromList,
            drink: drink,
            itemNum: drinksToBuy[drink]!,
          ),
        ))
        ..add(Visibility(
          visible: drinksToBuy.keys.length > 0,
          child: Column(
            children: [
              Divider(),
              Text(
                'Összesen: ' + sum(drinksToBuy).toString() + '🐪',
                style: Theme.of(context).textTheme.headline4,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (drinksToBuy.keys.length != 0) {
                      for (Drink drink in drinksToBuy.keys) {
                        widget.user
                            .addBoughtDrink(drink, number: drinksToBuy[drink]!);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ))
            ],
          ),
        )),
    );
  }

  Widget _generateLeftUpperPart() {
    return ListView(
      controller: controller,
      padding: EdgeInsets.all(10),
      shrinkWrap: true,
      children: [
        Visibility(
          visible: widget.user.drinksBought.keys.length != 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajánlott',
                style: Theme.of(context).textTheme.headline3,
              ),
              _generateGrid(null),
            ],
          ),
        ),
        Text(
          'Sörök',
          style: Theme.of(context).textTheme.headline3,
        ),
        _generateGrid(DrinkType.beer),
        Text(
          'Koktélok',
          style: Theme.of(context).textTheme.headline3,
        ),
        _generateGrid(DrinkType.cocktail),
      ],
    );
  }

  Widget _generateGrid(DrinkType? type) {
    List<Drink> drinks = [];
    if (type == null) {
      var mapEntries = widget.user.drinksBought.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      Map<Drink, int> sortedDrinks = {};
      sortedDrinks.addEntries(mapEntries);
      drinks = sortedDrinks.keys.take(5).toList();
    } else {
      drinks =
          Drink.allDrinks.where((element) => element.type == type).toList();
    }

    if (drinks.length == 0) return Container();
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      width = 7 * width / 10;
    }
    bool small = false;
    int count = (width / 200).floor();
    if (width < 400) {
      small = true;
      count = (width / 150).floor();
    }
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: count,
      children: drinks.map<Widget>(
        (e) {
          FocusNode node = FocusNode();
          nodes.add(node);
          return DrinkCard(
            addDrinkToList: addDrinkToList,
            node: node,
            drink: e,
            small: small,
          );
        },
      ).toList(),
    );
  }

  _initShortcuts() {
    return <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowLeft): _XIntent.arrowLeft(),
      LogicalKeySet(LogicalKeyboardKey.arrowRight): _XIntent.arrowRight(),
      LogicalKeySet(LogicalKeyboardKey.arrowUp): _XIntent.arrowUp(),
      LogicalKeySet(LogicalKeyboardKey.arrowDown): _XIntent.arrowDown(),
    };
  }

  void _actionHandler(_XIntent intent) {
    switch (intent.type) {
      case _XIntentType.ArrowLeft:
        onArrowLeftCallback();
        break;
      case _XIntentType.ArrowRight:
        onArrowRightCallback();
        break;
      case _XIntentType.ArrowUp:
        onArrowUpCallback();
        break;
      case _XIntentType.ArrowDown:
        onArrowDownCallback();
        break;
    }
  }

  _initActions() {
    return <Type, Action<Intent>>{
      _XIntent: CallbackAction<_XIntent>(
        onInvoke: _actionHandler,
      ),
    };
  }

  void onArrowDownCallback() {
    controller.animateTo(controller.offset + 20,
        duration: Duration(milliseconds: 10), curve: Curves.ease);
  }

  void onArrowUpCallback() {
    controller.animateTo(controller.offset - 20,
        duration: Duration(milliseconds: 10), curve: Curves.ease);
  }

  void onArrowLeftCallback() {
    if (nodeNum > 0) {
      nodeNum--;
    } else {
      nodeNum = nodes.length - 1;
    }
    FocusScope.of(context).requestFocus(nodes[nodeNum]);
  }

  void onArrowRightCallback() {
    if (nodeNum < nodes.length - 1) {
      nodeNum++;
    } else {
      nodeNum = 0;
    }
    FocusScope.of(context).requestFocus(nodes[nodeNum]);
  }
}

class _XIntent extends Intent {
  final _XIntentType type;
  const _XIntent({required this.type});

  const _XIntent.arrowRight() : type = _XIntentType.ArrowRight;
  const _XIntent.arrowLeft() : type = _XIntentType.ArrowLeft;
  const _XIntent.arrowUp() : type = _XIntentType.ArrowUp;
  const _XIntent.arrowDown() : type = _XIntentType.ArrowDown;
}

enum _XIntentType { ArrowRight, ArrowLeft, ArrowUp, ArrowDown }
