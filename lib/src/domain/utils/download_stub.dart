import 'dart:typed_data';

/// Implementacao nativa: download pelo navegador nao existe fora da web.
/// Quem chama deve checar `kIsWeb` antes.
void baixarNoNavegador(Uint8List bytes, String fileName) {
  throw UnsupportedError('Download pelo navegador so existe na web');
}
