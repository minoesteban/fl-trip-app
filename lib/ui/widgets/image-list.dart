import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tripper/core/utils/s3-auth-headers.dart';

class ImageList extends StatelessWidget {
  final List<String> _images;

  ImageList(this._images);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      child: Hero(
        tag: _images[0],
        child: CachedNetworkImage(
          width: MediaQuery.of(context).size.width - 10,
          fit: BoxFit.cover,
          httpHeaders: generateAuthHeaders(_images[0]),
          imageUrl: _images[0],
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
