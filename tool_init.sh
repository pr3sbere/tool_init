#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}[*] Starting Setup for Ubuntu/Kali...${NC}"

# 1. Install System Dependencies
echo -e "${BLUE}[*] Updating system and installing base dependencies...${NC}"
sudo apt-get update
sudo apt-get install -y git python3-pip build-essential libssl-dev libffi-dev libbz2-dev libreadline-dev libsqlite3-dev curl

# 2. Install uv if not present
if ! command -v uv &> /dev/null; then
    echo -e "${BLUE}[*] Installing uv...${NC}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Source for the duration of this script only
    source $HOME/.cargo/env
else
    echo -e "${GREEN}[+] uv is already installed.${NC}"
fi

# Ensure paths are set for the current script execution
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# 3. Install Python tools via uv
echo -e "${BLUE}[*] Installing Python tools via uv...${NC}"

PYPI_TOOLS=(
    "impacket" "certipy-ad" "bloodhound-ce-python" "mitm6" 
    "pywerview" "httpie" "ssh-audit" "kerbrute" 
    "bloodyAD" "ldapdomaindump" "pywhisker"
)

GIT_PY_TOOLS=(
    "https://github.com/lgandx/Responder.git"
    "https://github.com/RedTeamPentesting/wspcoerce.git"
    "https://github.com/AutoRecon/AutoRecon.git"
    "https://github.com/cddmp/enum4linux-ng.git"
    "https://github.com/Pennyw0rth/NetExec.git"
)

for tool in "${PYPI_TOOLS[@]}"; do
    echo -e "${BLUE}[+] Installing $tool...${NC}"
    uv tool install "$tool" --force
done

for repo in "${GIT_PY_TOOLS[@]}"; do
    echo -e "${BLUE}[+] Installing tool from $repo...${NC}"
    uv tool install "git+$repo" --force
done

# 4. Setup Git Tools Directory
GIT_DIR="$HOME/git_tools"
mkdir -p "$GIT_DIR"
cd "$GIT_DIR" || exit

echo -e "${BLUE}[*] Cloning repositories into $GIT_DIR (parallel)...${NC}"

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

for repo in "${REPOS[@]}"; do
    git clone "$repo" & 
done

wait

# 5. Create README.md
echo -e "${BLUE}[*] Creating README.md...${NC}"
cat << 'EOF' > README.md
# Tooling Notes

## General Installation Info
- **aquatone**: Installed via release. GitHub: https://github.com/michenriksen/aquatone.git
- **witnessme**: Uses pipx (Note: Also installed via uv tool).
- **PRETENDER**: Installed using (go): git: https://github.com/RedTeamPentesting/pretender.git then 'go build'
- **rusthound**: Installed using (cargo): cargo install rusthound-ce
- **httprobe**: go install github.com/tomnomnom/httprobe@latest
- **EyeWitness**: Use setup.sh inside the directory to install virtual env and dependencies

## Updates
- Update all Python tools: `uv tool upgrade --all`
EOF

# 6. Final Notification and Reload Instructions
echo -e "\n${GREEN}[+] Setup Complete!${NC}"
echo -e "${YELLOW}-----------------------------------------------------------${NC}"
echo -e "${YELLOW}IMPORTANT: You must reload your shell to use the new tools.${NC}"

# Detect shell to give the right command
if [[ $SHELL == *"zsh"* ]]; then
    echo -e "Run the following command now:"
    echo -e "${BLUE}source ~/.zshrc${NC}"
else
    echo -e "Run the following command now:"
    echo -e "${BLUE}source ~/.bashrc${NC}"
fi
echo -e "${YELLOW}-----------------------------------------------------------${NC}"