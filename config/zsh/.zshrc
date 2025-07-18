# =============================================================================

# Developer .zshrc Configuration for Fedora Linux

# =============================================================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then

  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

fi

# =============================================================================

# OH-MY-ZSH CONFIGURATION

# =============================================================================

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"  # or "robbyrussell" for simpler theme

# Oh My Zsh plugins

plugins=(

    git

    docker

    docker-compose

    kubectl

    helm

    terraform

    aws

    gcp

    azure

    nodejs

    npm

    yarn

    python

    pip

    golang

    rust

    cargo

    systemd

    tmux

    zsh-autosuggestions

    zsh-syntax-highlighting

    fzf

    history-substring-search

    colored-man-pages

    command-not-found

    extract

    web-search

)

# Load Oh My Zsh

source $ZSH/oh-my-zsh.sh

# =============================================================================

# ENVIRONMENT VARIABLES

# =============================================================================

export EDITOR='nvim'

export VISUAL='nvim'

export BROWSER='firefox'

export TERMINAL='alacritty'

export PAGER='less'

export MANPAGER='nvim +Man!'

# Development paths

export GOPATH="$HOME/go"

export GOROOT="/usr/local/go"

export CARGO_HOME="$HOME/.cargo"

export RUSTUP_HOME="$HOME/.rustup"

# Path configuration

export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/bin:$PATH"

export PATH="$GOPATH/bin:$PATH"

export PATH="$GOROOT/bin:$PATH"

export PATH="$CARGO_HOME/bin:$PATH"

export PATH="$HOME/.npm-global/bin:$PATH"

# History configuration

export HISTSIZE=50000

export SAVEHIST=50000

export HISTFILE="$HOME/.zsh_history"

setopt HIST_EXPIRE_DUPS_FIRST

setopt HIST_IGNORE_DUPS

setopt HIST_IGNORE_ALL_DUPS

setopt HIST_IGNORE_SPACE

setopt HIST_FIND_NO_DUPS

setopt HIST_SAVE_NO_DUPS

setopt HIST_BEEP

setopt SHARE_HISTORY

setopt APPEND_HISTORY

setopt INC_APPEND_HISTORY

# =============================================================================

# MODERN CLI TOOL ALIASES

# =============================================================================

# Better defaults for common commands

alias ll='exa -la --git --header --group-directories-first'

alias ls='exa --group-directories-first'

alias la='exa -a --group-directories-first'

alias lt='exa --tree --level=2'

alias cat='bat'

alias find='fd'

alias grep='rg'

alias ps='procs'

alias top='btop'

alias htop='btop'

alias du='dust'

alias df='duf'

alias ping='gping'

alias dig='dog'

# File operations

alias cp='cp -i'

alias mv='mv -i'

alias rm='rm -I'

alias mkdir='mkdir -p'

# Navigation

alias ..='cd ..'

alias ...='cd ../..'

alias ....='cd ../../..'

alias .....='cd ../../../..'

alias ~='cd ~'

alias -- -='cd -'

# =============================================================================

# SYSTEM & MONITORING ALIASES

# =============================================================================

alias ports='ss -tuln'

alias listening='ss -tuln | grep LISTEN'

alias processes='ps aux | grep'

alias diskspace='df -h'

alias diskusage='du -sh * | sort -hr'

alias meminfo='free -h'

alias cpuinfo='lscpu'

alias temp='sensors'

alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'

# System services

alias sctl='systemctl'

alias sctlu='systemctl --user'

alias jctl='journalctl'

alias reload-zsh='source ~/.zshrc'

# Package management

alias dnf-update='sudo dnf update && flatpak update'

alias dnf-search='dnf search'

alias dnf-install='sudo dnf install'

alias dnf-remove='sudo dnf remove'

alias dnf-info='dnf info'

alias dnf-clean='sudo dnf clean all'

# =============================================================================

# DEVELOPMENT ALIASES

# =============================================================================

# Git shortcuts

alias g='git'

alias ga='git add'

alias gaa='git add .'

alias gc='git commit'

alias gcm='git commit -m'

alias gca='git commit --amend'

alias gco='git checkout'

alias gcb='git checkout -b'

alias gb='git branch'

alias gbd='git branch -d'

alias gs='git status'

alias gd='git diff'

alias gl='git log --oneline --graph --decorate'

alias gla='git log --oneline --graph --decorate --all'

alias gp='git push'

alias gpu='git push -u origin'

alias gpl='git pull'

alias gf='git fetch'

alias gr='git remote'

alias gst='git stash'

alias gsp='git stash pop'

alias gm='git merge'

alias grb='git rebase'

alias gri='git rebase -i'

alias grs='git reset'

alias grh='git reset --hard'

alias gclean='git clean -fd'

# Docker & Containers

alias d='docker'

alias dc='docker-compose'

alias dcu='docker-compose up'

alias dcd='docker-compose down'

alias dcb='docker-compose build'

alias dps='docker ps'

alias dpa='docker ps -a'

alias di='docker images'

alias drm='docker rm'

alias drmi='docker rmi'

alias dstop='docker stop $(docker ps -q)'

alias dclean='docker system prune -af'

# Podman aliases

alias p='podman'

alias pc='podman-compose'

alias pps='podman ps'

alias ppa='podman ps -a'

alias pi='podman images'

# Kubernetes

alias k='kubectl'

alias kns='kubectl config set-context --current --namespace'

alias kgp='kubectl get pods'

alias kgs='kubectl get services'

alias kgd='kubectl get deployments'

alias kgi='kubectl get ingress'

alias kdp='kubectl describe pod'

alias kds='kubectl describe service'

alias kdd='kubectl describe deployment'

alias klf='kubectl logs -f'

alias kex='kubectl exec -it'

alias kctx='kubectl config current-context'

alias kctxs='kubectl config get-contexts'

# Terraform

alias tf='terraform'

alias tfi='terraform init'

alias tfp='terraform plan'

alias tfa='terraform apply'

alias tfd='terraform destroy'

alias tfv='terraform validate'

alias tff='terraform fmt'

# =============================================================================

# NETWORK & SECURITY

# =============================================================================

alias myip='curl -s ifconfig.me'

alias localip='ip route get 1 | awk "{print \$7}"'

alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'

alias scan-network='nmap -sn 192.168.1.0/24'

alias open-ports='nmap -p- localhost'

alias firewall-status='sudo firewall-cmd --list-all'

# =============================================================================

# USEFUL FUNCTIONS

# =============================================================================

# Create directory and cd into it

mkcd() {

    mkdir -p "$1" && cd "$1"

}

# Extract any archive

extract() {

    if [ -f $1 ] ; then

        case $1 in

            *.tar.bz2)   tar xjf $1     ;;

            *.tar.gz)    tar xzf $1     ;;

            *.bz2)       bunzip2 $1     ;;

            *.rar)       unrar e $1     ;;

            *.gz)        gunzip $1      ;;

            *.tar)       tar xf $1      ;;

            *.tbz2)      tar xjf $1     ;;

            *.tgz)       tar xzf $1     ;;

            *.zip)       unzip $1       ;;

            *.Z)         uncompress $1  ;;

            *.7z)        7z x $1        ;;

            *)     echo "'$1' cannot be extracted via extract()" ;;

        esac

    else

        echo "'$1' is not a valid file"

    fi

}

# Find process by name and kill it

killprocess() {

    ps aux | grep $1 | grep -v grep | awk '{print $2}' | xargs kill -9

}

# Quick backup function

backup() {

    cp "$1"{,.bak}

}

# Find and replace in files

replace() {

    find . -type f -name "*.$3" -exec sed -i "s/$1/$2/g" {} +

}

# Weather function

weather() {

    curl -s "wttr.in/$1"

}

# Port checker

port-check() {

    nc -zv $1 $2

}

# Git functions

gclone() {

    git clone $1 && cd $(basename $1 .git)

}

# Docker functions

docker-stop-all() {

    docker stop $(docker ps -q)

}

docker-clean-all() {

    docker system prune -a --volumes

}

# Kubernetes functions

kube-ctx() {

    kubectl config use-context $1

}

kube-ns() {

    kubectl config set-context --current --namespace=$1

}

# Development server functions

serve() {

    local port=${1:-8000}

    python3 -m http.server $port

}

node-serve() {

    local port=${1:-3000}

    npx http-server -p $port

}

# =============================================================================

# VERSION MANAGERS

# =============================================================================

# NVM (Node Version Manager)

export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Pyenv

export PYENV_ROOT="$HOME/.pyenv"

if [[ -d $PYENV_ROOT/bin ]]; then

    export PATH="$PYENV_ROOT/bin:$PATH"

    eval "$(pyenv init -)"

fi

# SDKMAN (Java Version Manager)

export SDKMAN_DIR="$HOME/.sdkman"

[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Rust

[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# =============================================================================

# MODERN TOOL CONFIGURATIONS

# =============================================================================

# FZF configuration

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'

# Zoxide (better cd)

if command -v zoxide >/dev/null 2>&1; then

    eval "$(zoxide init zsh)"

    alias cd='z'

fi

# Starship prompt (alternative to powerlevel10k)

if command -v starship >/dev/null 2>&1; then

    eval "$(starship init zsh)"

fi

# McFly (better history search)

if command -v mcfly >/dev/null 2>&1; then

    eval "$(mcfly init zsh)"

fi

# =============================================================================

# COMPLETION CONFIGURATIONS

# =============================================================================

# Enable completion caching

zstyle ':completion:*' use-cache on

zstyle ':completion:*' cache-path ~/.zsh/cache

# Case insensitive completion

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Menu selection

zstyle ':completion:*' menu select

# Colors in completion

zstyle ':completion:*' list-colors ''

# Kubernetes completion

if command -v kubectl >/dev/null 2>&1; then

    source <(kubectl completion zsh)

    complete -F __start_kubectl k

fi

# Helm completion

if command -v helm >/dev/null 2>&1; then

    source <(helm completion zsh)

fi

# Docker completion

if command -v docker >/dev/null 2>&1; then

    complete -F _docker d

fi

# =============================================================================

# DEVELOPMENT ENVIRONMENT SETUP

# =============================================================================

# Java environment

export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"

# Node.js global packages without sudo

mkdir -p ~/.npm-global

npm config set prefix '~/.npm-global'

# Python development

export PYTHONDONTWRITEBYTECODE=1

export PYTHONUNBUFFERED=1

# Go development

export GO111MODULE=on

export GOPROXY=https://proxy.golang.org

# =============================================================================

# SECURITY & PRODUCTIVITY

# =============================================================================

# GPG TTY for git signing

export GPG_TTY=$(tty)

# SSH agent

if ! pgrep -u "$USER" ssh-agent > /dev/null; then

    ssh-agent > ~/.ssh-agent-thing

fi

if [[ "$SSH_AGENT_PID" == "" ]]; then

    eval "$(<~/.ssh-agent-thing)"

fi

# =============================================================================

# CUSTOM ALIASES FOR PRODUCTIVITY

# =============================================================================

# Quick edits

alias zshrc='$EDITOR ~/.zshrc'

alias vimrc='$EDITOR ~/.vimrc'

alias nvimrc='$EDITOR ~/.config/nvim/init.vim'

alias hosts='sudo $EDITOR /etc/hosts'

# Quick navigation to common directories

alias dev='cd ~/Development'

alias docs='cd ~/Documents'

alias dl='cd ~/Downloads'

alias desk='cd ~/Desktop'

# Laravel/PHP development

alias artisan='php artisan'

alias composer-install='composer install --no-dev --optimize-autoloader'

alias phpunit='./vendor/bin/phpunit'

# Django development

alias manage='python manage.py'

alias runserver='python manage.py runserver'

alias makemigrations='python manage.py makemigrations'

alias migrate='python manage.py migrate'

# React/Frontend development

alias nr='npm run'

alias ns='npm start'

alias nt='npm test'

alias nb='npm run build'

alias yr='yarn run'

alias ys='yarn start'

alias yt='yarn test'

alias yb='yarn build'

# =============================================================================

# LOAD LOCAL CUSTOMIZATIONS

# =============================================================================

# Load local zshrc if it exists

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Load work-specific configurations

[[ -f ~/.zshrc.work ]] && source ~/.zshrc.work

# =============================================================================

# POWERLEVEL10K CONFIGURATION

# =============================================================================

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================================

# FINAL SETUP

# =============================================================================

# Auto-start tmux if not already in tmux and not in VS Code terminal

if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [ -z "$VSCODE_INJECTION" ]; then

    # Uncomment the next line if you want tmux to auto-start

    # tmux attach-session -t default || tmux new-session -s default

fi

# Welcome message

echo "?? Welcome back, developer! Your environment is ready."

echo "?? Run 'help-dev' for a list of custom commands and shortcuts."

# Help function

help-dev() {

    echo "=== DEVELOPMENT SHORTCUTS ==="

    echo "Modern CLI: ll, cat, find, grep, ps, top, du, df"

    echo "Git: g, ga, gc, gs, gd, gl, gp, gpl, etc."

    echo "Docker: d, dc, dps, di, dstop, dclean"

    echo "K8s: k, kns, kgp, kgs, klf, kex"

    echo "Navigation: .., ..., mkcd, z"

    echo "System: ports, processes, diskspace, meminfo"

    echo "Functions: extract, weather, backup, serve"

    echo "=== Edit configs: zshrc, vimrc, nvimrc ==="

}

# Auto-suggest configuration

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,underline"

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Syntax highlighting configuration

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

# Load syntax highlighting (should be at the end)

[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

