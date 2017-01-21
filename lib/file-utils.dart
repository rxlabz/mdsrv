import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';

import 'package:shelf/shelf.dart' as shelf;

/// renvoie une liste html des elements d'un dossier
///
Future<String> getDirContentUl(shelf.Request request, String resp) async {
  final root = new Directory(request.url.toFilePath());
  final items = await root
      .list()
      .where((f) =>
          FileSystemEntity.isDirectorySync(f.path) ||
          extension(f.path) == '.md')
      .where((f) => basename(f.path).split('').first != '.');

  final getClass = (FileSystemEntity f) => isDirSync(f.path) ? 'dir' : 'file';
  final getLink =
      (FileSystemEntity f) => "<a href='./${f.path}'>${basename(f.path)}</a>";
  final f2l =
      (FileSystemEntity f) => "<li class='${getClass(f)}'>${getLink(f)}</li>";

  return await "<ul>${ (await items.map(f2l).toList()).join()}</ul>";
}

/// renvoie un stream de files de
Future<String> filesToJson(Stream<FileSystemEntity> items) async {
  List<Map<String, String>> names = await items
      .map((FileSystemEntity f) => <String, String>{
            "name": "${isDirSync(f.path) ? '/' : ''}${basename(f.path)}"
          })
      .toList();
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  print('filesToJson  names ${await names}');

  return encoder.convert(await names);
}

Future<bool> isDir(String path) async {
  return await FileSystemEntity.isDirectory(path);
}

bool isDirSync(String path) {
  return FileSystemEntity.isDirectorySync(path);
}
