#!/usr/bin/env bash
# =============================================================================
# Arkchive — macOS / Linux Setup Script
# Run from the arkchive repo root:
#   bash scripts/install.sh
# =============================================================================

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

step()    { echo -e "\n${CYAN}>> $1${NC}"; }
success() { echo -e "   ${GREEN}OK${NC}  $1"; }
warn()    { echo -e "   ${YELLOW}WARN${NC}  $1"; }
error()   { echo -e "${RED}ERROR: $1${NC}"; exit 1; }

# -----------------------------------------------------------------------------
# 1. Check Python
# -----------------------------------------------------------------------------
step "Checking Python..."
if command -v python3 &>/dev/null; then
    success "$(python3 --version)"
    PYTHON=python3
elif command -v python &>/dev/null; then
    success "$(python --version)"
    PYTHON=python
else
    error "Python not found. Install it from https://python.org and re-run."
fi

# -----------------------------------------------------------------------------
# 2. Check Git
# -----------------------------------------------------------------------------
step "Checking Git..."
command -v git &>/dev/null || error "Git not found. Install it and re-run."
success "$(git --version)"

# -----------------------------------------------------------------------------
# 3. Install Python dependencies
# -----------------------------------------------------------------------------
step "Installing Python dependencies..."
$PYTHON -m pip install -r requirements.txt
success "Dependencies installed."

# -----------------------------------------------------------------------------
# 4. Clone gmail-to-sqlite
# -----------------------------------------------------------------------------
step "Setting up gmail-to-sqlite..."
DEFAULT_SYNC_PATH="$HOME/gmail-to-sqlite"
read -rp "   Where should gmail-to-sqlite be cloned? [default: $DEFAULT_SYNC_PATH]: " SYNC_PATH
SYNC_PATH="${SYNC_PATH:-$DEFAULT_SYNC_PATH}"

if [[ -f "$SYNC_PATH/main.py" ]]; then
    warn "gmail-to-sqlite already exists at $SYNC_PATH, skipping clone."
else
    git clone https://github.com/jtvcodes/gmail-to-sqlite.git "$SYNC_PATH"
    success "Cloned to $SYNC_PATH"
fi

# -----------------------------------------------------------------------------
# 5. Install gmail-to-sqlite dependencies
# -----------------------------------------------------------------------------
step "Installing gmail-to-sqlite dependencies..."
if [[ -f "$SYNC_PATH/requirements.txt" ]]; then
    $PYTHON -m pip install -r "$SYNC_PATH/requirements.txt"
    success "gmail-to-sqlite dependencies installed."
else
    warn "No requirements.txt found in gmail-to-sqlite — skipping."
fi

# -----------------------------------------------------------------------------
# 6. Create .env
# -----------------------------------------------------------------------------
step "Creating .env file..."
if [[ -f ".env" ]]; then
    warn ".env already exists — skipping. Edit it manually if needed."
else
    cat > .env <<EOF
# Path to the gmail-to-sqlite main.py entry point
GMAIL_SYNC_MAIN=$SYNC_PATH/main.py
EOF
    success ".env created with GMAIL_SYNC_MAIN=$SYNC_PATH/main.py"
fi

# -----------------------------------------------------------------------------
# 7. Create .data directory
# -----------------------------------------------------------------------------
step "Creating .data directory..."
if [[ ! -d ".data" ]]; then
    mkdir .data
    success ".data directory created."
else
    warn ".data already exists — skipping."
fi

# -----------------------------------------------------------------------------
# credentials.json reminder
# -----------------------------------------------------------------------------
step "Gmail credentials"
if [[ ! -f "$SYNC_PATH/credentials.json" ]]; then
    warn "No credentials.json found in $SYNC_PATH."
    echo -e "   To enable syncing, place your Google OAuth credentials.json in:"
    echo -e "   ${YELLOW}$SYNC_PATH/credentials.json${NC}"
    echo -e "   See: https://github.com/jtvcodes/gmail-to-sqlite for setup instructions."
else
    success "credentials.json found."
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}  Arkchive is ready!${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
echo "  Start the server:"
echo -e "    ${CYAN}$PYTHON server.py${NC}"
echo ""
echo "  Then open: http://localhost:8001"
echo ""
