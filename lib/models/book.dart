import 'dart:typed_data';

class Book {
  final int id;
  final String title;
  final String author;
  final String description; 
  final Map<String, double> userRatings; 
  final Map<String, bool> userReadStatus; 
  final String? imageUrl;
  final Uint8List? webImage;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description, 
    required this.userRatings,
    required this.userReadStatus,
    this.imageUrl,
    this.webImage,
  });

  
  double get averageRating {
    if (userRatings.isEmpty) return 0.0;
    return userRatings.values.reduce((a, b) => a + b) / userRatings.length;
  }

 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description, 
      'userRatings': userRatings,
      'userReadStatus': userReadStatus,
      'imageUrl': imageUrl,
      'webImage': webImage,
    };
  }

 
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      description: map['description'], 
      userRatings: Map<String, double>.from(map['userRatings']),
      userReadStatus: Map<String, bool>.from(map['userReadStatus']),
      imageUrl: map['imageUrl'],
      webImage: map['webImage'],
    );
  }


  @override
  String toString() {
    return 'Book{id: $id, title: $title, author: $author, description: $description, userRatings: $userRatings, userReadStatus: $userReadStatus, imageUrl: $imageUrl, webImage: $webImage}';
  }
}
