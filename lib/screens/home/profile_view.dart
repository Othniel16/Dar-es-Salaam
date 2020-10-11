import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:dar_es_salaam/shared/barrier.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

class ProfileView extends StatefulWidget {
  final String verificationID;
  ProfileView({this.verificationID});
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  //final AuthService _authService = AuthService();

  Color _color = Colors.grey;

  Future getBooksDonated() async {
    var instance = FirebaseFirestore.instance;
    var qs =
        await instance.collection('books').get().then((QuerySnapshot snapshot) {
      return snapshot.docs;
    });

    return qs;
  }

  // this variable is used to check if the currently signed in user is the same
  // as the user who uploaded the book which led the currently signed in user
  // to this page.
  bool verify;

  // method to check if a phone number is valid
  bool isNumeric(String phone) {
    if (phone == null) {
      return false;
    }
    return double.parse(phone, (e) => null) != null;
  }

  // method that launches the user's mail app and prepares it for send-
  // a mail to the book owner
  Future<void> sendMail(AppUser owner) async {
    final Email email = Email(
      body: '',
      subject: '',
      recipients: [owner.email],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      showSnackBar(
          context: context,
          message: 'An error occured. Check your internet connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppUser signedInUser = Provider.of<AppUser>(context);
    BookProvider bookProvider = Provider.of<BookProvider>(context);
    verify = widget.verificationID == signedInUser.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontFamily: fontFamily),
        ),
        leading: backButton(context: context),
        actions: [
          verify
              ? FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => ProfileEdit()));
                  },
                  child: Text(
                    'Edit',
                    style:
                        TextStyle(color: Colors.blue, fontFamily: fontFamily),
                  ))
              : Container()
        ],
      ),
      body: StreamBuilder<AppUser>(
        stream: FirestoreService(uid: widget.verificationID).userData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CupertinoActivityIndicator());
          } else {
            AppUser userData = snapshot.data;

            return Container(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  // profile image
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    alignment: Alignment.topCenter,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      radius: 55.0,
                      child: Icon(
                        Icons.person,
                        size: 40.0,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // username
                  listTileBuilder(userData,
                      leading: Icon(
                        Icons.person_outline,
                        color: _color,
                      ),
                      tag: 'Name',
                      data: userData.username.toString(),
                      showDivider: true),

                  // bio
                  listTileBuilder(userData,
                      leading: Icon(
                        Icons.info_outline,
                        color: _color,
                      ),
                      tag: 'Bio',
                      data: userData.description.toString(),
                      showDivider: true),

                  // phone number
                  // this field will be visible if :
                  // 1. A user is not the signed in user but the profile owner
                  //    has that his phone be visible
                  // 2. A user is actually the profile owner
                  !verify && userData.showPhone || verify
                      ? listTileBuilder(userData,
                          leading: Icon(
                            Icons.phone,
                            color: _color,
                          ),
                          tag: 'Phone',
                          data: userData.phone.toString(),
                          showDivider: true)
                      : Container(),

                  // email
                  listTileBuilder(userData,
                      leading: Icon(
                        Icons.mail_outline,
                        color: _color,
                      ),
                      tag: 'Email',
                      data: userData.email.toString(),
                      showDivider: true),

                  // location
                  listTileBuilder(userData,
                      leading: Icon(
                        CupertinoIcons.location_solid,
                        color: _color,
                      ),
                      tag: 'Location',
                      data: userData.location.toString(),
                      showDivider: false),

                  Divider(),

                  // books donated
                  // this field will be visible if :
                  // 1. A user is not the signed in user but the profile owner has that his phone be visible
                  // 2. A user is actually the profile owner
                  if (!verify && userData.showBookDonatedCount || verify)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 10, 30, 16),
                      child: ExpandablePanel(
                        iconColor: Colors.grey,
                        header:
                            // your books
                            Container(
                          margin: const EdgeInsets.only(bottom: 20.0),
                          child: RichText(
                            text: TextSpan(
                                text: verify ? 'My books' : 'More by',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color:
                                        Theme.of(context).textSelectionColor),
                                children: <TextSpan>[
                                  !verify
                                      ? TextSpan(
                                          text: ' ${userData.username}',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 30),
                                        )
                                      : TextSpan()
                                ]),
                          ),
                        ),
                        expanded:
                            // book snapshots
                            Container(
                                child: FutureBuilder(
                          future: getBooksDonated(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text('');
                            }

                            List<Book> books = [];
                            List<Book> temp = [];

                            for (Book book in bookProvider.getBooks) {
                              temp.add(book);
                              books = temp
                                  .where((book) => userData.booksDonated
                                      .contains(book.bookID))
                                  .toList();
                            }

                            return GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: userData.booksDonated.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 6.0,
                                mainAxisSpacing: 6.0,
                              ),
                              itemBuilder: (context, index) {
                                Book book = books[index];
                                return verify
                                    ? FocusedMenuHolder(
                                        onPressed: () {},
                                        menuWidth:
                                            MediaQuery.of(context).size.width *
                                                0.50,
                                        blurSize: 5.0,
                                        menuItemExtent: 45,
                                        menuBoxDecoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15.0))),
                                        duration: Duration(milliseconds: 100),
                                        animateMenuItems: true,
                                        blurBackgroundColor: Colors.black54,
                                        menuOffset:
                                            10.0, // Offset value to show menuItem from the selected item
                                        bottomOffsetHeight:
                                            80.0, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
                                        menuItems: <FocusedMenuItem>[
                                          // Add Each FocusedMenuItem  for Menu Options

                                          FocusedMenuItem(
                                              title: Text(
                                                book.isAvailable
                                                    ? 'Mark as unavailable'
                                                    : 'Mark as available',
                                              ),
                                              trailingIcon: Icon(
                                                Icons.check,
                                              ),
                                              onPressed: () {
                                                FirestoreService(
                                                        uid: book.bookID)
                                                    .toggleAvailability();
                                                setState(() {});
                                              }),
                                          FocusedMenuItem(
                                              title: Text(
                                                "Delete",
                                                style: TextStyle(
                                                    color: Colors.redAccent),
                                              ),
                                              trailingIcon: Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed: () async {
                                                try {
                                                  await FirestoreService(
                                                          uid: signedInUser.id)
                                                      .deleteFromBooksDonated(
                                                          book.bookID);
                                                  await FirestoreService(
                                                          uid: book.bookID)
                                                      .deleteBookFromCollection();
                                                  await FirestoreService()
                                                      .deleteImage(
                                                          book.image['name'])
                                                      .then((value) =>
                                                          showSnackBar(
                                                              message:
                                                                  'Book deleted',
                                                              context:
                                                                  context));
                                                } catch (error) {
                                                  print('An error occurred');
                                                }
                                              }),
                                        ],
                                        child: CachedNetworkImage(
                                          imageUrl: book.image['url'],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              CupertinoActivityIndicator(),
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: book.image['url'],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            CupertinoActivityIndicator(),
                                      );
                              },
                            );
                          },
                        )),
                      ),
                    )
                  else
                    Container(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget listTileBuilder(AppUser owner,
      {Widget leading, String tag, String data, bool showDivider}) {
    TextStyle dataStyle = TextStyle(fontSize: 16.0, color: Colors.grey);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          ListTile(
              leading: leading,
              title: Text(
                tag,
                style: TextStyle(fontFamily: fontFamily),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(data, style: dataStyle),
              ),

              // we check to see if the signed in user is the same person who uploaded
              // the book that led us into profileView. If that is the case
              // he cannot and must not be able to send himself a mail. That's what
              // verify is
              trailing: verify
                  ? Text('')
                  : (tag == 'Phone'
                      ? copyPhoneButton(owner)
                      : (tag == 'Email' ? sendMailToOwner(owner) : Text('')))),
          showDivider
              ? Padding(
                  padding: const EdgeInsets.only(left: 72.0),
                  child: Divider(),
                )
              : Container()
        ],
      ),
    );
  }

  // copy phone to clipboard button
  Widget copyPhoneButton(AppUser owner) {
    // if the user has set a phone, we show the copy button. We show
    // nothing(empty text widget) otherwise
    return isNumeric(owner.phone)
        ? GestureDetector(
            onTap: () {
              Clipboard.setData(new ClipboardData(text: owner.phone)).then(
                  (value) =>
                      showSnackBar(context: context, message: 'Phone copied'));
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 6,
              height: 40.0,
              child: Center(
                  child: Text(
                'Copy',
                style: TextStyle(color: Colors.purple),
              )),
              decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          )
        : Text('');
  }

  // send owner a mail button
  Widget sendMailToOwner(AppUser owner) {
    return GestureDetector(
      onTap: () => sendMail(owner),
      child: Container(
        height: 40.0,
        width: MediaQuery.of(context).size.width / 6,
        child: Center(
            child: Text(
          'Send',
          style: TextStyle(color: Colors.green),
        )),
        decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(30.0)),
      ),
    );
  }
}
