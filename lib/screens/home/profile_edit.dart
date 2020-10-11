import 'package:flutter/material.dart';
import 'package:dar_es_salaam/shared/barrier.dart';

class ProfileEdit extends StatefulWidget {
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final _formKey = GlobalKey<FormState>();

  String username, description, phone, location;

  TextStyle textFieldStyle =
      TextStyle(fontFamily: fontFamily, color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    final AppUser user = Provider.of<AppUser>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit',
          style: TextStyle(fontFamily: fontFamily),
        ),
        leading: backButton(context: context),
      ),
      body: StreamBuilder<AppUser>(
        stream: FirestoreService(uid: user.id).userData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CupertinoActivityIndicator());
          } else {
            AppUser userData = snapshot.data;
            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                // profile image
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  alignment: Alignment.topCenter,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 60.0,
                        child: Icon(
                          Icons.person,
                          size: 40.0,
                          color: Colors.black,
                        ),
                      ),
                      Positioned(
                        bottom: -3.0,
                        right: -3.0,
                        child: CircleAvatar(
                          radius: 23.0,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          child: CircleAvatar(
                            radius: 20.0,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.add_a_photo_rounded,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // textfields showing name, phone, description, and others
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 30.0),

                      // username field
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Name',
                                style: textFieldStyle,
                              ),
                            ),
                            TextFormField(
                              initialValue: userData.username,
                              decoration: textInputDecoration.copyWith(
                                  prefixIcon: Icon(Icons.person_outline)),
                              validator: (value) => value.isEmpty
                                  ? 'Username cannot be empty'
                                  : null,
                              onChanged: (value) {
                                setState(() => username = value);
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.0),

                      // description or bio field
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Bio',
                                style: textFieldStyle,
                              ),
                            ),
                            TextFormField(
                              maxLines: null,
                              initialValue: userData.description,
                              decoration: textInputDecoration.copyWith(
                                  prefixIcon: Icon(Icons.info_outline)),
                              validator: (value) => value.isEmpty
                                  ? 'Description cannot be empty'
                                  : null,
                              onChanged: (value) {
                                setState(() => description = value);
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.0),

                      // phone field
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Phone',
                                style: textFieldStyle,
                              ),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              initialValue: userData.phone,
                              decoration: textInputDecoration.copyWith(
                                  prefixIcon: Icon(Icons.phone)),
                              validator: (value) => value.isEmpty
                                  ? 'Phone cannot be empty'
                                  : null,
                              onChanged: (value) {
                                setState(() => phone = value);
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.0),

                      // location field
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Location',
                                style: textFieldStyle,
                              ),
                            ),
                            TextFormField(
                              initialValue: userData.location,
                              decoration: textInputDecoration.copyWith(
                                  prefixIcon:
                                      Icon(CupertinoIcons.location_solid)),
                              validator: (value) => value.isEmpty
                                  ? 'Location cannot be empty'
                                  : null,
                              onChanged: (value) {
                                setState(() => location = value);
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.0),

                      // save changes button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: CupertinoButton.filled(
                          child: Text(
                            'Save changes',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.id)
                                  .update({
                                'username': username ?? userData.username,
                                'description':
                                    description ?? userData.description,
                                'phone': phone ?? userData.phone,
                                'location': location ?? userData.location,
                              });
                              Navigator.pop(context);
                              showSnackBar(
                                  context: context, message: 'Profile updated');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
