(for /f "delims=" %%A in ('dir /b /a-d *.mp4') do @echo file '%%A') > "list.txt"
ffmpeg -safe 0 -f concat -i list.txt -pix_fmt yuv420p10le -c:v libx265 -preset veryslow -c:a copy output_[h265_veryslow_10bit].mp4