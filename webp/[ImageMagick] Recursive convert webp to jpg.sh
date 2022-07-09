#!/bin/bash
find . -name '*.webp' -type f -exec bash -c 'magick "$0" "${0%.webp}.jpg"' {} \;