(for /f "delims=" %%A in ('dir /b /a-d *.mp4') do @echo file '%%A') > "list.txt"
ffmpeg -safe 0 -f concat -i list.txt -c:v libx265 -preset medium -c:a copy output_[h265_medium].mp4