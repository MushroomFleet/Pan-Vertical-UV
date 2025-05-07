@echo off
echo ===================================
echo Video Panner 3000 - UV Setup Script
echo ===================================
echo.

REM Check if UV is installed, install if not
where uv >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo UV not found. Installing UV...
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install UV. Please install manually.
        exit /b 1
    )
)

echo Creating Python virtual environment with UV...

REM Check if environment already exists and might be corrupted
if exist ".venv" (
    echo Virtual environment already exists. It may be corrupted if you encountered errors before.
    set /p RECREATE="Do you want to remove and recreate it? (y/n): "
    if /i "%RECREATE%"=="y" (
        echo Removing existing virtual environment...
        rmdir /s /q .venv
        echo Creating new virtual environment...
        uv venv
    ) else (
        echo Using existing virtual environment.
    )
) else (
    uv venv
)
echo.

echo Setting up CUDA path...
REM Check for CUDA installation
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA" (
    echo CUDA toolkit found!
    for /f "delims=" %%i in ('dir "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA" /b /ad-h /o-n') do (
        set LATEST_CUDA=%%i
        goto :cuda_found
    )
    
    :cuda_found
    echo Found CUDA version: %LATEST_CUDA%
    
    REM Create batch file in venv to set CUDA variables on activation
    echo @echo off > .venv\Scripts\cuda_setup.bat
    echo set CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\%LATEST_CUDA% >> .venv\Scripts\cuda_setup.bat
    echo set OPENCV_CUDA_PATH=%%CUDA_PATH%% >> .venv\Scripts\cuda_setup.bat
    echo set CUDA_HOME=%%CUDA_PATH%% >> .venv\Scripts\cuda_setup.bat
    echo set OPENCV_CUDA_TOOLKIT_ROOT_DIR=%%CUDA_PATH%% >> .venv\Scripts\cuda_setup.bat
    echo set OPENCV_CUDA_LIB_PATH=%%CUDA_PATH%%\lib\x64 >> .venv\Scripts\cuda_setup.bat
    echo set OPENCV_CUDA_BIN_PATH=%%CUDA_PATH%%\bin >> .venv\Scripts\cuda_setup.bat
    echo set OPENCV_CUDA_INCLUDE_PATH=%%CUDA_PATH%%\include >> .venv\Scripts\cuda_setup.bat
    echo set PATH=%%CUDA_PATH%%\bin;%%PATH%% >> .venv\Scripts\cuda_setup.bat
    
    REM Modify activate.bat to call our cuda_setup.bat
    echo call "%%~dp0cuda_setup.bat" >> .venv\Scripts\activate.bat
    
    echo CUDA environment variables will be set when the virtual environment is activated.
) else (
    echo CUDA toolkit not found. GPU acceleration will not be available.
    echo If you have CUDA installed in a non-standard location, please set CUDA_PATH manually.
)
echo.

echo Installing required packages...
uv pip sync requirements.txt
echo.

echo ===================================
echo UV virtual environment setup complete!
echo ===================================
echo.
echo To use the video panner, activate the environment with:
echo   .venv\Scripts\activate
echo.
echo To test the video panner, run:
echo   start-uv.bat
echo.
echo For CUDA GPU acceleration setup, please refer to CUDA_SETUP.md
echo.
pause
