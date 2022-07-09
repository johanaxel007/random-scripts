#!/bin/bash
find . -name '*.jpg' -type f -exec bash -c 'cwebp -q 85 "$0" -o "${0%.jpg}.webp"' {} \;