# =============================================================================
# Arkchive — Windows Setup Script (PowerShell)
# Run from the arkchive repo root:
#   powershell -ExecutionPolicy Bypass -File scripts/install.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

function Write-Step($msg) {
    Write-Host "`n>> $msg" -ForegroundColor Cyan
}

function Write-Success($msg) {
    Write-Host "   OK  $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
    Write-Host "   WARN  $msg" -ForegroundColor Yellow
}

# -----------------------------------------------------------------------------
# 1. Check Python
# -----------------------------------------------------------------------------
Write-Step "Checking Python..."
try {
    $pyVersion = python --version 2>&1
    Write-Success $pyVersion
} catch {
    Write-Host "ERROR: Python not found. Install it from https://python.org and re-run." -ForegroundColor Red
    exit 1
}

# -----------------------------------------------------------------------------
# 2. Check Git
# -----------------------------------------------------------------------------
Write-Step "Checking Git..."
try {
    $gitVersion = git --version 2>&1
    Write-Success $gitVersion
} catch {
    Write-Host "ERROR: Git not found. Install it from https://git-scm.com and re-run." -ForegroundColor Red
    exit 1
}

# -----------------------------------------------------------------------------
# 3. Install Python dependencies
# -----------------------------------------------------------------------------
Write-Step "Installing Python dependencies..."
python -m pip install -r requirements.txt
Write-Success "Dependencies installed."

# -----------------------------------------------------------------------------
# 4. Clone gmail-to-sqlite
# -----------------------------------------------------------------------------
Write-Step "Setting up gmail-to-sqlite..."

$defaultSyncPath = "$env:USERPROFILE\gmail-to-sqlite"
$syncInput = Read-Host "   Where should gmail-to-sqlite be cloned? [default: $defaultSyncPath]"
if ([string]::IsNullOrWhiteSpace($syncInput)) {
    $syncPath = $defaultSyncPath
} else {
    $syncPath = $syncInput
}

if (Test-Path "$syncPath\main.py") {
    Write-Warn "gmail-to-sqlite already exists at $syncPath, skipping clone."
} else {
    git clone https://github.com/jtvcodes/gmail-to-sqlite.git $syncPath
    Write-Success "Cloned to $syncPath"
}

$mainPy = "$syncPath\main.py"

# -----------------------------------------------------------------------------
# 5. Install gmail-to-sqlite dependencies
# -----------------------------------------------------------------------------
Write-Step "Installing gmail-to-sqlite dependencies..."
if (Test-Path "$syncPath\requirements.txt") {
    python -m pip install -r "$syncPath\requirements.txt"
    Write-Success "gmail-to-sqlite dependencies installed."
} else {
    Write-Warn "No requirements.txt found in gmail-to-sqlite — skipping."
}

# -----------------------------------------------------------------------------
# 6. Create .env
# -----------------------------------------------------------------------------
Write-Step "Creating .env file..."
if (Test-Path ".env") {
    Write-Warn ".env already exists — skipping. Edit it manually if needed."
} else {
    @"
# Path to the gmail-to-sqlite main.py entry point
GMAIL_SYNC_MAIN=$mainPy
"@ | Set-Content .env
    Write-Success ".env created with GMAIL_SYNC_MAIN=$mainPy"
}

# -----------------------------------------------------------------------------
# 7. Create .data directory
# -----------------------------------------------------------------------------
Write-Step "Creating .data directory..."
if (-not (Test-Path ".data")) {
    New-Item -ItemType Directory -Path ".data" | Out-Null
    Write-Success ".data directory created."
} else {
    Write-Warn ".data already exists — skipping."
}

# -----------------------------------------------------------------------------
# 8. credentials.json reminder
# -----------------------------------------------------------------------------
Write-Step "Gmail credentials"
if (-not (Test-Path "$syncPath\credentials.json")) {
    Write-Warn "No credentials.json found in $syncPath."
    Write-Host "   To enable syncing, place your Google OAuth credentials.json in:" -ForegroundColor Yellow
    Write-Host "   $syncPath\credentials.json" -ForegroundColor Yellow
    Write-Host "   See: https://github.com/jtvcodes/gmail-to-sqlite for setup instructions." -ForegroundColor Yellow
} else {
    Write-Success "credentials.json found."
}

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "  Arkchive is ready!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Start the server:" -ForegroundColor White
Write-Host "    python server.py" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Then open: http://localhost:8001" -ForegroundColor White
Write-Host ""
