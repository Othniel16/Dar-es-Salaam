import 'package:dar_es_salaam/shared/barrier.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:random_color/random_color.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // whether to show title in app bar or not
  bool showTitle = false;

  final String _title = 'Browse';
  final String newArrivals = 'Fresh';

  var _imageHeight;
  var _recentlyAddedImageHeight;

  List<Book> allBooks = [];
  List<Book> fictionBooks = [];
  List<Book> nonfictionBooks = [];
  List<Book> childrenBooks = [];
  List<Book> schoolBooks = [];
  List<Book> recentlyAdded = [];

  Color _color =
      RandomColor().randomColor(colorBrightness: ColorBrightness.dark);

  @override
  void didChangeDependencies() {
    _imageHeight = MediaQuery.of(context).size.width / 1.9;
    _recentlyAddedImageHeight = MediaQuery.of(context).size.width / 3.5;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    getBooks();
  }

  @override
  Widget build(BuildContext context) {
    BookProvider bookProvider = Provider.of<BookProvider>(context);
    bookProvider.setBooks(allBooks);
    bookProvider.setFictionBooks(fictionBooks);
    bookProvider.setNonFictionBooks(nonfictionBooks);
    bookProvider.setChildrenBooks(childrenBooks);
    bookProvider.setSchoolMaterial(schoolBooks);

    return Scaffold(
      appBar: AppBar(
        title: AnimatedOpacity(
          opacity: showTitle ? 1.0 : 0.0,
          duration: Duration(milliseconds: showTitle ? 100 : 00),
          child: Text(
            _title,
            style: TextStyle(
                fontFamily: fontFamily,
                fontWeight: showTitle ? FontWeight.normal : FontWeight.bold),
          ),
        ),
        actions: [
          // search
          IconButton(
            color: Theme.of(context).iconTheme.color,
            icon: Icon(
              Icons.search,
            ),
            tooltip: 'Search',
            onPressed: () => showSearchButton(context),
          ),

          // settings
          IconButton(
              tooltip: 'Settings and more',
              color: Theme.of(context).iconTheme.color,
              icon: Icon(SimpleLineIcons.settings),
              onPressed: () {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => SettingsPage()));
              })
        ],
      ),
      body: allBooks.isNotEmpty
          ? Container(
              child: buildList(),
            )
          : buildEmptyView(context),
      floatingActionButton: Fab(),
    );
  }

  // get books from database
  void getBooks() async {
    List<QueryDocumentSnapshot> querySnapshots = await FirestoreService
        .booksCollection
        .get()
        .then((QuerySnapshot snapshot) {
      return snapshot.docs;
    });
    querySnapshots.shuffle();
    List<Book> books = [];
    for (DocumentSnapshot documentSnapshot in querySnapshots) {
      books.add(Book.fromDocument(documentSnapshot));
    }

    setState(() {
      allBooks = books;
      fictionBooks = books.where((book) => book.category == 'Fiction').toList();
      nonfictionBooks =
          books.where((book) => book.category == 'Non-fiction').toList();
      childrenBooks =
          books.where((book) => book.category == 'Children').toList();
      schoolBooks =
          books.where((book) => book.category == 'School Material').toList();
      recentlyAdded = books
          .where((book) =>
              (DateTime.now()
                  .difference(
                      DateTime.parse(book.timeOfUpload.toDate().toString()))
                  .inDays) ==
              0)
          .toList();
    });
  }

  Future<void> refreshList() async {
    setState(() {
      getBooks();
    });
  }

  Widget buildList() {
    return LiquidPullToRefresh(
      showChildOpacityTransition: false,
      animSpeedFactor: 4.0,
      color: _color,
      backgroundColor: Colors.white,
      height: 70.0,
      onRefresh: refreshList,
      child: NotificationListener(
        // ignore: missing_return
        onNotification: (ScrollNotification notification) {
          setState(() {
            // checking when user scrolls up
            if (notification.metrics.pixels > 40 && !showTitle) {
              showTitle = true;
            }
            // checking when user scrolls down
            else if (notification.metrics.pixels < 20 && showTitle) {
              showTitle = false;
            }
          });
        },
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                child: Text(
                  _title,
                  style: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily),
                ),
              ),
              Divider(),
              fictionBooks.isNotEmpty
                  ? blockBuilder('Fiction', fictionBooks)
                  : SizedBox.shrink(),
              nonfictionBooks.isNotEmpty
                  ? blockBuilder('Non-fiction', nonfictionBooks)
                  : SizedBox.shrink(),
              recentlyAdded.isNotEmpty
                  ? blockBuilder(newArrivals, recentlyAdded)
                  : SizedBox.shrink(),
              childrenBooks.isNotEmpty
                  ? blockBuilder('Children', childrenBooks)
                  : SizedBox.shrink(),
              schoolBooks.isNotEmpty
                  ? blockBuilder('School Material', schoolBooks)
                  : SizedBox.shrink(),
              allCategoriesWidget(allBooks)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyView(BuildContext context) {
    return LiquidPullToRefresh(
      showChildOpacityTransition: false,
      animSpeedFactor: 4.0,
      color: _color,
      backgroundColor: Colors.white,
      height: 70.0,
      onRefresh: refreshList,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 1.2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Have a book to donate?',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: fontFamily,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                        text: 'Tap',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textSelectionColor,
                          fontFamily: fontFamily,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '  +  ',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .floatingActionButtonTheme
                                    .backgroundColor,
                                fontSize: 30),
                          ),
                          TextSpan(
                              text: 'to get started',
                              style: TextStyle(
                                fontFamily: fontFamily,
                              ))
                        ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // new tag
  Widget newTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Text(
        'NEW',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // this widget builds the individual category blocks
  Widget blockBuilder(String category, List<Book> books) {
    return Container(
      margin: books.isNotEmpty
          ? EdgeInsets.symmetric(vertical: 10.0)
          : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // category and see all button. See all button only shows when there are
          // more than 4 items in that category
          Container(
            margin: EdgeInsets.only(left: 15.0, right: 10.0, bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                books.isNotEmpty
                    ? Text(
                        category,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Container(),
                if (books.length > 4)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => SeeAll(
                              title: category,
                              books: books,
                            ),
                          ));
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(fontSize: 15.0, color: Colors.red),
                    ),
                  )
                else
                  SizedBox.shrink()
              ],
            ),
          ),

          // images in the horizontal scroll view is shown only when there is
          // something to show. When there is no book, we show a container that
          // when tapped allows the user to add a new book. It has the same height
          // and width as the book images has
          if (books.length < 1)
            category != 'Fresh'
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) => AddBook()));
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          left: 15.0, right: 10.0, bottom: 15.0),
                      height: MediaQuery.of(context).size.width / 1.9,
                      width: MediaQuery.of(context).size.width / 1.9,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.add,
                              size: 40.0,
                            ),
                            Text('Add')
                          ],
                        ),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  )
                : SizedBox.shrink()
          else
            Container(
              height: category == newArrivals
                  ? MediaQuery.of(context).size.width / 2.2
                  : MediaQuery.of(context).size.width / 1.5,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  Book book = books[index];

                  // get the number of days since book was uploaded
                  // if it is 2 days, we don't show the new tag
                  Duration _dateDifference = DateTime.now().difference(
                      DateTime.parse(book.timeOfUpload.toDate().toString()));
                  int _daysAgo = _dateDifference.inDays;

                  return OpenContainer(
                    closedElevation: 0.0,
                    closedColor: Theme.of(context).scaffoldBackgroundColor,
                    openBuilder: (context, action) => BookDetail(
                      book: book,
                    ),
                    closedBuilder: (context, action) => Padding(
                      padding: index == 0
                          ? EdgeInsets.only(left: 15.0)
                          : EdgeInsets.only(left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Stack(
                              children: [
                                // actual image
                                CachedNetworkImage(
                                  width:
                                      MediaQuery.of(context).size.width / 1.9,
                                  height: category != newArrivals
                                      ? _imageHeight
                                      : _recentlyAddedImageHeight,
                                  fit: BoxFit.cover,
                                  imageUrl: book.image['url'],
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.error,
                                    size: 40.0,
                                  ),
                                ),

                                // new tag
                                category != newArrivals
                                    ? Positioned(
                                        child: _daysAgo < 2
                                            ? newTag()
                                            : SizedBox.shrink(),
                                        right: 10.0,
                                        bottom: 10.0,
                                      )
                                    : Container()
                              ],
                            ),
                          ),

                          // book title and first author
                          Flexible(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.9,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  book.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 17.0),
                                ),
                                subtitle: Text(
                                  book.authors[0],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          books.isNotEmpty ? Divider() : SizedBox.shrink()
        ],
      ),
    );
  }

  // build the last section of the home screen
  Container allCategoriesWidget(List<Book> books) {
    String tag = 'All Categories';
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
                left: 15.0, right: 10.0, bottom: 15.0, top: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tag,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => SeeAll(
                            title: tag,
                            books: books,
                          ),
                        ));
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(fontSize: 15.0, color: Colors.red),
                  ),
                )
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: books.length > 7 ? 7 : books.length,
            padding: const EdgeInsets.only(bottom: 30.0),
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              Book book = books[index];
              return OpenContainer(
                closedElevation: 0.0,
                closedColor: Theme.of(context).scaffoldBackgroundColor,
                openBuilder: (context, action) => BookDetail(
                  book: book,
                ),
                closedBuilder: (context, action) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: CachedNetworkImage(
                      imageUrl: book.image['url'],
                      fit: BoxFit.fitWidth,
                      width: MediaQuery.of(context).size.width / 5.5,
                      placeholder: (context, value) =>
                          CupertinoActivityIndicator(),
                    ),
                  ),
                  title: Text(
                    book.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    book.authors[0],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  // show the search screen
  Future<Book> showSearchButton(BuildContext context) {
    return showSearch(
      context: context,
      delegate: SearchPage<Book>(
        barTheme: Theme.of(context).copyWith(
          primaryColor: Colors.white,
          primaryIconTheme: IconThemeData(color: Colors.black),
          cursorColor: Colors.black,
          textTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
          ),
          appBarTheme: Theme.of(context).appBarTheme,
        ),
        items: allBooks,
        searchLabel: 'Search',
        suggestion: Center(
          child: Text(
            'Suggestions appear here :)',
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: fontFamily,
            ),
          ),
        ),
        failure: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No matching books :(',
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: fontFamily,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              'Check your spelling or try another word',
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: fontFamily,
              ),
            ),
          ],
        )),
        filter: (book) => [book.title, book.category],
        builder: (book) => GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => BookDetail(
                          book: book,
                        )));
          },
          child: ListTile(
            leading: Icon(CupertinoIcons.book),
            title: Text(
              book.title,
            ),
            subtitle: Text(
              book.category,
            ),
          ),
        ),
      ),
    );
  }
}
