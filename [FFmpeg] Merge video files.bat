(for /f "delims=" %%A in ('dir /b /a-d *.mp4,*.mkv,*.mov,*.flv,*.avi,*.wmv,*.mpg,*.mpeg,*.m4v') do @echo file '%%A') > "list.txt"
ffmpeg -safe 0 -f concat -i list.txt -c copy output.mp4