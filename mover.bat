@echo off
setlocal enabledelayedexpansion

set SOURCE_DIR=D:\proj\renamer\canon

set TARGET_DIR=D:\proj\renamer\target

for %%f in ("%SOURCE_DIR%\*") do (
	echo %%f
	for /f "usebackq delims=" %%a in (`ruby getExifTime.rb %%f`) do set EXIFDATE=%%a
	IF NOT EXIST %TARGET_DIR%^\!EXIFDATE! (
rem		echo %TARGET_DIR%^\!EXIFDATE!
		mkdir %TARGET_DIR%^\!EXIFDATE!
	)
	echo !EXIFDATE!
	move /-Y %%f %TARGET_DIR%^\!EXIFDATE!
rem	exit /b
)
