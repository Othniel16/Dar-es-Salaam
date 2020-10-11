import 'package:dar_es_salaam/models/book.dart';
import 'package:dar_es_salaam/shared/shared_preferences_helper.dart';
import 'package:flutter/material.dart';

class BookProvider extends ChangeNotifier {
  BookProvider(this._lastAppTheme, this._savedTheme);
  List<Book> _books = [];
  List<Book> _fiction = [];
  List<Book> _nonFiction = [];
  List<Book> _children = [];
  List<Book> _schoolMaterial = [];
  int _lastAppTheme;
  var _savedTheme;

  List<Book> get getBooks => _books;
  List<Book> get setfictionBooks => _fiction;
  List<Book> get nonFictionBooks => _nonFiction;
  List<Book> get childrenBooks => _children;
  List<Book> get schoolMaterialBooks => _schoolMaterial;
  int get lastAppTheme => _lastAppTheme;
  get savedTheme => _savedTheme;

  setBooks(List<Book> books) {
    _books = books;
  }

  setFictionBooks(List<Book> books) {
    _fiction = books;
  }

  setNonFictionBooks(List<Book> books) {
    _nonFiction = books;
  }

  setChildrenBooks(List<Book> books) {
    _children = books;
  }

  setSchoolMaterial(List<Book> books) {
    _schoolMaterial = books;
  }

  setLastAppTheme(int value) async {
    _lastAppTheme = value;
    notifyListeners();
    await SharedPreferencesHelper.setLastAppTheme(value);
  }
}
