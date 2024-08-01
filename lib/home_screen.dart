// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, sort_child_properties_last, no_leading_underscores_for_local_identifiers, unused_import, use_build_context_synchronously, unnecessary_import, prefer_const_constructors_in_immutables

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';
import 'book_search_delegate.dart';
import 'settings_screen.dart';
import 'sign_in_page.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.isAdmin;

    final List<Widget> _screens = [
      Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.books.isEmpty) {
            return Center(
              child: Text(
                'No books Available.',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 18, fontFamily: 'Raleway'),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: bookProvider.books.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (context, index) {
                final book = bookProvider.books[index];
                final currentUser = userProvider.user;
                final userRating = book.userRatings[currentUser?.uid] ?? 0.0;
                final userReadStatus = book.userReadStatus[currentUser?.uid];
                final bookStatus = (userReadStatus == null)
                    ? 'Read/Unread'
                    : (userReadStatus ? 'Read' : 'Unread');

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
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
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailScreen(book: book),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (book.imageUrl != null)
                          Center(
                            child: _isBase64(book.imageUrl!)
                                ? Image.memory(
                                    base64Decode(book.imageUrl!),
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : _isLocalFilePath(book.imageUrl!)
                                    ? Image.file(
                                        File(book.imageUrl!),
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        book.imageUrl!,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontFamily: 'Raleway', color: Colors.black, fontSize: 16),
                                  children: <TextSpan>[
                                    TextSpan(text: 'Title: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: book.title),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontFamily: 'Raleway', color: Colors.black, fontSize: 14),
                                  children: <TextSpan>[
                                    TextSpan(text: 'Author: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: book.author),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontFamily: 'Raleway', color: Colors.black, fontSize: 14),
                                  children: <TextSpan>[
                                    TextSpan(text: 'Description: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: book.description),
                                  ],
                                ),
                              ),
                              if (!isAdmin) ...[
                                SizedBox(height: 8),
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
                                      bookStatus,
                                      style: TextStyle(
                                        fontFamily: 'Raleway',
                                        fontSize: 14,
                                        color: bookStatus == 'Read' ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Rating: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Raleway',
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Icon(Icons.star, color: Colors.yellow[600], size: 20),
                                    SizedBox(width: 4),
                                    Text(
                                      userRating.toString(),
                                      style: TextStyle(
                                        fontFamily: 'Raleway',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Book Library', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontFamily: 'Raleway')),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: BookSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.book, color: _selectedIndex == 0 ? Colors.purple : Colors.grey),
              title: Text('Books', style: TextStyle(color: _selectedIndex == 0 ? Colors.purple : Colors.grey)),
              tileColor: _selectedIndex == 0 ? Colors.purple[50] : null,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: _selectedIndex == 1 ? Colors.purple : Colors.grey),
              title: Text('Settings', style: TextStyle(color: _selectedIndex == 1 ? Colors.purple : Colors.grey)),
              tileColor: _selectedIndex == 1 ? Colors.purple[50] : null,
              onTap: () => _onItemTapped(1),
            ),
          ],
        ),
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
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: _onItemTapped,
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.pinkAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddBookScreen()),
                );
              },
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
