import 'package:flutter/material.dart';

import 'add_user_page.dart';
import 'models/user.dart';
import 'user_card.dart';

class SearchPersonPage extends StatefulWidget {
  SearchPersonPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _SearchPersonPageState createState() => _SearchPersonPageState();
}

class _SearchPersonPageState extends State<SearchPersonPage> {
  String searchWord = '';
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Center(
                child: Text(
                  'Estike',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.attach_money,
              ),
              title: Text(
                "Egyenleg szerkesztése",
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.person_add,
              ),
              title: Text(
                "Felhasználó hozzáadása",
              ),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddUserPage()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.edit,
              ),
              title: Text(
                "Italok szerkesztése",
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.history,
              ),
              title: Text(
                "Előzmények",
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
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
    List<User> users = User.allUsers;
    if (searchWord != "") {
      users = User.allUsers
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
