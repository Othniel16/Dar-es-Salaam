import 'package:flutter/material.dart';
import 'package:dar_es_salaam/shared/barrier.dart';

class PrivacySettings extends StatefulWidget {
  @override
  _PrivacySettingsState createState() => _PrivacySettingsState();
}

class _PrivacySettingsState extends State<PrivacySettings> {
  bool showPhone;
  bool showBookCount;
  @override
  Widget build(BuildContext context) {
    final AppUser user = Provider.of<AppUser>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy settings',
          style: TextStyle(fontFamily: fontFamily),
        ),
        leading: backButton(context: context),
      ),
      body: StreamBuilder(
          stream: FirestoreService(uid: user.id).userData,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CupertinoActivityIndicator());
            } else {
              AppUser userData = snapshot.data;
              return ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  SizedBox(height: 10.0),
                  // vector illustration
                  Container(
                    child: Image.asset(
                      'assets/images/privacy.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  SizedBox(height: 10.0),

                  //showPhone
                  SwitchListTile(
                    value: userData.showPhone,
                    onChanged: (value) async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.id)
                          .update({
                        'showPhone': value,
                      });
                    },
                    title: Text('Phone'),
                    subtitle: Text(userData.showPhone ? 'Everyone' : 'Only me'),
                  ),

                  // show Books Donated
                  SwitchListTile(
                    value: userData.showBookDonatedCount,
                    onChanged: (value) async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.id)
                          .update({
                        'showBooksDonatedCount': value,
                      });
                    },
                    title: Text('My books'),
                    subtitle: Text(
                        userData.showBookDonatedCount ? 'Everyone' : 'Only me'),
                  )
                ],
              );
            }
          }),
    );
  }
}
