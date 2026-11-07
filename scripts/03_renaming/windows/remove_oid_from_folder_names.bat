@echo off
:: This script renames folders like "7_1_Shah Sadar Din" → "Shah Sadar Din"
:: and also handles "7_1.Shah Sadar Din" → "Shah Sadar Din"

for /d %%a in (*) do (
    for /f "tokens=3,* delims=_." %%b in ("%%a") do (
        set "newname=%%b %%c"
        setlocal enabledelayedexpansion
        ren "%%a" "!newname!"
        endlocal
    )
)

echo Rename completed.
pause
