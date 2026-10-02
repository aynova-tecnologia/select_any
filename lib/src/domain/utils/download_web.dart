import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Dispara o download de [bytes] no navegador, com o nome [fileName]
/// (Blob + ancora com atributo `download`).
void baixarNoNavegador(Uint8List bytes, String fileName) {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: _mimePorNome(fileName)),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

String _mimePorNome(String fileName) {
  final nome = fileName.toLowerCase();
  if (nome.endsWith('.csv')) return 'text/csv;charset=utf-8';
  if (nome.endsWith('.pdf')) return 'application/pdf';
  if (nome.endsWith('.xlsx')) {
    return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  }
  if (nome.endsWith('.txt')) return 'text/plain;charset=utf-8';
  return 'application/octet-stream';
}
