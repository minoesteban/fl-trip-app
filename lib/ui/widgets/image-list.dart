import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageList extends StatelessWidget {
  final String _pictureUrl;

  ImageList(this._pictureUrl);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      child: Hero(
        tag: _pictureUrl,
        child: CachedNetworkImage(
          width: MediaQuery.of(context).size.width - 10,
          fit: BoxFit.cover,
          imageUrl: '$_pictureUrl',
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
