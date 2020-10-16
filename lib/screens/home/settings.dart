import 'package:dar_es_salaam/screens/home/library.dart';
import 'package:flutter/material.dart';
import 'package:dar_es_salaam/shared/barrier.dart';
import 'package:dar_es_salaam/screens/home/intro_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SettingsPage extends StatefulWidget {
  static final AuthService _authService = AuthService();
  static String userID = _authService.getCurrentUserID;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Widget divider = Padding(
    padding: const EdgeInsets.only(left: 72.0),
    child: Divider(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
        ),
        leading: backButton(context: context),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          // profile
          ListTile(
            title: Text('Profile'),
            leading: CircleAvatar(
              backgroundColor: Colors.redAccent[400],
              child: const Icon(FontAwesome.user, color: Colors.white),
            ),
            onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ProfileView(
                          verificationID: SettingsPage.userID,
                        ))),
          ),
          divider,

          // edit profile
          ListTile(
            title: Text('Edit profile'),
            leading: CircleAvatar(
                backgroundColor: Colors.deepPurpleAccent,
                child: const Icon(
                  FontAwesome.edit,
                  color: Colors.white,
                )),
            onTap: () => Navigator.of(context)
                .push(CupertinoPageRoute(builder: (context) => ProfileEdit())),
          ),
          divider,

          // theme changer
          ListTile(
              title: Text('Choose theme'),
              leading: CircleAvatar(
                backgroundColor: Colors.black54,
                child: const Icon(FontAwesome5Solid.moon, color: Colors.white),
              ),
              onTap: () {
                //_displayDialog(context);
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => ThemePage()));
              }),
          divider,

          // privacy settings
          ListTile(
            title: Text('Privacy settings'),
            leading: CircleAvatar(
              backgroundColor: Colors.greenAccent[400],
              child: const Icon(FontAwesome.lock, color: Colors.white),
            ),
            onTap: () => Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => PrivacySettings())),
          ),
          divider,

          // library
          ListTile(
            title: Text('Library'),
            leading: CircleAvatar(
              backgroundColor: Colors.lightBlue,
              child: const Icon(Icons.my_library_books_outlined,
                  color: Colors.white),
            ),
            onTap: () {
              showCupertinoModalBottomSheet(
                context: context,
                builder: (context, scrollController) {
                  return Library();
                },
              );
            },
          ),
          divider,

          // quick tutorial
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.play_arrow_outlined, color: Colors.white),
            ),
            title: Text('Quick tutorial'),
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => IntroScreen(
                      userID: SettingsPage.userID,
                    ),
                  ));
            },
          ),
          divider,

          // sign out
          ListTile(
              title: Text('Sign out'),
              leading: CircleAvatar(
                backgroundColor: Colors.orange[400],
                child: const Icon(FontAwesome.sign_out, color: Colors.white),
              ),
              onTap: () {
                showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: Text('Confirm sign out'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('Confirm'),
                            isDestructiveAction: true,
                            onPressed: () async {
                              await SettingsPage._authService
                                  .signOut()
                                  .then((value) => Navigator.pop(context));
                            },
                          ),
                          CupertinoDialogAction(
                            child: Text('Cancel'),
                            isDefaultAction: true,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      );
                    });
              }),
          divider,

//           // use this button if ever you have to perform some changes for all users. Like
// //adding a new field to their documents
          // FlatButton(
          //     onPressed: () async {
          //       final QuerySnapshot result =
          //           await FirebaseFirestore.instance.collection('users').get();

          //       final List<DocumentSnapshot> documents = result.docs;

          //       documents.forEach((document) async {
          //         await FirebaseFirestore.instance
          //             .collection('users')
          //             .doc(document.id)
          //             .update({
          //           'library': [],
          //         });
          //       });
          //     },
          //     child: Text('Start'))
        ],
      ),
    );
  }
}
