import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../core/models/rating.model.dart';
import '../../config.dart';

class RatingService {
  String _endpoint = Platform.isAndroid ? API_ENDPOINT_ANDROID : API_ENDPOINT;

  Future<List<Rating>> getRatingsBy(int tripId, int placeId) async {
    String url = '$_endpoint/ratings?';
    if (tripId > 0) url += 'tripId=$tripId';
    if (placeId > 0) url += '&placeId=$placeId';

    final res = await http.get(url);
    if (res.statusCode == HttpStatus.ok)
      return parseRatings(res.body);
    else
      throw HttpException(res.body);
  }

  List<Rating> parseRatings(String data) {
    final decoded = json.decode(data);
    return decoded['ratings']
        .map<Rating>((json) => Rating.fromMap(json))
        .toList();
  }
}
