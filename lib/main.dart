import 'package:flutter/material.dart';
import 'imageDetails_screen.dart'; //
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(MyApp());
}

final List<String> imagePaths = [
  "https://i.ibb.co/aaas",
  "https://i.ibb.co/aaasq",
  "https://i.ibb.co/aaasq2",
  "https://images.pexels.com/photos/842711/pexels-photo-842711.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
  // "https://images.pexels.com/ph1",
  // "siduias",
  '',
  "https://i.ibb.co/vz6x9zK/VOZ-CNKT.png",
  "https://i.ibb.co/vz6x9zK/VOZ-CNKT.png",
];

final List<String> errorImagePaths = [];

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

class ImageListScreen extends StatefulWidget {
  @override
  _ImageListScreenState createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  @override
  void initState() {
    super.initState();
    errorImagePaths.addAll(imagePaths.where((path) => path.isEmpty));
  }

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
                      ImageDetailScreen(imagePaths[index], imagePaths, index),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: imagePaths[index],
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => GestureDetector(
                    // onTap: () {
                    //   showDialog(
                    //     context: context,
                    //     builder: (context) => AlertDialog(
                    //       title: Text('Error'),
                    //       content: Text('Image not available.'),
                    //       actions: [
                    //         TextButton(
                    //           onPressed: () {
                    //             Navigator.of(context).pop();
                    //           },
                    //           child: Text('OK'),
                    //         ),
                    //       ],
                    //     ),
                    //   );
                    // },
                    child: Image.asset(
                      "assets/image_error.png",
                      width: 100,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
