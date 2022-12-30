#!/bin/bash
find . -name '*.png' -type f -exec bash -c 'cwebp -z 9 -af -pass 10 -alpha_filter best -sharp_yuv -mt -quiet "$0" -o "${0%.png}.webp"' {} \;