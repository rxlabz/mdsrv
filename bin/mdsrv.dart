// Copyright (c) 2017, rxlabz. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:mdsrv/mdsrv-app.dart';
import 'package:mdsrv/shelf-utils.dart';
import 'package:shelf/shelf_io.dart' as io;

const DEFAULT_DIR = 'web';
const DEFAULT_INDEX = 'index.html';
const DEFAULT_PORT = '8765';

void main(List<String> args) {

  ArgResults params = getArgs(args);
  int port = initPort(params);

  final mdApp = new MdApp(params['dir'], DEFAULT_DIR, DEFAULT_INDEX);

  io.serve(mdApp.handler, '0.0.0.0', port).then((server) {
    print('MDSrvr started at http://${server.address.host}:${server.port} ...');
  });
}

ArgResults getArgs(List<String> args)
{
  final parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: DEFAULT_PORT)
    ..addOption(
      'dir',
      abbr: 'd',
    );
  return parser.parse(args);;
}
