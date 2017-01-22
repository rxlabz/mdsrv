#!/bin/bash

# kill port 8765 if used
# TODO ask confirmation

if lsof -t -i tcp:8765
then
    echo 'occupé'
else
    echo 'libre'
fi

lsof -t -i tcp:8765 | xargs kill &

# tools dir path
MDSRV_TOOLS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# parent dir path
MDSRV="$( cd "$( dirname "${MDSRV_TOOLS}" )" && pwd )"

# empty styles.css before compiling sass
> $MDSRV/web/styles.css &

# compilation Sass vers styles.css
dart-sass $MDSRV/web/styles.scss >> $MDSRV/web/styles.css &

# launch md-server
/bin/sleep 1 && dart "$1" -d "$2" &

# open in browser
/bin/sleep 2 && /usr/bin/open -a "/Applications/Google Chrome.app" "http://0.0.0.0:8765"
