@echo off
rem Click to fast start: opens MATLAB, then the window of the arm with a short demo.
rem MATLAB itself can take a minute to start.

set "ML=matlab"
where matlab >nul 2>nul
if errorlevel 1 (
    set "ML="
    for /d %%v in ("%ProgramFiles%\MATLAB\R*") do if exist "%%v\bin\matlab.exe" set "ML=%%v\bin\matlab.exe"
)
if not defined ML (
    echo MATLAB was not found on this computer.
    echo Open MATLAB, go to this folder and run click_to_fast_start.m
    pause
    exit /b 1
)

echo Starting MATLAB, the window of the arm opens after it...
start "" "%ML%" -sd "%~dp0." -r "click_to_fast_start"
