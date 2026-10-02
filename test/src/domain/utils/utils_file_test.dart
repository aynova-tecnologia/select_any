import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/src/domain/utils/download_stub.dart';
import 'package:select_any/src/domain/utils/utils_file.dart';

void main() {
  test('stub de download (nativo) lanca UnsupportedError', () {
    expect(
      () => baixarNoNavegador(Uint8List.fromList([1]), 'a.csv'),
      throwsUnsupportedError,
    );
  });

  group('salvarOuBaixar no nativo grava e devolve o arquivo', () {
    late Directory tmp;
    late Directory original;

    setUp(() {
      original = Directory.current;
      tmp = Directory.systemTemp.createTempSync('select_any_file_test');
      Directory.current = tmp;
    });

    tearDown(() {
      Directory.current = original;
      tmp.deleteSync(recursive: true);
    });

    test('bytes', () async {
      final file = await UtilsFileSelect.salvarOuBaixarBytes(
        [1, 2, 3],
        fileName: 'x.pdf',
        openExplorer: false,
      );
      expect(file, isNotNull);
      expect(file!.readAsBytesSync(), [1, 2, 3]);
    });

    test('string', () async {
      final file = await UtilsFileSelect.salvarOuBaixarString(
        'a;b',
        fileName: 'x.csv',
        openExplorer: false,
      );
      expect(file, isNotNull);
      expect(file!.path.endsWith('x.csv'), isTrue);
      expect(file.readAsStringSync(), 'a;b');
    });
  });
}
