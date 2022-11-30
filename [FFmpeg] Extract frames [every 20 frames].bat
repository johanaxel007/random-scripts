for %%A in ("*.mp4" *.mkv) do (
	if not exist "frames" mkdir "frames"
	ffmpeg -i "%%A" -vf "select=not(mod(n\,20))" -fps_mode vfr -q:v 2 "frames\%%~nA_out-%%06d.jpg"
)