import 'package:mdsrv/emoji.dart';

void main(List<String> args) {
  RegExp r = new RegExp(r'(:[a-z]+:)');
  String t = ":warning: yo :fire: les :fire: potes";

  final matches = r.allMatches(t).toList();

  print('matches.length => ${matches.length}');

  matches.forEach((m){
    print('gpCount ${m.groupCount}');
    print('start-end => ${m.start} ${m.end}');
    print('mGroup0 => ${m.group(0)} => ${MoJ.tag(m.group(0))}');
  } );

}