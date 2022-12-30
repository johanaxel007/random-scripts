#!/bin/bash
find . -name '*.jpg' -type f -exec bash -c 'cwebp -m 6 -q 85 -af -pass 10 -pre 7 -alpha_filter best -sharp_yuv -mt -quiet "$0" -o "${0%.jpg}.webp"' {} \;