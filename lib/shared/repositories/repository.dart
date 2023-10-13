Uri buildUri(String path, [Map<String, dynamic /*String?|Iterable<String>*/ >? params]) {
  return Uri(
    scheme: 'https',
    host: 'smetana.borscht.app',
    // port: port,
    path: '/api$path',
    queryParameters: params,
  );
}

Map<String, String> buildHeaders({String? accessToken}) {
  Map<String, String> headers = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };
  if (accessToken != null) {
    headers['Authorization'] = 'Bearer $accessToken';
  }
  return headers;
}

class FormGeneralException implements Exception {
  final String message;

  FormGeneralException({
    required this.message,
  });

  @override
  String toString() {
    return message;
  }
}

class FormFieldsException extends FormGeneralException {
  final Map<String, dynamic> fields;

  FormFieldsException({
    required message,
    required this.fields,
  }) : super(message: message);

  @override
  String toString() {
    var first = fields.entries.first;
    return '${first.key}: ${first.value.first}';
  }
}

Exception handleFormErrors(Map<String, dynamic> json) {
  if (json['fields'] != null) {
    return FormFieldsException(message: json['message'], fields: json['fields']);
  } else {
    return FormGeneralException(message: json['message']);
  }
}
