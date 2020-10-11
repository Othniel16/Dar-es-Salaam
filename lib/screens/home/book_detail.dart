import 'package:dar_es_salaam/shared/progressDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:dar_es_salaam/shared/barrier.dart';

class BookDetail extends StatefulWidget {
  final Book book;
  BookDetail({@required this.book});

  @override
  _BookDetailState createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  final TextStyle _textStyle = TextStyle(fontSize: 16.5, letterSpacing: 0.5);

  @override
  Widget build(BuildContext context) {
    Duration _dateDifference = DateTime.now().difference(
        DateTime.parse(widget.book.timeOfUpload.toDate().toString()));

    int _daysAgo = _dateDifference.inDays;

    final AppUser signedInUser = Provider.of<AppUser>(context);
    FirestoreService firestoreService = FirestoreService(uid: signedInUser.id);

    return Scaffold(
      appBar: AppBar(
        leading: backButton(context: context),
      ),
      body: FutureBuilder(
        future: FirestoreService.getOwnerOfBookWithID(widget.book.ownerID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CupertinoActivityIndicator());
          }

          return ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Row(
                children: [
                  // book image
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: GestureDetector(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.width / 2.2,
                            width: MediaQuery.of(context).size.width / 2.2,
                            imageUrl: widget.book.image['url']),
                      ),
                      onTap: () => Navigator.push(
                          context,
                          TransparentCupertinoPageRoute(
                              builder: (context) => ImageView(
                                    imageUrl: widget.book.image['url'],
                                  ))),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        height: MediaQuery.of(context).size.width / 2.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24.0,
                                fontFamily: fontFamily,
                              ),
                            ),

                            Spacer(),

                            // owner
                            Align(
                              alignment: Alignment.center,
                              child: Bounce(
                                duration: Duration(milliseconds: 80),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: Center(
                                      child: Text('Owner',
                                          style: TextStyle(
                                            fontFamily: fontFamily,
                                            color: Theme.of(context)
                                                .textSelectionColor,
                                          ))),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .textSelectionColor),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => ProfileView(
                                                verificationID:
                                                    widget.book.ownerID,
                                              )));
                                },
                              ),
                            ),

                            SizedBox(
                              height: 10.0,
                            ),

                            // add to library
                            Align(
                              alignment: Alignment.center,
                              child: Bounce(
                                duration: Duration(milliseconds: 100),
                                onPressed: () {
                                  // show a loading widget to let the user know what is happening
                                  showProgress(context);
                                  firestoreService
                                      .addToLibrary(
                                    book: widget.book,
                                  )
                                      .then((String message) {
                                    // dismiss the loading dialog when book has been added to db
                                    dismissProgressDialog();
                                    showSnackBar(
                                        context: context, message: message);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: Center(
                                      child: Text('Add to library',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: fontFamily,
                                          ))),
                                  decoration: BoxDecoration(
                                      color: Colors.red[500],
                                      borderRadius: BorderRadius.circular(5.0),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0, 10),
                                          blurRadius: 20,
                                          color: Colors.red.withOpacity(0.23),
                                        )
                                      ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(),
              ),

              // book category
              detailTileBuilder(
                tag: 'Category',
                child: ListTile(
                  title: Text(
                    widget.book.category,
                    style: _textStyle,
                  ),
                ),
              ),

              // authors
              detailTileBuilder(
                tag: 'Authors',
                child: widget.book.authors.length == 1
                    ? ListTile(
                        title: widget.book.authors[0] == ''
                            ? Text(
                                'No authors were provided',
                                style: _textStyle.copyWith(color: Colors.grey),
                              )
                            : Text(
                                widget.book.authors[0].toString(),
                                style: _textStyle,
                              ),
                      )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.book.authors.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Row(
                              children: [
                                Text((index + 1).toString()),
                                SizedBox(
                                  width: 13.0,
                                ),
                                Text(
                                  widget.book.authors[index],
                                  style: _textStyle,
                                ),
                              ],
                            ),
                          );
                        }),
              ),

              // book availability
              detailTileBuilder(
                tag: 'Status',
                child: ListTile(
                  title: widget.book.isAvailable
                      ? Text(
                          'Available',
                          style: _textStyle,
                        )
                      : Text(
                          'Not available',
                          style: _textStyle,
                        ),
                ),
              ),

              // days since upload
              detailTileBuilder(
                  tag: 'Uploaded',
                  child: ListTile(
                    title: Text(
                      _daysAgo == 1
                          ? _daysAgo.toString() + ' day ago'
                          : _daysAgo.toString() + ' days ago',
                      style: _textStyle,
                    ),
                  )),

              // book title
              detailTileBuilder(
                tag: 'Book Title',
                child: ListTile(
                  title: Text(
                    widget.book.title,
                    style: _textStyle,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // method to build each detail section of a book. Like category, authors, etc
  Widget detailTileBuilder({String tag, Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 10.0),
            child: Text(
              tag,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          child,
          Divider()
        ],
      ),
    );
  }
}

class ImageView extends StatelessWidget {
  final String imageUrl;
  ImageView({@required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExtendedImageSlidePage(
        slideAxis: SlideAxis.vertical,
        slideType: SlideType.wholePage,
        child: ExtendedImage(
          //disable to stop image sliding off page && entering dead end without back button.
          //setting to false means it won't slide at all.
          enableSlideOutPage: true,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (state) => GestureConfig(
            maxScale: 3.0,
          ),
          fit: BoxFit.scaleDown,
          image: CachedNetworkImageProvider(
            imageUrl,
          ),
        ),
      ),
    );
  }
}
