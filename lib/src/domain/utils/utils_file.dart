import 'dart:io';

import 'package:msk_utils/msk_utils.dart';
import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class UtilsFileSelect {
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
    } else if (Platform.isMacOS) {
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
