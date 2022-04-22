#!/bin/sh
USER=deploy
HOST=juliuskoskela.dev
DIR=juliuskoskela.dev/public  # the directory where your web site files should go

hugo && rsync -avz --delete public/ ${USER}@${HOST}:~/${DIR}

exit 0

