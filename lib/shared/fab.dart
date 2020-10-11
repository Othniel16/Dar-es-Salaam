import 'package:animations/animations.dart';
import 'package:dar_es_salaam/screens/home/add_book.dart';
import 'package:flutter/material.dart';

class Fab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedBuilder: (context, action) => SizedBox(
        height: 56.0,
        width: 56.0,
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.black,
            semanticLabel: 'Add book',
          ),
        ),
      ),
      openBuilder: (context, action) {
        return AddBook();
      },
      closedElevation: 6,
      closedColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
      closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(56 / 2))),
    );
  }
}
