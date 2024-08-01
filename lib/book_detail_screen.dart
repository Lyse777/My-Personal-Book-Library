// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, use_key_in_widget_constructors, unused_import, use_build_context_synchronously

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_book_library/edit_book_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  BookDetailScreen({required this.book});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book book;

  @override
  void initState() {
    super.initState();
    book = widget.book;
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Book'),
        content: Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<BookProvider>(context, listen: false).deleteBook(book.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  bool _isBase64(String value) {
    try {
      final decodedBytes = base64Decode(value);
      return decodedBytes.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  bool _isLocalFilePath(String path) {
    return !path.startsWith('http') && !path.startsWith('data:image/');
  }

  Widget _buildImage(String imageUrl) {
    if (_isBase64(imageUrl)) {
      return Image.memory(
        base64Decode(imageUrl),
        height: 200,
        width: 150,
        fit: BoxFit.cover,
      );
    } else if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        height: 200,
        width: 150,
        fit: BoxFit.cover,
      );
    } else if (_isLocalFilePath(imageUrl)) {
      if (kIsWeb) {
        return Text('Local file paths are not supported on web.');
      } else {
        return Image.file(
          File(imageUrl),
          height: 200,
          width: 150,
          fit: BoxFit.cover,
        );
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    final isAdmin = userProvider.isAdmin;
    final currentUser = userProvider.user;

    double userRating = 0;
    bool userReadStatus = false;

    if (currentUser != null) {
      userRating = book.userRatings[currentUser.uid] ?? 0.0;
      userReadStatus = book.userReadStatus[currentUser.uid] ?? false;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black54 : Colors.purple,
        title: Text(
          book.title,
          style: TextStyle(fontFamily: 'Raleway'),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                final updatedBook = await Navigator.push<Book>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditBookScreen(book: book),
                  ),
                );
                if (updatedBook != null) {
                  setState(() {
                    book = updatedBook;
                  });
                  Provider.of<BookProvider>(context, listen: false).updateBook(updatedBook);
                }
              },
            ),
          if (isAdmin)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () => _showDeleteConfirmationDialog(context),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Color(0xFF3E3E3E), Colors.black]
                : [Color(0xFFE6E6FA), Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Book Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (book.imageUrl != null)
                      Center(
                        child: _buildImage(book.imageUrl!),
                      ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.title, color: isDarkMode ? Colors.white : Colors.black),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Title: ${book.title}',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Raleway',
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.black),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Author: ${book.author}',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Raleway',
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.description, color: isDarkMode ? Colors.white : Colors.black),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Description: ${book.description}',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Raleway',
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow[600]),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Average Rating: ${book.averageRating.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isAdmin) ...[
                      SizedBox(height: 20),
                      Text(
                        'User Ratings and Read Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      for (var entry in book.userRatings.entries)
                        Row(
                          children: [
                            Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.black),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'User: ${entry.key}, Rating: ${entry.value}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Raleway',
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 10),
                      for (var entry in book.userReadStatus.entries)
                        Row(
                          children: [
                            Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.black),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'User: ${entry.key}, Status: ${entry.value ? 'Read' : 'Unread'}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Raleway',
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                    if (!isAdmin && currentUser != null) ...[
                      SizedBox(height: 20),
                      Text(
                        'Your Rating',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      RatingBar.builder(
                        initialRating: userRating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) async {
                          await bookProvider.addRating(book.id, rating, currentUser.uid);
                          setState(() {
                            book.userRatings[currentUser.uid] = rating;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      SwitchListTile(
                        title: Text(
                          'Mark as Read',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        value: userReadStatus,
                        onChanged: (bool value) async {
                          await bookProvider.setUserReadStatus(book.id, value, currentUser.uid);
                          setState(() {
                            book.userReadStatus[currentUser.uid] = value;
                          });
                        },
                        activeColor: Colors.purple,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
