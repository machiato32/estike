import 'package:flutter/material.dart';

class SplitView extends StatefulWidget {
  final Widget drawer;
  final Widget rightWidget;
  SplitView({required this.drawer, required this.rightWidget});
  @override
  _SplitViewState createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return Table(
        columnWidths: {
          0: FractionColumnWidth(0.2),
          1: FractionColumnWidth(0.8),
        },
        children: [
          TableRow(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: widget.drawer,
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                  ),
                ),
                child: widget.rightWidget,
              ),
            ],
          ),
        ],
      );
    }
    return widget.rightWidget;
  }
}
