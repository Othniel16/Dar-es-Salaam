import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String title;
  final List authors;
  final String category;
  final bool isAvailable;
  final String ownerID;
  final String bookID;
  final Map image;
  final Timestamp timeOfUpload;

  Book({
    this.title,
    this.authors,
    this.category,
    this.isAvailable,
    this.ownerID,
    this.bookID,
    this.image,
    this.timeOfUpload,
  });

  static Book fromDocument(DocumentSnapshot documentSnapshot) {
    return Book(
      title: documentSnapshot.data()['title'] ?? 'Null',
      authors: documentSnapshot.data()['authors'] ?? [],
      category: documentSnapshot.data()['category'] ?? 'Null',
      isAvailable: documentSnapshot.data()['isAvailable'] ?? true,
      ownerID: documentSnapshot.data()['ownerID'] ?? 'Null',
      image: documentSnapshot.data()['image'] ?? {},
      timeOfUpload: documentSnapshot.data()['timeOfUpload'],
      bookID: documentSnapshot.data()['bookID'] ?? 'Null',
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'title': title,
      'authors': authors,
      'ownerID': ownerID,
      'image': image,
      'timeOfUpload': Timestamp.now(),
      'isAvailable': isAvailable,
      'category': category,
      'bookID': bookID,
    };
    return map;
  }
}
