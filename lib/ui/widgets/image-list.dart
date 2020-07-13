import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageList extends StatelessWidget {
  final String _imageUrl;

  ImageList(this._imageUrl);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Hero(
        tag: _imageUrl,
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: '$_imageUrl',
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              strokeWidth: 0.5,
              valueColor: AlwaysStoppedAnimation(Colors.grey[100]),
            ),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}
