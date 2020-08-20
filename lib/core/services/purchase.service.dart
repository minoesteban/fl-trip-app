import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../core/models/purchase.model.dart';
import '../../config.dart';

class PurchaseService {
  String _endpoint = Platform.isAndroid ? API_ENDPOINT_ANDROID : API_ENDPOINT;

  Future<List<PurchaseCount>> getCounts() async {
    final res = await http.get('$_endpoint/purchases/count');
    if (res.statusCode == HttpStatus.ok)
      return parseCounts(res.body);
    else
      throw HttpException(res.body);
  }

  List<PurchaseCount> parseCounts(String data) {
    final decoded = json.decode(data);
    List<PurchaseCount> counts = [];
    counts.addAll(decoded['trips']
        .map<PurchaseCount>((json) => PurchaseCount.fromMap(json))
        .toList());
    counts.addAll(decoded['places']
        .map<PurchaseCount>((json) => PurchaseCount.fromMap(json))
        .toList());
    return counts;
  }
}
