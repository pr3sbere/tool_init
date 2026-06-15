#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}[*] Starting Setup for Ubuntu/Kali...${NC}"

# 1. Install System Dependencies
echo -e "${BLUE}[*] Updating system and installing base dependencies...${NC}"
sudo apt update && sudo apt install -y \
    git \
    python3-pip \
    build-essential \
    libssl-dev \
    libffi-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl

# 2. Install uv if not present
if ! command -v uv &> /dev/null; then
    echo -e "${BLUE}[*] Installing uv...${NC}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Source for current session
    source $HOME/.cargo/env
else
    echo -e "${GREEN}[+] uv is already installed.${NC}"
fi

# Ensure ~/.local/bin is in PATH (standard for uv)
export PATH="$HOME/.local/bin:$PATH"

# 3. Install Python tools via uv (Fast & Isolated)
echo -e "${BLUE}[*] Installing Python tools via uv...${NC}"

# Standard PyPI packages
PYPI_TOOLS=(
    "impacket" "certipy-ad" "bloodhound-ce-python" "mitm6" 
    "pywerview" "httpie" "ssh-audit" "kerbrute" 
    "bloodyAD" "ldapdomaindump" "pywhisker"
)

# Git-based Python tools (installed as tools)
GIT_PY_TOOLS=(
    "https://github.com/lgandx/Responder.git"
    "https://github.com/RedTeamPentesting/wspcoerce.git"
    "https://github.com/AutoRecon/AutoRecon.git"
    "https://github.com/cddmp/enum4linux-ng.git"
    "https://github.com/Pennyw0rth/NetExec.git"
)

# Install PyPI tools
for tool in "${PYPI_TOOLS[@]}"; do
    echo -e "${BLUE}Installing $tool...${NC}"
    uv tool install "$tool" --force
done

# Install Git-based tools via uv
for repo in "${GIT_PY_TOOLS[@]}"; do
    echo -e "${BLUE}Installing tool from $repo...${NC}"
    uv tool install "git+$repo" --force
done

# 4. Setup Git Tools Directory and Clone Repos
GIT_DIR="$HOME/git_tools"
mkdir -p "$GIT_DIR"
cd "$GIT_DIR" || exit

echo -e "${BLUE}[*] Cloning repositories into $GIT_DIR (in parallel)...${NC}"

REPOS=(
    "https://github.com/dirkjanm/krbrelayx.git"
    "https://github.com/capture0x/AdStrike.git"
    "https://github.com/lefayjey/linWinPwn.git"
    "https://github.com/BenZamir/MITM6-Kerberos-CNAME-Abuse.git"
    "https://github.com/lgandx/PCredz.git"
    "https://github.com/secorizon/MSFinger.git"
    "https://github.com/cddmp/enum4linux-ng.git"
    "https://github.com/RedSiege/EyeWitness.git"
    "https://github.com/nullt3r/udpx.git"
    "https://github.com/urbanadventurer/username-anarchy.git"
    "https://github.com/thewhiteh4t/FinalRecon.git"
    "https://github.com/byt3bl33d3r/WitnessMe.git"
    "https://github.com/jasonxtn/Argus.git"
    "https://github.com/RedTeamPentesting/pretender.git"
    "https://github.com/tomnomnom/httprobe.git"
)

# Clone repos in parallel to save time
for repo in "${REPOS[@]}"; do
    git clone "$repo" & 
done

# Wait for all background clones to finish before creating README
wait

# 5. Create README.md
echo -e "${BLUE}[*] Creating README.md...${NC}"
cat << EOF > README.md
# Tooling Notes

## General Installation Info
- **aquatone**: Installed via release. GitHub: [https://github.com/michenriksen/aquatone.git](https://github.com/michenriksen/aquatone.git)
- **witnessme**: Uses pipx (Note: Also installed via uv tool in this script).
- **PRETENDER**: Installed using (go): git [https://github.com/RedTeamPentesting/pretender.git](https://github.com/RedTeamPentesting/pretender.git) then \`go build\`.
- **rusthound**: Installed using (cargo): \`cargo install rusthound-ce\`.
- **httprobe**: \`go install github.com/tomnomnom/httprobe@latest\`.
- **EyeWitness**: Use \`setup.sh\` inside the directory to install virtual env and dependencies.

## Management
- Most Python tools were installed using **uv** for speed and isolation.
- To update all uv-installed tools: \`uv tool upgrade --all\`
EOF

echo -e "${GREEN}[+] Setup Complete!${NC}"
echo -e "${GREEN}[+] Python tools are available in your terminal.${NC}"
echo -e "${GREEN}[+] Git repositories are in: $GIT_DIR${NC}"