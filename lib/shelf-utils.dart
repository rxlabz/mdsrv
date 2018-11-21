import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

const HEADERS_CONTENT_HTML = const {'Content-Type': "text/html; charset=utf-8"};

/// Shelf app helper, provides basic shortcuts for
/// - handler pipeline
/// - with static handler
/// - with static handler
///
abstract class ShelfApp {
  String _dir;
  String _index;

  Handler get handler => _getHandler();

  FutureOr<Response> Function(Request r) get staticHandler =>
    createStaticHandler(rootPath(_dir), defaultDocument: _index);

  ShelfApp(this._dir, this._index);

  Handler _getHandler() {
    return const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(getCascadeHandler());
  }

  @protected
  Handler getCascadeHandler() => staticHandler;
}

int initPort(ArgResults args) {
  var port = int.parse(args['port'], onError: (val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });
  return port;
}

/// renvoie le chemin du dossier static de référence  exemple : /web
///
String rootPath(String relativePath) =>
  join(dirname(Platform.script.toFilePath()), '..', relativePath);
