import 'package:dar_es_salaam/models/user.dart';
import 'package:dar_es_salaam/screens/authenticate/authenticate.dart';
import 'package:dar_es_salaam/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);

    // return either Home or Authenticate screen if user is signed in or out
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
