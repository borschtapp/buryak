import 'dart:convert';

String generateFakeJwt({Duration? expiresIn}) {
  final exp = expiresIn != null ? (DateTime.now().add(expiresIn).millisecondsSinceEpoch ~/ 1000) : 9999999999;

  final header = base64Url.encode(utf8.encode(json.encode({'alg': 'HS256', 'typ': 'JWT'})));
  final payload = base64Url.encode(utf8.encode(json.encode({'exp': exp})));
  return '$header.$payload.fake_signature';
}

// JWT with exp=9999999999 (year 2286) — always valid in tests
const String kFutureJwt =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
    '.eyJleHAiOjk5OTk5OTk5OTl9'
    '.7oYMFDqJFpPTUhLGpSc3kB5FTJbGtEHuuvkNXbp8xco';

// JWT with exp=1 (year 1970) — always expired in tests
const String kExpiredJwt =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
    '.eyJleHAiOjF9'
    '.lDHmysKBwjkMzAGSZehf8CxSe3G8pjHEpPwf1Yf4u1I';

Map<String, dynamic> fakeUserJson({String? accessToken, String? refreshToken}) => {
  'id': 'user-1',
  'household_id': 'household-1',
  'name': 'Test User',
  'email': 'test@example.com',
  'updated': '2024-01-01T00:00:00.000Z',
  'created': '2024-01-01T00:00:00.000Z',
  'access_token': accessToken ?? kFutureJwt,
  'refresh_token': refreshToken ?? 'refresh-token-abc',
};
