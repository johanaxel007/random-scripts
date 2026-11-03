SET MyHandle=C:\tools\SysinternalsSuite\handle64.exe
FOR /F "tokens=3,6 delims=: " %%I IN ('%MyHandle% -p Mp3tag.exe SingleInstance_MMF_Mp3tag -nobanner') DO %MyHandle% -c %%J -y -p %%I -nobanner
PAUSE