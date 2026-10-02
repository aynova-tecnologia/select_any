import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:msk_utils/msk_utils.dart';
import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'download_stub.dart' if (dart.library.js_interop) 'download_web.dart';

class UtilsFileSelect {
  /// Na web baixa [s] pelo navegador e devolve null; no nativo salva como
  /// [saveFileString] e devolve o arquivo. Prefira este metodo a
  /// [saveFileString] quando o codigo tambem roda na web.
  static Future<File?> salvarOuBaixarString(
    String s, {
    String? fileName,
    String? extensionFile,
    String? dirComplementar,
    String? contentExport,
    bool openExplorer = true,
    bool openFileInDesktop = true,
  }) async {
    if (kIsWeb) {
      // BOM para o Excel abrir o CSV em UTF-8 com acentos corretos
      final bytes = Uint8List.fromList(
        [
          ...(s.startsWith('﻿') ? const <int>[] : const [0xEF, 0xBB, 0xBF]),
          ...utf8.encode(s)
        ],
      );
      baixarNoNavegador(bytes, _nomeParaDownload(fileName, extensionFile));
      return null;
    }
    return saveFileString(
      s,
      fileName: fileName,
      extensionFile: extensionFile,
      dirComplementar: dirComplementar,
      contentExport: contentExport,
      openExplorer: openExplorer,
      openFileInDesktop: openFileInDesktop,
    );
  }

  /// Na web baixa [bytes] pelo navegador e devolve null; no nativo salva como
  /// [saveFileBytes] e devolve o arquivo. Prefira este metodo a
  /// [saveFileBytes] quando o codigo tambem roda na web.
  static Future<File?> salvarOuBaixarBytes(
    List<int> bytes, {
    String? fileName,
    String? extensionFile,
    String? dirExtra,
    String? contentExport,
    bool openExplorer = true,
    bool openFileInDesktop = true,
  }) async {
    if (kIsWeb) {
      baixarNoNavegador(
        Uint8List.fromList(bytes),
        _nomeParaDownload(fileName, extensionFile),
      );
      return null;
    }
    return saveFileBytes(
      bytes,
      fileName: fileName,
      extensionFile: extensionFile,
      dirExtra: dirExtra,
      contentExport: contentExport,
      openExplorer: openExplorer,
      openFileInDesktop: openFileInDesktop,
    );
  }

  /// Nome do arquivo baixado: usa [fileName] (ou o timestamp) e garante a
  /// extensao sem duplica-la (chamadores passam 'csv' ou '.csv').
  static String _nomeParaDownload(String? fileName, String? extensionFile) {
    var nome = fileName ?? '${DateTime.now().millisecondsSinceEpoch}';
    if (extensionFile != null && extensionFile.isNotEmpty) {
      final ext =
          extensionFile.startsWith('.') ? extensionFile : '.$extensionFile';
      if (!nome.toLowerCase().endsWith(ext.toLowerCase())) nome += ext;
    }
    return nome;
  }

  static Future<File> saveFileString(
    String s, {
    String? fileName,
    String? extensionFile,
    String? dirComplementar,
    String? contentExport,
    bool openExplorer = true,
    bool openFileInDesktop = true,
  }) async {
    String directory;
    String separator = UtilsPlatform.isWindows ? "\\" : "/";

    if (UtilsPlatform.isDesktop) {
      directory = '${io.Directory.current.path}$separator Files';
    } else if (UtilsPlatform.isIOS) {
      directory = (await getTemporaryDirectory()).absolute.path;
    } else {
      directory = (await getExternalStorageDirectory())!.absolute.path;
    }

    if (dirComplementar != null) {
      directory += '$separator$dirComplementar';
    }

    io.File file = io.File(
      '$directory$separator${DateTime.now().millisecondsSinceEpoch}',
    );
    io.Directory dir = io.Directory('$directory');

    if (!(await dir.exists())) {
      dir = await dir.create(recursive: true);
    }

    fileName ??=
        '${DateTime.now().millisecondsSinceEpoch}${extensionFile ?? ""}';
    file = io.File('${dir.path}$separator$fileName');

    if (!(await file.exists())) {
      file = await file.create(recursive: true);
    }

    await file.writeAsBytes(s.codeUnits);

    if (openExplorer) {
      await openFileOrDirectory(
          file.path, openFileInDesktop ? file.path : dir.path,
          contentExport: contentExport);
    }

    return file;
  }

  static Future<File> saveFileBytes(
    List<int> bytes, {
    String? fileName,
    String? extensionFile,
    String? dirExtra,
    String? contentExport,
    bool openExplorer = true,
    bool openFileInDesktop = true,
  }) async {
    String directory;
    String separator = UtilsPlatform.isWindows ? "\\" : "/";

    if (UtilsPlatform.isDesktop) {
      directory = '${io.Directory.current.path}$separator Files';
    } else if (UtilsPlatform.isIOS) {
      directory = (await getTemporaryDirectory()).absolute.path;
    } else {
      directory = (await getExternalStorageDirectory())!.absolute.path;
    }

    if (dirExtra != null) {
      directory += '$separator$dirExtra';
    }

    io.File file = io.File(
      '$directory$separator${DateTime.now().millisecondsSinceEpoch}',
    );
    io.Directory dir = io.Directory('$directory');

    if (!(await dir.exists())) {
      dir = await dir.create(recursive: true);
    }

    fileName ??= '${DateTime.now().millisecondsSinceEpoch}';
    if (extensionFile != null && extensionFile.isNotEmpty) {
      fileName += extensionFile;
    }

    file = io.File('${dir.path}$separator$fileName');

    if (!(await file.exists())) {
      file = await file.create(recursive: true);
    }

    await file.writeAsBytes(bytes);

    if (openExplorer) {
      await openFileOrDirectory(
        file.path,
        openFileInDesktop ? file.path : dir.path,
        contentExport: contentExport,
      );
    }

    return file;
  }

  static openFileOrDirectory(
    String filePath,
    String directoryPath, {
    String? contentExport,
  }) async {
    if (UtilsPlatform.isWeb) {
      return;
    }

    if (UtilsPlatform.isWindows) {
      await UtilsPlatform.openProcess(
        'explorer.exe',
        args: ['$directoryPath'],
      );
    } else if (UtilsPlatform.isMacos) {
      await UtilsPlatform.openProcess('open', args: ['$directoryPath']);
    } else if (UtilsPlatform.isMobile) {
      // Convertendo o caminho do arquivo para XFile
      final xFile = XFile(filePath);

      // Use share_plus para compartilhar o arquivo
      await Share.shareXFiles(
        [xFile], // Passando o XFile na lista
        text: contentExport ?? 'Segue em anexo seu relatório',
      );
    }
  }
}
