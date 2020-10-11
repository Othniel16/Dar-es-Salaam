import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String username;
  final String email;
  final List booksDonated;
  final List booksReceived;
  final List library;
  final String phone;
  final String description;
  final List followers;
  final List following;
  final Timestamp dateJoined;
  final String location;
  final bool showPhone;
  final bool showBookDonatedCount;

  AppUser({
    this.id,
    this.username,
    this.email,
    this.phone,
    this.description,
    this.booksDonated,
    this.booksReceived,
    this.library,
    this.followers,
    this.following,
    this.location,
    this.dateJoined,
    this.showBookDonatedCount,
    this.showPhone,
  });

  factory AppUser.fromDocument(DocumentSnapshot snapshot) {
    return AppUser(
      username: snapshot.data()['username'],
      email: snapshot.data()['email'],
      phone: snapshot.data()['phone'],
      description: snapshot.data()['description'],
      booksDonated: snapshot.data()['booksDonated'],
      booksReceived: snapshot.data()['booksReceived'],
      library: snapshot.data()['library'],
      location: snapshot.data()['location'],
      dateJoined: snapshot.data()['dateJoined'],
      showBookDonatedCount: snapshot.data()['showBooksDonatedCount'],
      showPhone: snapshot.data()['showPhone'],
    );
  }
}
