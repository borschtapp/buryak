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
}

class FormFieldsException extends FormGeneralException {
  final Map<String, dynamic> errors;

  FormFieldsException({
    required message,
    required this.errors,
  }) : super(message: message);
}

Exception handleFormErrors(Map<String, dynamic> json) {
  if (json['fields'] != null) {
    return FormFieldsException(message: json['message'], errors: json['fields']);
  } else {
    return FormGeneralException(message: json['message']);
  }
}
