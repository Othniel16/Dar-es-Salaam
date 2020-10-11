import 'package:flutter/material.dart';

class GmailStyleFAB extends StatelessWidget {
  const GmailStyleFAB({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Donate',
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark ? null : Colors.white,
      child: CustomPaint(
        child: Container(),
        foregroundPainter: FloatingPainter(),
      ),
      onPressed: () {
        // showCupertinoModalBottomSheet(
        //     duration: const Duration(milliseconds: 400),
        //     animationCurve: Curves.fastLinearToSlowEaseIn,
        //     context: context,
        //     builder: (context, scrollController) {
        //       return AddBook();
        //     });
      },
    );
  }
}

class FloatingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint amberPaint = Paint()
      ..color = Colors.amber[900]
      ..strokeWidth = 5;

    Paint greenPaint = Paint()
      ..color = Colors.greenAccent[400]
      ..strokeWidth = 5;

    Paint bluePaint = Paint()
      ..color = Colors.blue[900]
      ..strokeWidth = 5;

    Paint redPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5;

    canvas.drawLine(Offset(size.width * 0.27, size.height * 0.5),
        Offset(size.width * 0.5, size.height * 0.5), amberPaint);
    canvas.drawLine(
        Offset(size.width * 0.5, size.height * 0.5),
        Offset(size.width * 0.5, size.height - (size.height * 0.27)),
        greenPaint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.5),
        Offset(size.width - (size.width * 0.27), size.height * 0.5), bluePaint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.5),
        Offset(size.width * 0.5, size.height * 0.27), redPaint);
  }

  @override
  bool shouldRepaint(FloatingPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(FloatingPainter oldDelegate) => false;
}
