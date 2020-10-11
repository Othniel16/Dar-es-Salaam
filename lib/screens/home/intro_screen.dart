import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:dar_es_salaam/screens/authenticate/authenticate.dart';
import 'package:dar_es_salaam/shared/barrier.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with AfterLayoutMixin<Splash> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => Wrapper()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => IntroScreen(
                userID: null,
              )));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return new Scaffold();
  }
}

class IntroScreen extends StatefulWidget {
  final String userID;

  const IntroScreen({Key key, @required this.userID}) : super(key: key);
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int page = 0;
  LiquidController liquidController;
  SharedPreferences prefs;
  UpdateType updateType;
  final pages = [
    Container(
      color: Colors.red,
    ),
    Container(
      color: Colors.yellow,
    ),
    Container(
      color: Colors.green,
    ),
    Container(
      color: Colors.blue,
    ),
    Container(
      color: Colors.amberAccent,
    ),
  ];

  @override
  void initState() {
    liquidController = LiquidController();
    _initPreferences();
    super.initState();
  }

  _initPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  pageChangeCallback(int lpage) {
    setState(() {
      page = lpage;
    });
  }

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((page ?? 0) - index).abs(),
      ),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return new Container(
      width: 25.0,
      child: new Center(
        child: new Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: new Container(
            width: 5.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        LiquidSwipe(
          pages: pages,
          onPageChangeCallback: pageChangeCallback,
          liquidController: liquidController,
          ignoreUserGestureWhileAnimating: true,
          enableLoop: false,
        ),

        // dot indicator
        Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Column(
            children: <Widget>[
              Expanded(child: SizedBox()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(pages.length, _buildDot),
              ),
            ],
          ),
        ),

        // next button
        Align(
          alignment: Alignment.bottomCenter,
          // show start button if user reaches end of slide. Else show next button
          child: !(page == pages.length - 1)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: CupertinoButton(
                    onPressed: () {
                      liquidController.animateToPage(
                          duration: 400,
                          page: liquidController.currentPage + 1);
                    },
                    child: Text(
                      "Next",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: Colors.white,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: CupertinoButton(
                    onPressed: () async {
                      // go back to previous screen if uid is not null
                      // meaning the user deliberately opened the tutorial
                      if (widget.userID != null) {
                        Navigator.pop(context);
                      } else {
                        // change seen to true so that user doesn't see tutorial
                        // screen again and navigate user to sign up screen
                        await prefs.setBool('seen', true).then((value) {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => Authenticate(),
                              ));
                        });
                      }
                    },
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }
}
