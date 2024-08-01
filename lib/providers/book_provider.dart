import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import '../services/logging_service.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  String _sortingOrder = 'TitleAsc';
  String _filterCriteria = 'All';
  final String adminEmail = 'umuhirelise22@gmail.com';

  List<Book> get books {
    List<Book> filteredBooks = _filterBooks();
    return _sortBooks(filteredBooks);
  }

  Future<void> loadBooks() async {
    try {
      _books = await DatabaseService().getBooks();
      LoggingService.logInfo('Books loaded: ${_books.toString()}');
      notifyListeners();
    } catch (error, stackTrace) {
      LoggingService.logError('Failed to load books', error, stackTrace);
    }
  }

  Future<void> addBook(Book book) async {
    try {
      await DatabaseService().insertBook(book);
      _books.add(book);
      LoggingService.logInfo('Book added: ${book.toString()}');
      notifyListeners();
    } catch (error, stackTrace) {
      LoggingService.logError('Failed to add book', error, stackTrace);
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      await DatabaseService().updateBook(book);
      final index = _books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        _books[index] = book;
        LoggingService.logInfo('Book updated: ${book.toString()}');
        notifyListeners();
      }
    } catch (error, stackTrace) {
      LoggingService.logError('Failed to update book', error, stackTrace);
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      await DatabaseService().deleteBook(id);
      _books.removeWhere((b) => b.id == id);
      LoggingService.logInfo('Book deleted with id: $id');
      notifyListeners();
    } catch (error, stackTrace) {
      LoggingService.logError('Failed to delete book', error, stackTrace);
    }
  }

  void sortBooks(String criteria) {
    _sortingOrder = criteria;
    notifyListeners();
  }

  void filterBooks(String criteria) {
    _filterCriteria = criteria;
    notifyListeners();
  }

  List<Book> _sortBooks(List<Book> books) {
    switch (_sortingOrder) {
      case 'TitleAsc':
        books.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'TitleDesc':
        books.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'AuthorAsc':
        books.sort((a, b) => a.author.compareTo(b.author));
        break;
      case 'AuthorDesc':
        books.sort((a, b) => b.author.compareTo(a.author));
        break;
      case 'RatingAsc':
        books.sort((a, b) => a.averageRating.compareTo(b.averageRating));
        break;
      case 'RatingDesc':
        books.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
    }
    LoggingService.logInfo('Books sorted by: $_sortingOrder');
    return books;
  }

  List<Book> _filterBooks() {
    if (_filterCriteria == 'All') {
      return _books;
    } else if (_filterCriteria == 'Read') {
      return _books.where((book) => book.userReadStatus.values.any((status) => status)).toList();
    } else if (_filterCriteria == 'Unread') {
      return _books.where((book) => book.userReadStatus.values.any((status) => !status)).toList();
    }
    return _books;
  }

  Future<void> addRating(int bookId, double rating, String userId) async {
    try {
      final book = _books.firstWhere((b) => b.id == bookId);
      book.userRatings[userId] = rating;
      await updateBook(book);
      LoggingService.logInfo('Rating added for book: $bookId by user: $userId');
      notifyListeners();
    } catch (error, stackTrace) {
      LoggingService.logError('Failed to add rating', error, stackTrace);
    }
  }

  Future<void> setUserReadStatus(int bookId, bool isRead, String userId) async {
    try {
      final book = _books.firstWhere((b) => b.id == bookId);
      book.userReadStatus[userId] = isRead;
      await updateBook(book);
      LoggingService.logInfo('Read status set for book: $bookId by user: $userId');
      notifyListeners();
    } catch (error, stackTrace) {
      LoggingService.logError('Failed to set read status', error, stackTrace);
    }
  }

  double getUserRating(int bookId, String userId) {
    final book = _books.firstWhere((b) => b.id == bookId);
    return book.userRatings[userId] ?? 0.0;
  }

  bool getUserReadStatus(int bookId, String userId) {
    final book = _books.firstWhere((b) => b.id == bookId);
    return book.userReadStatus[userId] ?? false;
  }
}
