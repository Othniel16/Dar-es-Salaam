import 'package:flutter/material.dart';

Widget backButton({@required BuildContext context}) {
  return IconButton(
    icon: Icon(
      Icons.close,
      color: Theme.of(context).iconTheme.color,
    ),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
}
