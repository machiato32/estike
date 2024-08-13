import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/user.dart';

class HistoryFilterDialog extends StatefulWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? userId;
  final bool showBalanceModifications;
  final ValueChanged<DateTime?> onFromDateChanged;
  final ValueChanged<DateTime?> onToDateChanged;
  final ValueChanged<int?> onUserIdChanged;
  final ValueChanged<bool> onBalanceModificationsChanged;

  HistoryFilterDialog(
      {required this.fromDate,
      required this.toDate,
      required this.userId,
      required this.showBalanceModifications,
      required this.onFromDateChanged,
      required this.onToDateChanged,
      required this.onUserIdChanged,
      required this.onBalanceModificationsChanged});

  @override
  State<HistoryFilterDialog> createState() => _HistoryFilterDialogState();
}

class _HistoryFilterDialogState extends State<HistoryFilterDialog> {
  DateTime? _fromDate;
  DateTime? _toDate;
  User? _user;
  late bool _showBalanceModifications;
  @override
  void initState() {
    super.initState();
    _fromDate = widget.fromDate;
    _toDate = widget.toDate;
    if (widget.userId != null) {
      _user =
          User.allUsers.firstWhere((element) => element.id == widget.userId);
    }
    _showBalanceModifications = widget.showBalanceModifications;
  }

  @override
  Widget build(BuildContext context) {
    DateTime minDate = DateTime.parse('2020-01-01');
    DateTime maxDate = DateTime.now();
    return Dialog(
      child: ListView(
        padding: EdgeInsets.all(20),
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Kezdődátum: ' +
                      (_fromDate != null
                          ? DateFormat('yyyy-MM-dd').format(_fromDate!)
                          : '2020-01-01'),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
              TextButton(
                  onPressed: () {
                    showDatePicker(
                            context: context,
                            initialDate: _fromDate ??
                                DateTime.now().subtract(Duration(days: 8)),
                            firstDate: minDate,
                            lastDate: maxDate)
                        .then((selectedDate) {
                      setState(() {
                        _fromDate = selectedDate;
                        widget.onFromDateChanged(selectedDate);
                      });
                    });
                  },
                  child: Icon(Icons.date_range))
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                    'Végdátum: ' +
                        DateFormat('yyyy-MM-dd').format(
                            _toDate != null ? _toDate! : DateTime.now()),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
              TextButton(
                  onPressed: () {
                    showDatePicker(
                            context: context,
                            initialDate: _toDate ?? DateTime.now(),
                            firstDate: minDate,
                            lastDate: maxDate)
                        .then((selectedDate) {
                      setState(() {
                        _toDate = selectedDate;
                        widget.onToDateChanged(selectedDate);
                      });
                    });
                  },
                  child: Icon(Icons.date_range))
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('Felhasználó',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
              Expanded(
                child: DropdownSearch<User>(
                  itemAsString: (User user) =>
                      user.name + ' (' + user.id.toString() + ')',
                  items: User.allUsers,
                  filterFn: (User user, search) =>
                      user.id.toString().contains(search) ||
                      user.name.contains(search),
                  popupProps: PopupProps.dialog(
                      /*
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      */
                      showSearchBox: true,
                      searchDelay: Duration(milliseconds: 0)),
                  clearButtonProps: ClearButtonProps(isVisible: true),
                  enabled: true,
                  selectedItem: _user,
                  compareFn: (User user1, User user2) => user1.id == user2.id,
                  onChanged: (User? user) {
                    _user = user;
                    widget.onUserIdChanged(user != null ? user.id : null);
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('Feltöltések mutatása',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
              Checkbox(
                  value: _showBalanceModifications,
                  activeColor: Theme.of(context).colorScheme.primary,
                  checkColor: Theme.of(context).colorScheme.onPrimary,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _showBalanceModifications = value;
                        widget.onBalanceModificationsChanged(value);
                      });
                    }
                  }),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.send)),
          )
        ],
      ),
    );
  }
}
