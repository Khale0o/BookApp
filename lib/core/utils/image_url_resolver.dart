import 'package:bookapp/core/config/app_config.dart';

String? resolveBookImageUrl(
  String? value, {
  String baseUrl = AppConfig.apiBaseUrl,
}) {
  final raw = value?.trim();
  if (raw == null || raw.isEmpty) return null;
  final normalized = raw.replaceAll('\\', '/');
  if (normalized.startsWith('//')) {
    return _validatedNetworkUri('https:$normalized');
  }
  final uri = Uri.tryParse(normalized);
  if (uri == null) return null;
  if (uri.hasScheme) {
    return _validatedNetworkUri(normalized);
  }
  final looksLikeHostPath = RegExp(
    r'^[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+/',
  ).hasMatch(normalized);
  if (looksLikeHostPath || normalized.toLowerCase().startsWith('www.')) {
    return _validatedNetworkUri('https://$normalized');
  }
  final origin = Uri.tryParse(baseUrl);
  if (origin == null || !origin.hasScheme || origin.host.isEmpty) return null;
  return origin.resolveUri(uri).toString();
}

String? _validatedNetworkUri(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    return null;
  }
  return uri.toString();
}
