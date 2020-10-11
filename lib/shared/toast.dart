import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

showSnackBar({@required String message, @required BuildContext context}) {
  showToast(
    message,
    context: context,
    animation: StyledToastAnimation.slideFromBottom,
    reverseAnimation: StyledToastAnimation.slideToBottom,
    fullWidth: true,
    startOffset: Offset(0.0, 3.0),
    reverseEndOffset: Offset(0.0, 3.0),
    position: StyledToastPosition.bottom,
    duration: Duration(seconds: 4),
    animDuration: Duration(seconds: 1),
    curve: Curves.elasticOut,
    reverseCurve: Curves.fastOutSlowIn,
  );
}
