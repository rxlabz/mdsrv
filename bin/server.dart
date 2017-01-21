// Copyright (c) 2017, rxlabz. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:markdown/markdown.dart';
import 'package:mdsrv/emoji.dart';
import 'package:mdsrv/file-utils.dart';
import 'package:mustache/mustache.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

const RESPONSE_HEADERS = const {'Content-Type': "text/html; charset=utf-8"};

const DEV_NOTES = '/users/rxlabz/dev/notes';

const DEFAULT_DIR = 'web';
const DEFAULT_PORT = '8765';
const DEFAULT_INDEX = 'index.html';


//String projectPath = '/users/rxlabz/dev/notes';
String rootDir;

void main(List<String> args) {
  var parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: DEFAULT_PORT)
    ..addOption('dir', abbr: 'd'/*, defaultsTo: projectPath*/);

  ArgResults params = parser.parse(args);
  int port = initPort(params);

  rootDir = params['dir'];

  final staticRoot = rootPath(DEFAULT_DIR);

  final handler = initHandler(staticRoot);

  io.serve(handler, '0.0.0.0', port).then((server) {
    print('MDSrvr started at http://${server.address.host}:${server.port} ...');
  });
}

int initPort(ArgResults args) {
  var port = int.parse(args['port'], onError: (val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });
  return port;
}

/// renvoie le chemin du dossier static de référence  exemple : /web
String rootPath(String relativePath) =>
    join(dirname(Platform.script.toFilePath()), '..', relativePath);

/// initialise le pipeline de traitement de la requete
shelf.Handler initHandler(String staticRoot) => const shelf.Pipeline()
    .addMiddleware(shelf.logRequests())
    .addHandler(new shelf.Cascade()
        .add(createStaticHandler(staticRoot, defaultDocument: DEFAULT_INDEX))
        .add(_browseRequest)
        .handler);

/// lecture du contenu de dossiers ou de fichiers .md
///
Future<shelf.Response> _browseRequest(shelf.Request request) async {
  String resp;

  //final bool isHome = request.url.toFilePath() == DEV_NOTES;
  final bool isHome = request.url.toFilePath() == '';

  if (await FileSystemEntity.isDirectory( rootDir + request.url.toFilePath())) {
    //final path = rootDir + request.url.toFilePath();
    final requestUrl = request.url.toFilePath();
    resp = await html(await getDirContentUl(rootDir, requestUrl, resp), showBack: !isHome);
  } else if (extension(request.url.toFilePath()) == ".md") {
    String mdContent = await new File( rootDir + request.url.toFilePath()).readAsString();
    resp = await html(markdownToHtml(MoJ.parse(mdContent)), showBack: !isHome);
  } else
    resp = '"${request.url}" is not a directory';

  return new shelf.Response.ok(resp, headers: RESPONSE_HEADERS);
}

/// injecte le body dans le template principal
///
Future<String> html(String body, {bool showBack = false}) async {
  String src = await new File('./web/index.tpl.html').readAsString();
  Template tpl = new Template(src, name: 'file.html');
  return tpl.renderString({"body": body, "showBack": showBack}).replaceAll(':fire:', "🔥");
}
