import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:photo_view/photo_view.dart';

class ImageDetailScreen extends StatefulWidget {
  final String imagePath;
  final List<String> imagePaths;
  final int selectedIndex;

  ImageDetailScreen(this.imagePath, this.imagePaths, this.selectedIndex);

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  DefaultCacheManager cacheManager = DefaultCacheManager();
  bool isOnline = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkConnectionAndClearCache();
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

  late String currentImagePath;
  int selectedImageIndex = 0;
  final ScrollController _controller = ScrollController();

  bool _isPinching = false;
  double _imageScale = 1.0;

  @override
  void initState() {
    super.initState();
    currentImagePath = widget.imagePath;
    selectedImageIndex = widget.selectedIndex;
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
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      //cuộn tới ảnh đang được xem
      double offset = selectedImageIndex * 116.0 -
          MediaQuery.of(context).size.width / 2 +
          65;
      if (_controller.hasClients) {
        _controller.animateTo(
          offset,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void updateImagePath(String newPath, int index) {
    setState(() {
      currentImagePath = newPath;
      selectedImageIndex = index;

      double offset =
          index * 116.0 - MediaQuery.of(context).size.width / 2 + 65;

      if (_controller.hasClients) {
        _controller.animateTo(
          offset,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }

      // Thiết lập _imageScale về 1.0
      _imageScale = 1.0;
    });
  }

  BoxDecoration getDecorationForImage(int index, int currentIndex) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(
        color: index == currentIndex
            ? Color.fromARGB(255, 6, 59, 195)
            : Colors.transparent,
        width: 3.0,
      ),
    );
  }

  void nextImage() {
    if (selectedImageIndex < widget.imagePaths.length - 1) {
      updateImagePath(
          widget.imagePaths[selectedImageIndex + 1], selectedImageIndex + 1);
    } else {
      updateImagePath(widget.imagePaths.first, 0);
    }
  }

  void previousImage() {
    if (selectedImageIndex > 0) {
      updateImagePath(
          widget.imagePaths[selectedImageIndex - 1], selectedImageIndex - 1);
    } else {
      updateImagePath(widget.imagePaths.last, widget.imagePaths.length - 1);
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    setState(() {
      _isPinching = true;
      _imageScale = 1.0;
    });
  }

  Offset _imageCenter = Offset(0, 0);
  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // _isPinching = true;

      _imageCenter = details.localFocalPoint;
      _imageScale = details.scale;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    setState(() {
      _isPinching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageScale = 1.0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Detail'),
      ),
      body: Column(
        children: [
          _buildImageViewer(),
          _buildImageSelector(),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    return Expanded(
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: Stack(
          children: [
            Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              child: InteractiveViewer(
                // constrained: true,
                // panEnabled: false,
                // boundaryMargin: EdgeInsets.all(200),
                child: Center(
                  child: Transform.scale(
                    scale: _imageScale,
                    child: isOnline
                        ? CachedNetworkImage(
                            imageUrl: currentImagePath,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )
                        : Image.asset(
                            "assets/error_network.png",
                            width: 400,
                            height: 500,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // if (!_isPinching)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.grey,
                      size: 50.0,
                    ),
                    onPressed: previousImage,
                  ),
                  // SizedBox(width: 250),
                  // if (!_isPinching)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 50.0,
                    ),
                    onPressed: nextImage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Widget _buildImageViewer() {
//     return Expanded(
//       child: PhotoView(
//         imageProvider: CachedNetworkImageProvider(currentImagePath),
//         // : AssetImage("assets/error_network.png"),
//         minScale: PhotoViewComputedScale.contained,
//         maxScale: PhotoViewComputedScale.covered * 2.0,
//         initialScale: PhotoViewComputedScale.contained,
//       ),
//     );
//   }
  Widget _buildImageSelector() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: _controller,
          itemCount: widget.imagePaths.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  if (isOnline) {
                    updateImagePath(widget.imagePaths[index], index);
                  } else {
                    _showNoInternetDialog();
                  }
                },
                child: Container(
                  decoration: getDecorationForImage(index, selectedImageIndex),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: isOnline
                        ? CachedNetworkImage(
                            imageUrl: widget.imagePaths[index],
                            width: selectedImageIndex == index ? 130 : 100,
                            height: selectedImageIndex == index ? 110 : 80,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/image_error.png',
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
              ),
            );
          },
        ),
      ),
    );
  }
}
