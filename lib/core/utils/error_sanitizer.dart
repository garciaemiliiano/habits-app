/// Saca la API key de un mensaje de error que la haya incluído como
/// query param (típico cuando el SDK de Google AI expone el request URL
/// dentro del exception toString()).
String sanitizeApiError(Object error) {
  return error.toString().replaceAll(
        RegExp(r'key=[A-Za-z0-9_\-]+'),
        'key=***',
      );
}
