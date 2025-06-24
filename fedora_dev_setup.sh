#!/bin/bash

# =============================================================================
# Fedora Linux Developer Environment Setup Script
# =============================================================================

set -e

echo "🚀 Setting up Fedora Linux for Senior Development..."

# =============================================================================
# SYSTEM UPDATE & ESSENTIAL PACKAGES
# =============================================================================

echo "📦 Updating system and installing essential packages..."
sudo dnf update -y

# Essential development tools
sudo dnf install -y \
    git vim neovim zsh curl wget htop tree unzip zip \
    gcc gcc-c++ make cmake python3-pip nodejs npm \
    golang rust cargo docker podman docker-compose \
    kubernetes-cli helm terraform

# Modern CLI replacements
echo "🔧 Installing modern CLI tools..."
sudo dnf install -y bat exa fd-find ripgrep fzf starship procs dust duf

# Additional useful tools
sudo dnf install -y \
    tmux screen alacritty kitty \
    firefox thunderbird \
    gimp vlc \
    qemu-kvm libvirt virt-manager \
    fail2ban ufw \
    gnome-tweaks gnome-extensions-app

# =============================================================================
# REPOSITORIES AND EXTERNAL SOURCES
# =============================================================================

echo "📚 Adding external repositories..."

# RPM Fusion for multimedia
sudo dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Media codecs
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} \
    gstreamer1-plugin-openh264 gstreamer1-libav \
    --exclude=gstreamer1-plugins-bad-free-devel

# VS Code repository
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install -y code

# =============================================================================
# FLATPAK SETUP
# =============================================================================

echo "📱 Setting up Flatpak applications..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install useful Flatpak apps
flatpak install -y flathub \
    com.slack.Slack \
    us.zoom.Zoom \
    com.discordapp.Discord \
    org.signal.Signal \
    org.obsidian.Obsidian \
    com.getpostman.Postman \
    org.keepassxc.KeePassXC

# =============================================================================
# ZSH SETUP
# =============================================================================

echo "🐚 Setting up Zsh and Oh My Zsh..."

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k theme
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# Install useful plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
fi

# =============================================================================
# DEVELOPMENT TOOLS SETUP
# =============================================================================

echo "⚙️  Setting up development tools..."

# NVM (Node Version Manager)
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
fi

# Pyenv (Python Version Manager)
if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
fi

# SDKMAN (Java Version Manager)
if [ ! -d "$HOME/.sdkman" ]; then
    curl -s "https://get.sdkman.io" | bash
fi

# Rust
if [ ! -d "$HOME/.cargo" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# =============================================================================
# FONTS INSTALLATION
# =============================================================================

echo "🔤 Installing developer fonts..."
sudo dnf install -y \
    fira-code-fonts \
    jetbrains-mono-fonts \
    source-code-pro-fonts \
    google-noto-fonts \
    google-noto-emoji-fonts

# =============================================================================
# DOCKER SETUP
# =============================================================================

echo "🐳 Setting up Docker..."
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# =============================================================================
# MODERN CLI TOOLS (Additional)
# =============================================================================

echo "🔨 Installing additional modern CLI tools..."

# Zoxide (better cd)
if ! command -v zoxide &> /dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Bottom (btop alternative)
if ! command -v btop &> /dev/null; then
    sudo dnf install -y btop
fi

# McFly (better history search)
if ! command -v mcfly &> /dev/null; then
    curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly
fi

# =============================================================================
# GIT CONFIGURATION
# =============================================================================

echo "🔧 Git configuration prompts..."
read -p "Enter your Git username: " git_username
read -p "Enter your Git email: " git_email

git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global core.editor nvim
git config --global pull.rebase true
git config --global core.autocrlf input

# Generate SSH key if it doesn't exist
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "🔑 Generating SSH key..."
    ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N ""
    echo "Your SSH public key:"
    cat "$HOME/.ssh/id_ed25519.pub"
    echo "Add this to your GitHub/GitLab account"
fi

# =============================================================================
# FIREWALL CONFIGURATION
# =============================================================================

echo "🔥 Configuring firewall for development..."
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=3001/tcp
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload

# =============================================================================
# DIRECTORIES SETUP
# =============================================================================

echo "📁 Creating development directories..."
mkdir -p ~/Development/{personal,work,opensource,learning}
mkdir -p ~/Development/scripts
mkdir -p ~/.local/bin

# =============================================================================
# FINAL SETUP
# =============================================================================

echo "✅ Installation complete!"
echo ""
echo "🔄 Next steps:"
echo "1. Logout and login again (or restart) to apply all changes"
echo "2. Copy the .zshrc content to ~/.zshrc"
echo "3. Run 'p10k configure' to set up your prompt"
echo "4. Add your SSH key to GitHub/GitLab"
echo "5. Install any additional IDEs (JetBrains Toolbox, etc.)"
echo ""
echo "📚 Useful commands after restart:"
echo "- 'help-dev' for development shortcuts"
echo "- 'p10k configure' for prompt customization"
echo "- 'nvm install node' for latest Node.js"
echo "- 'sdk install java' for Java versions"
echo ""
echo "Happy coding! 🚀"