#!/bin/bash
DIR="/tmp/"
# rm -rf $DIR*
find "${DIR}" -xdev -mindepth 1 -printf "%d\t%y\t%p\0" | sort -z -r -n | cut -z -f3- | xargs -0 -r -- rm -d --