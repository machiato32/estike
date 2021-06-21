import 'package:estike/user.dart';
import 'package:estike/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'drink_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        // textTheme: TextTheme(
        //   headline6:
        // ),
        cardTheme: CardTheme(
          margin: EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: 'Estike számla'),
        // '/drink_page': (context) => DrinkPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String searchWord = '';
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _generateBody(),
    );
  }

  void resetTextFiled() {
    setState(() {
      controller.clear();
      searchWord = '';
    });
  }

  Widget _generateBody() {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(10),
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              searchWord = value;
            });
          },
          autofocus: true,
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Keresés',
          ),
        ),
        _generateGrid(),
      ],
    );
  }

  Widget _generateGrid() {
    List<User> users = allUsers;
    if (searchWord != "") {
      users = allUsers
          .where((element) =>
              element.id.toString().contains(searchWord) ||
              element.name.toLowerCase().contains(searchWord.toLowerCase()))
          .toList();
    }
    if (users.length == 0) return Container();
    double width = MediaQuery.of(context).size.width;
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
      children: users.map<Widget>(
        (e) {
          FocusNode node = FocusNode();
          // nodes.add(node);
          return UserCard(
            resetTextField: resetTextFiled,
            // node: node,
            user: e,
            small: small,
          );
        },
      ).toList(),
    );
  }
}
