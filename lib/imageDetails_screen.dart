import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageDetailScreen extends StatefulWidget {
  final String imagePath;
  final List<String> imagePaths;
  final int selectedIndex;

  ImageDetailScreen(this.imagePath, this.imagePaths, this.selectedIndex);

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  late String currentImagePath;
  int selectedImageIndex = 0;
  final ScrollController _controller = ScrollController();
  double _scale = 1.0;
  double _previousScale = 5.0;
  bool _isPinching = false;
  @override
  void initState() {
    super.initState();
    currentImagePath = widget.imagePath;
    selectedImageIndex = widget.selectedIndex;

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
    _previousScale = _scale;
    setState(() {
      _isPinching = true; // start pinch
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = _previousScale * details.scale;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    setState(() {
      _isPinching = false; // end pinch
    });
  }

  @override
  Widget build(BuildContext context) {
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
      child: Container(
        child: InteractiveViewer(
          constrained: true,
          panEnabled: false,
          boundaryMargin: EdgeInsets.all(200),
          clipBehavior: Clip.hardEdge,
          // use pinch to scale
          onInteractionStart: (details) => _onScaleStart(details),
          onInteractionUpdate: (details) => _onScaleUpdate(details),
          onInteractionEnd: (details) => _onScaleEnd(details),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.symmetric(horizontal: 30),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(currentImagePath),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!_isPinching)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.grey,
                      size: 50.0,
                    ),
                    onPressed: previousImage,
                  ),
                Spacer(),
                if (!_isPinching)
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
        ),
      ),
    );
  }

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
                  updateImagePath(widget.imagePaths[index], index);
                },
                child: Container(
                  decoration: getDecorationForImage(index, selectedImageIndex),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
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
