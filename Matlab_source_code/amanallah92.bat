C:
IF NOT EXIST C:\Program Files\FlightGear\NUL GOTO START

cd C:\Program Files\FlightGear

SET FG_ROOT=C:\Program Files\FlightGear\data
.\\bin\win64\fgfs --aircraft=dhc2F --fdm=network,localhost,5501,5502,5503 --fog-fastest --disable-clouds --start-date-lat=2004:06:01:09:00:00 --disable-sound --in-air --enable-freeze --airport=KSFO --runway=10L --altitude=7224 --heading=113 --offset-distance=4.72 --offset-azimuth=0

:EXIT
echo msgbox "C:\Program Files\FlightGear is not found! Please install Flight Gear Simulator First !" > %tmp%\tmp.vbs
wscript %tmp%\tmp.vbs
del %tmp%\tmp.vbs