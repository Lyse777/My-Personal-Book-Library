import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/book.dart';
import 'logging_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'book_library.db');
    LoggingService.logInfo('Database path: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY,
        title TEXT,
        author TEXT,
        description TEXT, 
        userRatings TEXT,
        userReadStatus TEXT,
        imageUrl TEXT,
        webImage BLOB
      )
      ''',
    );
    LoggingService.logInfo('Database created and books table initialized.');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  
    LoggingService.logInfo('Database upgraded from version $oldVersion to $newVersion.');
  }

  Future<void> insertBook(Book book) async {
    try {
      final db = await database;
      await db.insert(
        'books',
        book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      LoggingService.logInfo('Book inserted: ${book.toString()}');
    } catch (error, stackTrace) {
      LoggingService.logError('Failed to insert book', error, stackTrace);
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      final db = await database;
      await db.update(
        'books',
        book.toMap(),
        where: 'id = ?',
        whereArgs: [book.id],
      );
      LoggingService.logInfo('Book updated: ${book.toString()}');
    } catch (error, stackTrace) {
      LoggingService.logError('Failed to update book', error, stackTrace);
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      final db = await database;
      await db.delete(
        'books',
        where: 'id = ?',
        whereArgs: [id],
      );
      LoggingService.logInfo('Book deleted with id: $id');
    } catch (error, stackTrace) {
      LoggingService.logError('Failed to delete book', error, stackTrace);
    }
  }

  Future<List<Book>> getBooks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('books');
      LoggingService.logInfo('Books loaded: $maps');
      return List.generate(maps.length, (i) {
        return Book.fromMap(maps[i]);
      });
    } catch (error, stackTrace) {
      LoggingService.logError('Failed to load books', error, stackTrace);
      return [];
    }
  }

  Future<List<Book>> getBooksForUser(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('books');
      LoggingService.logInfo('Books loaded for user: $maps');
      return maps.map((map) {
        final book = Book.fromMap(map);
       
        return book;
      }).toList();
    } catch (error, stackTrace) {
      LoggingService.logError('Failed to load books for user', error, stackTrace);
      return [];
    }
  }
}
