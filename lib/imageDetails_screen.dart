import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    currentImagePath = widget.imagePath;
    selectedImageIndex = widget.selectedIndex;
  }

  void updateImagePath(String newPath, int index) {
    setState(() {
      currentImagePath = newPath;
      selectedImageIndex = index;

      double offset =
          index * 116.0 - MediaQuery.of(context).size.width / 2 + 65;

      _controller.animateTo(
        offset,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
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
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = _previousScale * details.scale;
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
          boundaryMargin: EdgeInsets.all(200),
          clipBehavior: Clip.hardEdge,
          onInteractionStart: (details) => _onScaleStart(details),
          onInteractionUpdate: (details) => _onScaleUpdate(details),
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
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey,
                    size: 50.0,
                  ),
                  onPressed: previousImage,
                ),
                Spacer(),
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
                    child: Image.network(
                      widget.imagePaths[index],
                      width: selectedImageIndex == index ? 130 : 100,
                      height: selectedImageIndex == index ? 110 : 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/image_error.png',
                          width: 100,
                          height: 200,
                          fit: BoxFit.cover,
                        );
                      },
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
