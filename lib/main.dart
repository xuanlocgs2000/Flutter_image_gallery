import 'package:flutter/material.dart';
import 'imageDetails_screen.dart'; //

void main() {
  runApp(MyApp());
}

final List<String> imagePaths = [
  "assets/img1.jpg",
  "assets/img2.jpg",
  "assets/img3.jpg",
  "assets/img4.jpg",
  "assets/img5.jpg",
  "assets/img6.jpg",
];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageListScreen(),
    );
  }
}

class ImageListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image List'),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        children: List.generate(imagePaths.length, (index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ImageDetailScreen(imagePaths[index], imagePaths),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePaths[index],
                  width: 100,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
