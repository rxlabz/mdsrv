import 'dart:async';
import 'dart:io';

import 'package:markdown/markdown.dart';
import 'package:mdsrv/file-utils.dart';
import 'package:mdsrv/shelf-utils.dart';
import 'package:mustache/mustache.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:moj/moj.dart';

class MdApp extends ShelfApp{

  MDBrowser mdBrowser;

  MdApp(String rootDir, String dir, String index) : super(dir, index){
    mdBrowser = new MDBrowser(rootDir);
  }

  @override
  Handler getCascadeHandler() => new Cascade()
    .add(staticHandler)
    .add(mdBrowser.browse)
    .handler;

}

/// injecte le body dans le template principal
///
Future<String> html(String body, {bool showBack = false}) async {
  String src = await new File('./web/index.tpl.html').readAsString();
  Template tpl = new Template(src, name: 'file.html');
  return tpl.renderString({"body": body, "showBack": showBack});
}

class MDBrowser {

  String rootDir;

  MDBrowser(this.rootDir);

  browse(Request req) async {
    String resp;

    final bool isHome = req.url.toFilePath() == '';

    if (await isDir(rootDir + req.url.toFilePath())) {
      final reqUrl = req.url.toFilePath();
      resp = await html(await getDirContentUl(rootDir, reqUrl, resp),
        showBack: !isHome);
    } else if (extension(req.url.toFilePath()) == ".md") {
      String mdContent =
      await new File(rootDir + '/' + req.url.toFilePath()).readAsString();
      resp =
      await html(markdownToHtml(MoJ.parse(mdContent)), showBack: !isHome);
    } else
      resp = '"${req.url}" is not a directory';

    return new Response.ok(resp, headers: HEADERS_CONTENT_HTML);
  }
}