Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Video Panner 3000 - UV Test Runner" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Running with UV virtual environment..." -ForegroundColor Green

# Activate the virtual environment properly to ensure all environment variables are loaded
Write-Host "Activating virtual environment..." -ForegroundColor Yellow
& .\.venv\Scripts\Activate.ps1

Write-Host "Running video panner..." -ForegroundColor Green
python video_panner.py --config test-overlay.json --verbose --check-first-frame

# Deactivate the virtual environment
deactivate

Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Test completed" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""
