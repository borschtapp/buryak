import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('flutterConfig')
external JSObject? get _flutterConfig;

String? getRuntimeApiUrl() {
  final url = _flutterConfig?.getProperty<JSString?>('apiBaseUrl'.toJS)?.toDart;
  if (url != null && url.isNotEmpty) return url;
  return null;
}
