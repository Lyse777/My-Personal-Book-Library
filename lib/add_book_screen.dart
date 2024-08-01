// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, sort_child_properties_last, unused_local_variable, unused_import

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddBookScreen extends StatefulWidget {
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _author = '';
  String _description = ''; // New description field
  Uint8List? _imageBytes;
  String? _imageName;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _imageBytes = result.files.single.bytes;
          _imageName = result.files.single.name;
        });
      }
    } else {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = pickedFile.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Book', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add a New Book',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Raleway',
                ),
              ),
              SizedBox(height: 16),
              if (_imageBytes != null)
                Center(
                  child: kIsWeb
                      ? Image.memory(
                          _imageBytes!,
                          height: 200,
                          width: 150,
                          fit: BoxFit.cover,
                        )
                      : Image.memory(
                          _imageBytes!,
                          height: 200,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Author',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
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
                    style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      String? imageUrl;
                      if (kIsWeb && _imageBytes != null) {
                        imageUrl = base64Encode(_imageBytes!);
                      } else {
                        imageUrl = _imageName;
                      }
                      final newBook = Book(
                        id: DateTime.now().millisecondsSinceEpoch,
                        title: _title,
                        author: _author,
                        description: _description, // Add description
                        userRatings: {},
                        userReadStatus: {},
                        imageUrl: imageUrl,
                        webImage: _imageBytes,
                      );
                      Provider.of<BookProvider>(context, listen: false).addBook(newBook);
                      Fluttertoast.showToast(
                        msg: 'Book added successfully',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 5,
                        backgroundColor: Colors.purple,
                        textColor: Colors.white,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
