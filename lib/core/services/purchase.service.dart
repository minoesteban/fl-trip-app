import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tripper/providers/credentials.provider.dart';
import '../../core/models/purchase.model.dart';
import '../../config.dart';

class PurchaseService {
  String _endpoint = Platform.isAndroid ? API_ENDPOINT_ANDROID : API_ENDPOINT;

  Future<List<PurchaseCount>> getCounts() async {
    var _headersJustKey = {'x-api-key': await getKey('gk')};
    final res =
        await http.get('$_endpoint/purchases/count', headers: _headersJustKey);
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
