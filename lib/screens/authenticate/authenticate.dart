import 'package:dar_es_salaam/screens/authenticate/sign_in.dart';
import 'package:dar_es_salaam/screens/authenticate/sign_up.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  int currentTab = 0;
  bool showSignIn = true;

  List<String> tabs = ['Login', 'Sign Up'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Container(
            height: 60.0,
            margin: EdgeInsets.only(top: 30.0),
            child: Row(
              children: [
                Flexible(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      if (currentTab == index) {
                        return Container(
                          margin: const EdgeInsets.only(left: 30.0, top: 15.0),
                          child: Column(
                            children: [
                              Text(
                                tabs[index],
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                color: Theme.of(context).iconTheme.color,
                                height: 2.0,
                                width: 40.0,
                              )
                            ],
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            showSignIn = !showSignIn;
                            currentTab = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 30.0, top: 15.0),
                          child: Text(
                            tabs[index],
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 30.0),
                  height: 50.0,
                  width: 50.0,
                  child: Material(
                    elevation: 10.0,
                    color: Colors.transparent,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: Image.asset(
                          'assets/images/logo2.jpg',
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
              ],
            ),
          ),
          showSignIn ? SignIn() : SignUp()
        ],
      ),
    );
  }
}
