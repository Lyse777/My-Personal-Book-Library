// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, sort_child_properties_last, no_leading_underscores_for_local_identifiers, unused_import, use_build_context_synchronously, unnecessary_import, prefer_const_constructors_in_immutables

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  EditBookScreen({required this.book});

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _author;
  late String _description; // New description field
  String? _imageUrl;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _title = widget.book.title;
    _author = widget.book.author;
    _description = widget.book.description; // Initialize description
    _imageUrl = widget.book.imageUrl;
    if (_imageUrl != null && _isLocalFilePath(_imageUrl!)) {
      _loadImage();
    } else if (_imageUrl != null && _isBase64(_imageUrl!)) {
      _imageBytes = base64Decode(_imageUrl!);
    }
  }

  bool _isLocalFilePath(String path) {
    return !path.startsWith('http') && !path.startsWith('data:image/');
  }

  bool _isBase64(String value) {
    try {
      final decodedBytes = base64Decode(value);
      return decodedBytes.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadImage() async {
    if (!kIsWeb && _isLocalFilePath(_imageUrl!)) {
      final bytes = await File(_imageUrl!).readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _imageBytes = result.files.single.bytes;
          _imageUrl = base64Encode(_imageBytes!);
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageUrl = pickedFile.path;
        });
      }
    }
  }

  Widget _buildImage() {
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        height: 200,
        width: 150,
        fit: BoxFit.cover,
      );
    } else if (_imageUrl != null) {
      if (_isBase64(_imageUrl!)) {
        return Image.memory(
          base64Decode(_imageUrl!),
          height: 200,
          width: 150,
          fit: BoxFit.cover,
        );
      } else if (_imageUrl!.startsWith('http')) {
        return Image.network(
          _imageUrl!,
          height: 200,
          width: 150,
          fit: BoxFit.cover,
        );
      } else if (_isLocalFilePath(_imageUrl!)) {
        if (kIsWeb) {
          return Text('Local file paths are not supported on web.');
        } else {
          return Image.file(
            File(_imageUrl!),
            height: 200,
            width: 150,
            fit: BoxFit.cover,
          );
        }
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black54 : Colors.purple,
        title: Text('Edit Book', style: TextStyle(fontFamily: 'Raleway')),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Edit Book Details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_imageUrl != null) Center(child: _buildImage()),
                      SizedBox(height: 20),
                      TextFormField(
                        initialValue: _title,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? Colors.black54 : Colors.white,
                        ),
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _title = value!;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: _author,
                        decoration: InputDecoration(
                          labelText: 'Author',
                          labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? Colors.black54 : Colors.white,
                        ),
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the author';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _author = value!;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: _description,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? Colors.black54 : Colors.white,
                        ),
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the description';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _description = value!;
                        },
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: Icon(Icons.upload_file, color: Colors.white),
                          label: Text(
                            'Upload Image',
                            style: TextStyle(fontFamily: 'Raleway', color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final updatedBook = Book(
                              id: widget.book.id,
                              title: _title,
                              author: _author,
                              description: _description, // Add description
                              userRatings: widget.book.userRatings,
                              userReadStatus: widget.book.userReadStatus,
                              imageUrl: _imageBytes != null ? base64Encode(_imageBytes!) : _imageUrl,
                            );
                            Provider.of<BookProvider>(context, listen: false).updateBook(updatedBook);
                            Navigator.pop(context, updatedBook);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.purple,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(fontSize: 18, fontFamily: 'Raleway'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
