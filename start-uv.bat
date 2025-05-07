@echo off
echo ===================================
echo Video Panner 3000 - UV Test Runner
echo ===================================
echo.

echo Running with UV virtual environment...

echo Activating virtual environment...
call .venv\Scripts\activate.bat

echo Running video panner...
python video_panner.py --config test-overlay.json --verbose --check-first-frame

echo Deactivating virtual environment...
call deactivate

echo.
echo ===================================
echo Test completed
echo ===================================
echo.
pause
