(for /f "delims=" %%A in ('dir /b /a-d *.mp4') do @echo file '%%A') > "list.txt"
ffmpeg -safe 0 -f concat -i list.txt -c:v libx265 -preset veryslow -c:a copy output_h265_veryslow.mp4