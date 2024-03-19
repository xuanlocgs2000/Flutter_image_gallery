import 'package:flutter/material.dart';
import 'imageDetails_screen.dart'; //
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  // addImagePathMultipleTimes("https://s.net.vn/lXgl", 1000);
  runApp(MyApp());
}

final List<String> imagePaths = [
  "https://i.ibb.co/aaas",
  "https://i.ibb.co/aaasq",
  "https://i.ibb.co/aaasq2",
  "https://images.pexels.com/photos/842711/pexels-photo-842711.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
  // "https://images.pexels.com/ph1",
  // "siduias",
  'https://s.net.vn/VSMa',
  'https://s.net.vn/JRlL',
  'https://s.net.vn/rdZj',
  'https://s.net.vn/lXgl',
  'https://s.net.vn/1Cdv',
  'https://s.net.vn/7FYa',
  'https://s.net.vn/kWBE',
  'https://s.net.vn/FU4E',
  'https://s.net.vn/cOY9',
  'https://s.net.vn/FsuT',
  'https://s.net.vn/TaRR',
  'https://s.net.vn/GPIr',
  'https://s.net.vn/Duh0',
  'https://s.net.vn/aIO4',
  'https://images.unsplash.com/photo-1710631292664-481aa3b59000?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  // "https://i.ibb.co/vz6x9zK/VOZ-CNKT.png",
];
void addImagePathMultipleTimes(String path, int times) {
  for (int i = 0; i < times; i++) {
    imagePaths.add(path);
  }
}

// final List<String> errorImagePaths = [];

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
  DefaultCacheManager cacheManager = DefaultCacheManager();
  bool isOnline = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkConnectionAndClearCache();
  }

  @override
  void initState() {
    super.initState();
    checkConnectionAndClearCache(); // Kiểm tra kết nối mạng và xóa cache
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          isOnline = false;
        });
      } else {
        setState(() {
          isOnline = true;
        });
      }
    });
  }

  Future<void> checkConnectionAndClearCache() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isOnline = false;
      });
      await cacheManager.emptyCache();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Không có kết nối mạng"),
          content: Text("Vui lòng kiểm tra kết nối mạng của bạn và thử lại."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Đóng"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    cacheManager.dispose(); // free cache
    super.dispose();
  }

  @override
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
              if (isOnline) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ImageDetailScreen(imagePaths[index], imagePaths, index),
                  ),
                );
              } else {
                _showNoInternetDialog();
              }
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: isOnline
                    ? CachedNetworkImage(
                        width: 200,
                        height: 300,
                        imageUrl: imagePaths[index],
                        cacheManager: cacheManager,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) => Image.asset(
                          "assets/image_error.png",
                          width: 100,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        "assets/error_network.png",
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
