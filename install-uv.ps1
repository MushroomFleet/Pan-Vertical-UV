Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Video Panner 3000 - UV Setup Script" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Check if UV is installed
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "UV not found. Installing UV..." -ForegroundColor Yellow
    try {
        Invoke-RestMethod -Uri https://astral.sh/uv/install.ps1 | Invoke-Expression
    }
    catch {
        Write-Host "Failed to install UV. Please install manually." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Creating Python virtual environment with UV..." -ForegroundColor Green

# Check if environment already exists and might be corrupted
if (Test-Path ".venv") {
    Write-Host "Virtual environment already exists. It may be corrupted if you encountered errors before." -ForegroundColor Yellow
    $recreate = Read-Host "Do you want to remove and recreate it? (y/n)"
    if ($recreate -eq "y") {
        Write-Host "Removing existing virtual environment..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force .venv
        Write-Host "Creating new virtual environment..." -ForegroundColor Green
        uv venv
    } else {
        Write-Host "Using existing virtual environment." -ForegroundColor Green
    }
} else {
    uv venv
}
Write-Host ""

Write-Host "Setting up CUDA path..." -ForegroundColor Green
# Check for CUDA installation
$cudaBasePath = "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA"
if (Test-Path $cudaBasePath) {
    Write-Host "CUDA toolkit found!" -ForegroundColor Green
    
    # Find latest CUDA version
    $cudaVersions = Get-ChildItem -Path $cudaBasePath -Directory | Sort-Object -Property Name -Descending
    if ($cudaVersions.Count -gt 0) {
        $latestCuda = $cudaVersions[0].Name
        Write-Host "Found CUDA version: $latestCuda" -ForegroundColor Green
        
        $cudaPath = Join-Path $cudaBasePath $latestCuda
        
        # Create PowerShell script in venv to set CUDA variables on activation
        $cudaSetupScript = @"
# CUDA environment setup
`$env:CUDA_PATH = "$cudaPath"
`$env:OPENCV_CUDA_PATH = `$env:CUDA_PATH
`$env:CUDA_HOME = `$env:CUDA_PATH
`$env:OPENCV_CUDA_TOOLKIT_ROOT_DIR = `$env:CUDA_PATH
`$env:OPENCV_CUDA_LIB_PATH = Join-Path `$env:CUDA_PATH "lib\x64"
`$env:OPENCV_CUDA_BIN_PATH = Join-Path `$env:CUDA_PATH "bin"
`$env:OPENCV_CUDA_INCLUDE_PATH = Join-Path `$env:CUDA_PATH "include"
`$env:PATH = Join-Path `$env:CUDA_PATH "bin" + [System.IO.Path]::PathSeparator + `$env:PATH
Write-Host "CUDA environment variables set for GPU acceleration." -ForegroundColor Green
"@
        
        $cudaSetupPath = ".venv\Scripts\cuda_setup.ps1"
        $cudaSetupScript | Out-File -FilePath $cudaSetupPath -Encoding utf8
        
        # Modify Activate.ps1 to call our cuda_setup.ps1
        $activatePath = ".venv\Scripts\Activate.ps1"
        $activateContent = Get-Content $activatePath -Raw
        $updatedContent = $activateContent.TrimEnd() + "`n`n# Initialize CUDA environment variables`n. `"`$PSScriptRoot\cuda_setup.ps1`"`n"
        $updatedContent | Out-File -FilePath $activatePath -Encoding utf8
        
        Write-Host "CUDA environment variables will be set when the virtual environment is activated." -ForegroundColor Green
    }
} else {
    Write-Host "CUDA toolkit not found. GPU acceleration will not be available." -ForegroundColor Yellow
    Write-Host "If you have CUDA installed in a non-standard location, please set CUDA_PATH manually." -ForegroundColor Yellow
}
Write-Host ""

Write-Host "Installing required packages..." -ForegroundColor Green
uv pip sync requirements.txt
Write-Host ""

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "UV virtual environment setup complete!" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To use the video panner, activate the environment with:" -ForegroundColor Yellow
Write-Host "  .venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host ""
Write-Host "To test the video panner, run:" -ForegroundColor Yellow
Write-Host "  .\start-uv.ps1" -ForegroundColor White
Write-Host ""
Write-Host "For CUDA GPU acceleration setup, please refer to CUDA_SETUP.md" -ForegroundColor Cyan
Write-Host ""
