#!/bin/bash

mdsrv="/Users/rxlabz/dev/projects/darxlibz/mdsrv/"

lsof -t -i tcp:8765 | xargs kill &
> $mdsrv/web/styles.css &
dart-sass $mdsrv/web/styles.scss >> $mdsrv/web/styles.css  &
/bin/sleep 1 && dart /Users/rxlabz/dev/projects/darxlibz/mdsrv/bin/server.dart -d /Users/rxlabz/dev/notes/ &
/bin/sleep 2 && /usr/bin/open -a "/Applications/Google Chrome.app" "http://0.0.0.0:8765"
