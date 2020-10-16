import 'package:dar_es_salaam/shared/barrier.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

showSnackBar({@required String message, @required BuildContext context}) {
  return Flushbar(
    flushbarStyle: FlushbarStyle.FLOATING,
    margin: EdgeInsets.all(8.0),
    duration: Duration(seconds: 5),
    borderRadius: 5.0,
    reverseAnimationCurve: Curves.linear,
    forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    mainButton: FlatButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        'OK',
        style: TextStyle(color: Colors.amber, fontFamily: fontFamily),
      ),
    ),
    messageText: Text(
      message,
      style: TextStyle(
        fontSize: 17.0,
        color: Colors.white,
      ),
    ),
  )..show(context);
}
