import 'package:dar_es_salaam/shared/back_button.dart';
import 'package:dar_es_salaam/shared/barrier.dart';
import 'package:flutter/material.dart';

class Library extends StatelessWidget {
  final ScrollController controller;

  const Library({Key key, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    BookProvider bookProvider = Provider.of<BookProvider>(context);
    final AppUser signedInUser = Provider.of<AppUser>(context);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Library',
            style: TextStyle(fontFamily: fontFamily),
          ),
          leading: backButton(context: context),
        ),
        backgroundColor: Colors.transparent,
        body: StreamBuilder<AppUser>(
          stream: FirestoreService(uid: signedInUser.id).userData,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CupertinoActivityIndicator());
            } else {
              AppUser userData = snapshot.data;
              List<Book> libraryItems = [];
              List<Book> temp = [];

              for (Book book in bookProvider.getBooks) {
                temp.add(book);
                libraryItems = temp
                    .where((book) => userData.library.contains(book.bookID))
                    .toList();
              }
              return ListView.separated(
                padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
                physics: BouncingScrollPhysics(),
                controller: controller,
                itemCount: libraryItems.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  Book book = libraryItems[index];
                  return ListTile(
                    title: Text(book.title),
                    leading: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 8),
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.20))
                      ]),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: CachedNetworkImage(
                            imageUrl: book.image['url'],
                            fit: BoxFit.fitWidth,
                            width: MediaQuery.of(context).size.width / 6.5,
                            placeholder: (context, value) => Container(
                              color: Colors.grey[300],
                            ),
                          )),
                    ),
                    onLongPress: () {
                      showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  child: Row(
                                    children: [
                                      // book image
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                6.5,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                6.5,
                                            imageUrl: book.image['url']),
                                      ),
                                      // book title
                                      Expanded(
                                        child: ListTile(
                                            title: Text(
                                              book.title,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                //fontSize: 24.0,
                                                fontFamily: fontFamily,
                                              ),
                                            ),
                                            subtitle: book.authors.isNotEmpty
                                                ? Text(book.authors[0])
                                                : Container()),
                                      ),
                                    ],
                                  ),
                                ),

                                Divider(),

                                // visit owner profile
                                ListTile(
                                  title: Text('See owner'),
                                  leading: Icon(Icons.person_outline,
                                      color: Colors.red),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => ProfileView(
                                                  verificationID: book.ownerID,
                                                )));
                                  },
                                ),

                                Divider(),

                                // remove from library
                                ListTile(
                                  title: Text('Remove'),
                                  leading: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onTap: () async {
                                    // try to remove book from user library
                                    try {
                                      await FirestoreService(
                                              uid: signedInUser.id)
                                          .deleteFromLibrary(book.bookID)
                                          .then((value) {
                                        Navigator.pop(context);
                                        showSnackBar(
                                            message: 'Book removed',
                                            context: context);
                                      });
                                    } catch (error) {
                                      print('An error occurred');
                                    }
                                  },
                                ),
                              ],
                            );
                          });
                    },
                  );
                },
              );
            }
          },
        ));
  }
}
