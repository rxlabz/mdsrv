import 'dart:io';

const String fp = '/Users/rxlabz/dev/notes/Shell.md';

void main(List<String> args) {
  print('main... ');
  File f = new File(fp);
  //f.watch().listen((e)=>print('=> f ${e}'));
  f.parent.watch().listen((e){
    if(e is FileSystemMoveEvent && e.destination == fp){
      print('Modified with temp file');
    }
    if(e is FileSystemModifyEvent  && e.path == fp){
      print('Modified in place');
    }
    print('event => $e');
  });
}