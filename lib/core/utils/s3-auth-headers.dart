import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:tripper/credentials.dart';

Map<String, String> generateAuthHeaders(String url) {
  Map<String, String> headers;

  String accessKeyId = AWS_ACCESS_KEY_ID;
  String secretAccessKey = AWS_SECRET_ACCESS_KEY;

  String host = Uri.parse(url).host;
  String region = 'us-east-1';
  String service = 's3';
  String key = Uri.parse(url).path.substring(1);
  String payload = SigV4.hashCanonicalRequest('');
  String datetime = SigV4.generateDatetime();
  String canonicalRequest = '''GET
${'/$key'.split('/').map((s) => Uri.encodeComponent(s)).join('/')}

host:$host
x-amz-content-sha256:$payload
x-amz-date:$datetime

host;x-amz-content-sha256;x-amz-date
$payload''';
  final credentialScope = SigV4.buildCredentialScope(datetime, region, service);
  final stringToSign = SigV4.buildStringToSign(
      datetime, credentialScope, SigV4.hashCanonicalRequest(canonicalRequest));
  final signingKey =
      SigV4.calculateSigningKey(secretAccessKey, datetime, region, service);
  final signature = SigV4.calculateSignature(signingKey, stringToSign);

  final authorization = [
    'AWS4-HMAC-SHA256 Credential=$accessKeyId/$credentialScope',
    'SignedHeaders=host;x-amz-content-sha256;x-amz-date',
    'Signature=$signature',
  ].join(',');

  headers = {
    'Authorization': authorization,
    'x-amz-content-sha256': payload,
    'x-amz-date': datetime,
    // 'Accept': '*/*',
    // 'Connection': 'keep-alive',
  };

  return headers;
}

// host:$host
// x-amz-content-sha256:$payload
// x-amz-date:$datetime
// x-amz-security-token:${_credentials.sessionToken}

// headers = {
//     'Authorization': authorization,
//     'x-amz-content-sha256': payload,
//     'x-amz-date': datetime,
//     'x-amz-security-token': _credentials.sessionToken,
//   };
