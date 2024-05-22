import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.lightBlueAccent,
          foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,

            )
        )
      ),
      home: PhotoListScreen(),
    );
  }
}

class Photo {
  final int id;
  final String title;
  final String thumbnailUrl;
  final String url;

  Photo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.url,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      url: json['url'],
    );
  }
}

class PhotoListScreen extends StatefulWidget {
  @override
  _PhotoListScreenState createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  bool _getPhotoListInProgress = false;
  List<Photo> photoList = [];

  @override
  void initState() {
    super.initState();
    _getPhotoList();
  }

  Future<void> _getPhotoList() async {
    setState(() {
      _getPhotoListInProgress = true;
    });

    const String photoListUrl = 'https://jsonplaceholder.typicode.com/photos';
    Uri uri = Uri.parse(photoListUrl);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        photoList = jsonResponse.map((photo) => Photo.fromJson(photo)).take(10).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get photos! Try again")),
      );
    }

    setState(() {
      _getPhotoListInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Gallery"),
      ),
      body: Visibility(
        visible: !_getPhotoListInProgress,
        replacement: const Center(
          child: CircularProgressIndicator(),
        ),
        child: ListView.separated(
          itemCount: photoList.length,
          itemBuilder: (context, index) {
            return _buildPhotoItem(context, photoList[index]);
          },
          separatorBuilder: (_, __) => Divider(),
        ),
      ),
    );
  }

  Widget _buildPhotoItem(BuildContext context, Photo photo) {
    return ListTile(
      leading: Image.network(
        photo.thumbnailUrl,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image);
        },
      ),
      title: Text(photo.title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoDetailScreen(photo: photo),
          ),
        );
      },
    );
  }
}

class PhotoDetailScreen extends StatelessWidget {
  final Photo photo;

  PhotoDetailScreen({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              photo.url,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, size: 100);
              },
            ),
            SizedBox(height: 16),
            Text(
              'Title: ${photo.title}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'ID: ${photo.id}',
              style: TextStyle(fontSize: 18),

            ),
          ],
        ),
      ),
    );
  }
}
