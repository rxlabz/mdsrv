// Copyright (c) 2017, rxlabz. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:mustache/mustache.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:markdown/markdown.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

const RESPONSE_HEADERS = const {'Content-Type': "text/html; charset=utf-8"};

const DEFAULT_DIR = 'web';

void main(List<String> args) {
  var parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8765');

  var result = parser.parse(args);

  var port = int.parse(result['port'], onError: (val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });

  var rootPath = join(dirname(Platform.script.toFilePath()), '..', 'web');

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(new shelf.Cascade()
          .add(createStaticHandler(rootPath, defaultDocument: 'index.html'))
          .add(_readRequest)
          .handler);

  io.serve(handler, '0.0.0.0', port).then((server) {
    print('MDSrvr started at http://${server.address.host}:${server.port} ...');
  });
}

rootPath(String relativePath) =>
    join(dirname(Platform.script.toFilePath()), '..', relativePath);

Future<shelf.Response> _readRequest(shelf.Request request) async {
  String resp;

  if (await FileSystemEntity.isDirectory(request.url.toFilePath())) {
    resp = await getDirContentHtml(request, resp);
  } else if (extension(request.url.toFilePath()) == ".md") {
    String mdContent = await new File(request.url.toFilePath()).readAsString();
    final cnv = new HtmlUnescape();
    resp = await html(markdownToHtml(mdContent));
  } else
    resp = '"${request.url}" is not a directory';

  return new shelf.Response.ok(resp, headers: RESPONSE_HEADERS);
}

Future<String> getDirContentHtml(shelf.Request request, String resp) async {
  final root = new Directory(request.url.toFilePath());
  final items = await root.list();
  final getClass = (FileSystemEntity f) => isDirSync(f.path) ? 'dir' : 'file';
  final getLink =
      (FileSystemEntity f) => "<a href='./${f.path}'>${basename(f.path)}</a>";
  final f2l =
      (FileSystemEntity f) => "<li class='${getClass(f)}'>${getLink(f)}</li>";
  resp = await html("<ul>${ (await items.map(f2l).toList()).join()}</ul>");
  return resp;
}

filesToJson(Stream<FileSystemEntity> items) async {
  List<Map<String, String>> names = await items
      .map((FileSystemEntity f) => <String, String>{
            "name": "${isDirSync(f.path) ? '/' : ''}${basename(f.path)}"
          })
      .toList();
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  print('filesToJson  names ${await names}');
  //return names;
  return encoder.convert(await names);
}

Future<bool> isDir(String path) async {
  return await FileSystemEntity.isDirectory(path);
}

bool isDirSync(String path) {
  return FileSystemEntity.isDirectorySync(path);
}

Future<String> html(String body, {bool home = false}) async {
  String src = await new File('./web/index.tpl.html').readAsString();
  Template tpl = new Template(src, name: 'file.html');
  return tpl.renderString({"body": body, "atHome": !home});

/*  String src = '''
<!doctype html>
<html lang="en">
<head>
  <base href="/">
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" href="atom-one-dark.css">
    <link rel="stylesheet" href="styles.css">
    <title>MDSRV</title>
</head>
<body>
<header><h1>dev.logs</h1></header>
<div id="container">
{{body}}
</div>
</body>
<script src="highlight.pack.js"></script>

<script>hljs.initHighlightingOnLoad();</script>
</html>
''';*/
  //Template tpl = new Template(src,name:'file.html');
  //return tpl.renderString({"body":body});
  return src.replaceFirst('{{body}}', body);
}
