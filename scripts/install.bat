@echo off
:: =============================================================================
:: Arkchive — Windows Setup Script (CMD)
:: Run from the arkchive repo root:
::   scripts\install.bat
:: =============================================================================

setlocal EnableDelayedExpansion

echo.
echo  =============================================
echo   Arkchive — Windows Installer
echo  =============================================
echo.

:: -----------------------------------------------------------------------------
:: 1. Check Python
:: -----------------------------------------------------------------------------
echo [1/7] Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo  ERROR: Python not found. Install it from https://python.org and re-run.
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('python --version 2^>^&1') do echo   OK  %%i

:: -----------------------------------------------------------------------------
:: 2. Check Git
:: -----------------------------------------------------------------------------
echo.
echo [2/7] Checking Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo  ERROR: Git not found. Install it from https://git-scm.com and re-run.
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('git --version 2^>^&1') do echo   OK  %%i

:: -----------------------------------------------------------------------------
:: 3. Install Python dependencies
:: -----------------------------------------------------------------------------
echo.
echo [3/7] Installing Python dependencies...
python -m pip install -r requirements.txt
if errorlevel 1 (
    echo  ERROR: pip install failed.
    pause
    exit /b 1
)
echo   OK  Dependencies installed.

:: -----------------------------------------------------------------------------
:: 4. Clone gmail-to-sqlite
:: -----------------------------------------------------------------------------
echo.
echo [4/7] Setting up gmail-to-sqlite...
set "DEFAULT_SYNC_PATH=%USERPROFILE%\gmail-to-sqlite"
set /p SYNC_PATH="   Clone path [default: %DEFAULT_SYNC_PATH%]: "
if "!SYNC_PATH!"=="" set "SYNC_PATH=%DEFAULT_SYNC_PATH%"

if exist "!SYNC_PATH!\main.py" (
    echo   WARN  gmail-to-sqlite already exists at !SYNC_PATH!, skipping clone.
) else (
    git clone https://github.com/jtvcodes/gmail-to-sqlite.git "!SYNC_PATH!"
    if errorlevel 1 (
        echo  ERROR: git clone failed.
        pause
        exit /b 1
    )
    echo   OK  Cloned to !SYNC_PATH!
)

:: -----------------------------------------------------------------------------
:: 5. Install gmail-to-sqlite dependencies
:: -----------------------------------------------------------------------------
echo.
echo [5/7] Installing gmail-to-sqlite dependencies...
if exist "!SYNC_PATH!\requirements.txt" (
    python -m pip install -r "!SYNC_PATH!\requirements.txt"
    echo   OK  gmail-to-sqlite dependencies installed.
) else (
    echo   WARN  No requirements.txt found in gmail-to-sqlite — skipping.
)

:: -----------------------------------------------------------------------------
:: 6. Create .env
:: -----------------------------------------------------------------------------
echo.
echo [6/7] Creating .env file...
if exist ".env" (
    echo   WARN  .env already exists — skipping. Edit it manually if needed.
) else (
    echo GMAIL_SYNC_MAIN=!SYNC_PATH!\main.py> .env
    echo   OK  .env created.
)

:: -----------------------------------------------------------------------------
:: 7. Create .data directory
:: -----------------------------------------------------------------------------
echo.
echo [7/7] Creating .data directory...
if not exist ".data" (
    mkdir .data
    echo   OK  .data directory created.
) else (
    echo   WARN  .data already exists — skipping.
)

:: -----------------------------------------------------------------------------
:: credentials.json reminder
:: -----------------------------------------------------------------------------
echo.
if not exist "!SYNC_PATH!\credentials.json" (
    echo  WARN: No credentials.json found in !SYNC_PATH!
    echo  To enable syncing, place your Google OAuth credentials.json there.
    echo  See: https://github.com/jtvcodes/gmail-to-sqlite
)

:: -----------------------------------------------------------------------------
:: Done
:: -----------------------------------------------------------------------------
echo.
echo  =============================================
echo   Arkchive is ready!
echo  =============================================
echo.
echo   Start the server:
echo     python server.py
echo.
echo   Then open: http://localhost:8001
echo.
pause
