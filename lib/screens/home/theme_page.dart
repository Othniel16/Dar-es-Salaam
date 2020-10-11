import 'package:flutter/material.dart';
import 'package:dar_es_salaam/shared/barrier.dart';

class ThemePage extends StatefulWidget {
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: backButton(context: context),
          title: Text('Choose theme', style: TextStyle(fontFamily: fontFamily)),
        ),
        body: Consumer<BookProvider>(
          builder: (context, value, child) {
            int groupValue = value.lastAppTheme;
            return Column(mainAxisSize: MainAxisSize.min, children: [
              RadioListTile(
                value: 0,
                title: Text('Light'),
                groupValue: groupValue,
                onChanged: (index) async {
                  value.setLastAppTheme(index);
                  AdaptiveTheme.of(context).setLight();
                },
                activeColor: Colors.blue,
              ),
              RadioListTile(
                value: 1,
                title: Text('Dark'),
                groupValue: groupValue,
                onChanged: (index) async {
                  value.setLastAppTheme(index);
                  AdaptiveTheme.of(context).setDark();
                },
                activeColor: Colors.blue,
              ),
              RadioListTile(
                value: 2,
                title: Text('System default'),
                groupValue: groupValue,
                onChanged: (index) async {
                  value.setLastAppTheme(index);
                  AdaptiveTheme.of(context).setSystem();
                },
                activeColor: Colors.blue,
              ),
            ]);
          },
        ));
  }
}
