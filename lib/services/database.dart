import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dar_es_salaam/models/book.dart';
import 'package:dar_es_salaam/models/user.dart';
import 'package:dar_es_salaam/shared/barrier.dart';

class FirestoreService {
  // user uid
  final String uid;
  FirestoreService({this.uid});
  // collection references
  static final CollectionReference booksCollection =
      FirebaseFirestore.instance.collection('books');
  static final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

// -------------------- Setting stuff -------------------------

// method to update user data. It is also used to set initial
// data for a new user
  Future setInitialUserData({
    String username,
    description,
    phone,
    email,
    location,
    Timestamp dateJoined,
    List booksDonated,
    booksReceived,
    library,
    bool showBooksDonatedCount,
    showPhone,
  }) async {
    return await usersCollection.doc(uid).set({
      'username': username,
      'description': description,
      'phone': phone,
      'email': email,
      'booksDonated': booksDonated,
      'booksReceived': booksReceived,
      'library': library,
      'dateJoined': dateJoined,
      'location': location,
      'showBooksDonatedCount': showBooksDonatedCount,
      'showPhone': showPhone,
    });
  }

// set the bookID of a book
  Future setBookId(String id) async {
    return await booksCollection.doc(uid).update({
      'bookID': id,
    });
  }

// -------------------- Update methods -------------------------
  Future updateUserData({String username, description, phone, location}) async {
    return await usersCollection.doc(uid).update({
      'username': username,
      'description': description,
      'phone': phone,
      'location': location,
    });
  }

  // update the books a user has donated
  Future updateUserBooksDonated({Book book}) async {
    return await usersCollection.doc(uid).update({
      'booksDonated': FieldValue.arrayUnion([book.bookID]),
    });
  }

// -------------------- Delete methods -------------------------

// delete a book from the books collection
  Future deleteBookFromCollection() async {
    return await booksCollection.doc(uid).delete();
  }

  // delete a book from a user's books donated
  Future deleteFromBooksDonated(String bookID) async {
    DocumentSnapshot doc = await usersCollection.doc(uid).get();
    List booksDonated = doc.data()['booksDonated'];
    if (booksDonated.contains(bookID)) {
      print('Book is available');
      List val = [];
      val.add(bookID);
      return await usersCollection
          .doc(uid)
          .update({'booksDonated': FieldValue.arrayRemove(val)});
    } else {
      print('Book cannot be found');
    }
  }

  // delete a book from a user's library
  Future deleteFromLibrary(String bookID) async {
    DocumentSnapshot doc = await usersCollection.doc(uid).get();
    List library = doc.data()['library'];
    if (library.contains(bookID)) {
      print('Book is available');
      List val = [];
      val.add(bookID);
      return await usersCollection
          .doc(uid)
          .update({'library': FieldValue.arrayRemove(val)});
    } else {
      print('Book cannot be found');
    }
  }

// delete a book from firestore and cloud storage
  Future deleteImage(String imageFileName) async {
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(imageFileName);

    try {
      await firebaseStorageRef.delete();
      return true;
    } catch (e) {
      return e.toString();
    }
  }

// -------------------- Fetch methods -------------------------

// get the owner of a book by uid
  static Future<AppUser> getOwnerOfBookWithID(String id) async {
    Future<DocumentSnapshot> document = usersCollection.doc(id).get();
    return await document.then((doc) {
      return AppUser.fromDocument(doc);
    });
  }

  // get user doc stream
  Stream<AppUser> get userData {
    return usersCollection.doc(uid).snapshots().map((snapshot) {
      return AppUser.fromDocument(snapshot);
    });
  }

  // get books from database
  static Future getBooks() async {
    var qs = await booksCollection.get().then((QuerySnapshot snapshot) {
      return snapshot.docs;
    });
    qs.shuffle();
    return qs;
  }

// -------------------- Add methods -------------------------

  // add a book to the database. A uid will be generated automatically for every
  // new book added
  Future addBook({Book book}) async {
    return booksCollection.add(book.toMap());
  }

  // add a book to user library
  Future<String> addToLibrary({Book book}) async {
    DocumentSnapshot doc = await usersCollection.doc(uid).get();
    List library = doc.data()['library'];
    if (library.contains(book.bookID)) {
      return 'Entry already exists';
    } else {
      await usersCollection.doc(uid).update({
        'library': FieldValue.arrayUnion([book.bookID]),
      });
      return 'Saved to library';
    }
  }
}
