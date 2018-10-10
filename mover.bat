@echo off
setlocal enabledelayedexpansion

set SOURCE_DIR=C:\shared\135_0308

set TARGET_DIR=C:\

for %%f in ("%SOURCE_DIR%\*") do (
	echo %%f
	for /f "usebackq delims=" %%a in (`ruby getExifTime.rb %%f`) do set EXIFDATE=%%a
	echo !EXIFDATE!
	echo move /-Y %%f %TARGET_DIR%!EXIFDATE!
	pause
rem	exit /b
)
