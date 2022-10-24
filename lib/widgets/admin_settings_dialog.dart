import 'package:estike/config.dart';
import 'package:estike/widgets/future_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSettingsDialog extends StatefulWidget {
  const AdminSettingsDialog({Key? key}) : super(key: key);

  @override
  State<AdminSettingsDialog> createState() => _AdminSettingsDialogState();
}

class _AdminSettingsDialogState extends State<AdminSettingsDialog> {
  TextEditingController adminController = TextEditingController();
  TextEditingController addUserController = TextEditingController();
  TextEditingController appUrlController = TextEditingController(text: APP_URL);
  DateTime newLastUpdatedAt = DateTime.parse(lastUpdatedAt);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Admin beállítások',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: adminController,
                      obscureText: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (text) {
                        if (text == null) {
                          return 'Jajj';
                        }
                        if (text.length < 5) {
                          return 'Legyen azért hosszabb 5 karakternél...';
                        }
                        return null;
                      },
                      onFieldSubmitted: (text) {
                        _updateAdminPassword();
                      },
                      decoration: InputDecoration(
                          labelText: 'Admin jelszó', hintText: 'Új jelszó'),
                    ),
                  ),
                  TextButton(
                    onPressed: _updateAdminPassword,
                    child: Icon(
                      Icons.save,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: addUserController,
                      obscureText: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (text) {
                        if (text == null) {
                          return 'Jajj';
                        }
                        if (text.length < 2) {
                          return 'Legyen azért hosszabb 2 karakternél...';
                        }
                        return null;
                      },
                      onFieldSubmitted: (text) {
                        _updateAddUserPassword();
                      },
                      decoration: InputDecoration(
                          labelText: 'Felhasználó hozzáadása jelszó',
                          hintText: 'Új jelszó'),
                    ),
                  ),
                  TextButton(
                    onPressed: _updateAddUserPassword,
                    child: Icon(
                      Icons.save,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: appUrlController,
                      decoration: InputDecoration(labelText: 'Szerver URL'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (text) {
                        if (text == null) {
                          return 'Jajj';
                        }
                        if (text.length < 1) {
                          return 'Ne legyen azért üres...';
                        }
                        return null;
                      },
                      onFieldSubmitted: (text) {
                        _updateAppUrl();
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: _updateAppUrl,
                    child: Icon(
                      Icons.save,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              TextButton.icon(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.parse(lastUpdatedAt),
                    firstDate: DateTime.parse('2022-09-01'),
                    lastDate: DateTime.now(),
                  ).then((DateTime? value) {
                    if (value != null) {
                      setState(() {
                        lastUpdatedAt = value.toIso8601String();
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setString('last_updated', lastUpdatedAt);
                        });
                      });
                    }
                  });
                },
                icon: Icon(
                  Icons.date_range,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                label: Text(
                  'Utolsó feltöltés/letöltés dátuma: ' +
                      DateFormat('yyyy-MM-dd')
                          .format(DateTime.parse(lastUpdatedAt)),
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.secondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _updateAdminPassword() {
    if (adminController.text.length > 4) {
      showDialog(
        context: context,
        builder: (context) =>
            FutureSuccessDialog(future: _updateAdminPasswordFuture()),
      );
    }
  }

  Future<bool> _updateAdminPasswordFuture() async {
    SharedPreferences.getInstance().then((prefs) {
      adminPassword = adminController.text;
      prefs.setString('admin_password', adminPassword);
    });
    Future.delayed(Duration(milliseconds: 600)).then((value) => _onUpdated());
    return Future.value(true);
  }

  _updateAddUserPassword() {
    if (addUserController.text.length > 1) {
      showDialog(
        context: context,
        builder: (context) =>
            FutureSuccessDialog(future: _updateAddUserPasswordFuture()),
      );
    }
  }

  Future<bool> _updateAddUserPasswordFuture() async {
    SharedPreferences.getInstance().then((prefs) {
      addUserPassword = addUserController.text;
      prefs.setString('add_user_password', addUserPassword);
    });
    Future.delayed(Duration(milliseconds: 600)).then((value) => _onUpdated());
    return Future.value(true);
  }

  _updateAppUrl() {
    if (appUrlController.text != '') {
      showDialog(
        context: context,
        builder: (context) =>
            FutureSuccessDialog(future: _updateAppUrlFuture()),
      );
    }
  }

  Future<bool> _updateAppUrlFuture() async {
    SharedPreferences.getInstance().then((prefs) {
      APP_URL = appUrlController.text;
      prefs.setString('app_url', APP_URL);
    });
    Future.delayed(Duration(milliseconds: 600)).then((value) => _onUpdated());
    return Future.value(true);
  }

  void _onUpdated() {
    Navigator.pop(context);
    setState(() {});
  }
}
