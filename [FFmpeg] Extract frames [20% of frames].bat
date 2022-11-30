for %%A in ("*.mp4" *.mkv) do (
	if not exist "frames" mkdir "frames"
	ffmpeg -i "%%A" -r 0.2 -q:v 2 "frames\%%~nA_out-%%06d.jpg"
)