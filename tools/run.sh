#!/bin/bash

lsof -t -i tcp:8765 | xargs kill &
MDSRV="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MDSRV="$( cd "$( dirname "${MDSRV}" )" && pwd )"
echo '---'$MDSRV'----'
> $MDSRV/web/styles.css &
dart-sass $MDSRV/web/styles.scss >> $MDSRV/web/styles.css &
/bin/sleep 1 && dart /Users/rxlabz/dev/projects/darxlibz/mdsrv/bin/server.dart -d /Users/rxlabz/dev/notes/ &
/bin/sleep 2 && /usr/bin/open -a "/Applications/Google Chrome.app" "http://0.0.0.0:8765"
