#!/bin/bash
find . -name '*.png' -type f -exec bash -c 'cwebp -m 6 -q 80 -af -pass 10 -pre 7 -alpha_filter best -sharp_yuv -mt -quiet "$0" -o "${0%.png}.webp"' {} \;