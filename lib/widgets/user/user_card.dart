import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../product/product_page.dart';

class UserCard extends StatelessWidget {
  final Function resetTextField;
  late Function onTap;
  final User user;
  final bool small;
  UserCard(
      {required this.user,
      Key? key,
      this.small = false,
      required this.resetTextField,
      Function? onTap})
      : super(key: key) {
    if (onTap == null) {
      this.onTap = (context) {
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => ProductPage(user: user)))
            .then((value) => resetTextField());
      };
    } else {
      this.onTap = onTap;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        color: user.balance < 0 ? Colors.red[300] : Colors.grey[800],
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            onTap(context);
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Stack(
              children: [
                Material(
                  color: Colors.transparent,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          Text(
                            user.id.toString(),
                            style: small
                                ? Theme.of(context).textTheme.headline6
                                : Theme.of(context).textTheme.headline5,
                            textAlign: TextAlign.center,
                          ),
                          Flexible(
                            child: Text(
                              user.name,
                              style: small
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.headline4,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        user.balance.toString() + '🐪',
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
