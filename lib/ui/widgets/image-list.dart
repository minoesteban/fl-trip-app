import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tripper/core/utils/s3-auth-headers.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageList extends StatelessWidget {
  final List<String> _names;
  final List<String> _images;
  final int _selected;

  ImageList(this._names, this._images, this._selected);

  // @override
  // Widget build(BuildContext context) {
  //   return Dialog(
  //     insetPadding: const EdgeInsets.symmetric(horizontal: 10),
  //     child: Hero(
  //       tag: _images[0],
  //       child: CachedNetworkImage(
  //         width: MediaQuery.of(context).size.width - 10,
  //         fit: BoxFit.cover,
  //         httpHeaders: generateAuthHeaders(_images[0], context),
  //         imageUrl: _images[0],
  //         placeholder: (context, url) => Center(
  //           child: CircularProgressIndicator(
  //             strokeWidth: 0.5,
  //             valueColor: AlwaysStoppedAnimation(Colors.grey[100]),
  //           ),
  //         ),
  //         errorWidget: (context, url, error) => Icon(Icons.error),
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 400.0,
                enlargeCenterPage: true,
                initialPage: _selected,
              ),
              items: _images.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      // decoration: BoxDecoration(color: Colors.transparent),
                      child: Column(
                        // mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CachedNetworkImage(
                            width: MediaQuery.of(context).size.width - 10,
                            fit: BoxFit.contain,
                            httpHeaders:
                                generateAuthHeaders(_images[0], context),
                            imageUrl: _images[_images.indexOf(i)],
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 0.5,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.grey[100]),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _names[_images.indexOf(i)],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 1.1,
                              fontFamily: 'Nunito',
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            CloseButton(
              color: Colors.white,
            )
          ],
        ));
  }
}
