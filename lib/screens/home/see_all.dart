import 'package:dar_es_salaam/shared/barrier.dart';
import 'package:flutter/material.dart';

class SeeAll extends StatelessWidget {
  final String title;
  final List<Book> books;
  SeeAll({@required this.title, @required this.books});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(context: context),
        title: Text(
          title,
          style: TextStyle(fontFamily: fontFamily),
        ),
      ),
      body: StaggeredGridView.countBuilder(
        physics: BouncingScrollPhysics(),
        crossAxisCount: 4,
        itemCount: books.length,
        itemBuilder: (context, index) => Showcase(
          book: books[index],
        ),
        staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
        mainAxisSpacing: 24.0,
        crossAxisSpacing: 12.0,
        padding: EdgeInsets.all(12.0),
      ),
    );
  }
}

class Showcase extends StatelessWidget {
  final Book book;
  Showcase({@required this.book});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OpenContainer(
          closedElevation: 0.0,
          closedColor: Theme.of(context).scaffoldBackgroundColor,
          openBuilder: (context, action) => BookDetail(
            book: book,
          ),
          closedBuilder: (context, action) => ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: CachedNetworkImage(
              imageUrl: book.image['url'],
            ),
          ),
        ),
        buildInfo(context),
      ],
    );
  }

  Widget buildInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 7.0,
          ),
          Text(
            book.title,
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 4.0,
          ),
          Text(
            book.authors[0],
            style: Theme.of(context).textTheme.caption,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
