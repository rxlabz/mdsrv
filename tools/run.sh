#!/bin/bash

# kill port 8765 if used
# TODO ask confirmation

if lsof -t -i tcp:8765
then
    echo 'port 8765 is not available. Kill process ?'
    select result in "yes" "no"; do
        if [ "$result" = "yes" ]
        then
            lsof -t -i tcp:8765 | xargs kill &
            break
        else
            echo 'Cancelled...'
        fi
        exit
    done
fi

# tools dir path
MDSRV_TOOLS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# parent dir path
MDSRV="$( cd "$( dirname "${MDSRV_TOOLS}" )" && pwd )"

# empty styles.css before compiling sass
> $MDSRV/web/styles.css &

# compilation Sass vers styles.css
dart-sass $MDSRV/web/styles.scss >> $MDSRV/web/styles.css &

# launch md-server
/bin/sleep 1 && dart $MDSRV/bin/mdsrv.dart -d "$1" &

# open in browser
/bin/sleep 2 && /usr/bin/open -a "/Applications/Google Chrome.app" "http://0.0.0.0:8765"
