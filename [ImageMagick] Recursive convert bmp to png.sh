#!/bin/bash
find . -type f -iname "*.bmp" -exec mogrify -format png '{}' +