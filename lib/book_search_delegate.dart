// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import 'book_detail_screen.dart';
import 'dart:convert';
import 'dart:io';

class BookSearchDelegate extends SearchDelegate<Book?> {
  @override
  String get searchFieldLabel => 'Search by Title or Author';

  @override
  TextStyle? get searchFieldStyle => TextStyle(color: Color.fromARGB(255, 195, 191, 191));

  @override
  InputDecorationTheme? get searchFieldDecorationTheme {
    final isDarkMode = Theme.of(context as BuildContext).brightness == Brightness.dark;
    return InputDecorationTheme(
      hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
      filled: true,
      fillColor: isDarkMode ? Colors.black : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return [
      IconButton(
        icon: Icon(Icons.clear, color: isDarkMode ? Colors.grey : Colors.black),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.grey : Colors.black),
      onPressed: () {
        close(context, null); // Use close(context, null) to indicate no selection
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isAdmin = userProvider.isAdmin;

    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        final results = bookProvider.books.where((book) {
          return book.title.toLowerCase().contains(query.toLowerCase()) ||
              book.author.toLowerCase().contains(query.toLowerCase());
        }).toList();

        if (results.isEmpty) {
          return Center(
            child: Text(
              'No results found.',
              style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.white : Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final book = results[index];
            final bool isBase64 = _isBase64(book.imageUrl ?? '');
            final bool isLocalFilePath = _isLocalFilePath(book.imageUrl ?? '');

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading: book.imageUrl != null
                    ? (isBase64
                        ? Image.memory(base64Decode(book.imageUrl!), height: 50, width: 50, fit: BoxFit.cover)
                        : isLocalFilePath
                            ? Image.file(File(book.imageUrl!), height: 50, width: 50, fit: BoxFit.cover)
                            : Image.network(book.imageUrl!, height: 50, width: 50, fit: BoxFit.cover))
                    : null,
                title: RichText(
                  text: TextSpan(
                    style: TextStyle(fontFamily: 'Raleway', color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(text: 'Title: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: book.title),
                    ],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontFamily: 'Raleway', color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
                        children: <TextSpan>[
                          TextSpan(text: 'Author: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: book.author),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontFamily: 'Raleway', color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
                        children: <TextSpan>[
                          TextSpan(text: 'Description: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: book.description),
                        ],
                      ),
                    ),
                    if (!isAdmin)
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final currentUser = userProvider.user;
                          final userRating = book.userRatings[currentUser?.uid] ?? 0.0;
                          final userReadStatus = book.userReadStatus[currentUser?.uid] ?? false;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Your Rating: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Raleway',
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Icon(Icons.star, color: Colors.yellow[600], size: 20),
                                  SizedBox(width: 4),
                                  Text(
                                    userRating.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Status: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Raleway',
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    userReadStatus ? 'Read' : 'Unread',
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 14,
                                      color: userReadStatus ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailScreen(book: book),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ThemeData(
      primaryColor: isDarkMode ? Colors.black : Colors.purple,
      scaffoldBackgroundColor: isDarkMode ? Colors.black : Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
        filled: true,
        fillColor: isDarkMode ? Colors.black : Colors.white,
        border: InputBorder.none,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      iconTheme: IconThemeData(
        color: isDarkMode ? Colors.grey : Colors.black,
      ),
    );
  }

  bool _isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool _isLocalFilePath(String path) {
    return !path.startsWith('http') && !path.startsWith('data:image/');
  }
}
