#! /bin/sh
fswatch -0 -o -e 'out/' . | xargs -0 -n 1 -I {} sh -c 'make all; echo "\a"'
