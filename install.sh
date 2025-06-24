#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

echo "Linking configs…"
for src in $DOTFILES_DIR/config/*; do
  dest="$HOME/.${src##*/}"
  mkdir -p "$(dirname "$dest")"
  ln -sf "$src" "$dest"
done

echo "Installing system packages…"
sudo dnf install -y git zsh neovim stow curl wget jq yq fzf ripgrep tmux starship kubectl gh

echo "Installing Go…"
GO_VERSION=1.22.3
curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
echo 'export GOPATH=$HOME/go' >> ~/.zshrc

/usr/local/go/bin/go install golang.org/x/tools/cmd/goimports@latest
/usr/local/go/bin/go install github.com/go-delve/delve/cmd/dlv@latest
/usr/local/go/bin/go install github.com/ramya-rao-a/go-outline@latest

echo "Installing Kubernetes tools…"
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

curl -Lo kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/latest/download/kustomize_v5.4.1_linux_amd64.tar.gz
tar -xvzf kustomize.tar.gz
chmod +x kustomize && sudo mv kustomize /usr/local/bin/

curl -Lo k9s.tar.gz https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
tar -xzf k9s.tar.gz && chmod +x k9s && sudo mv k9s /usr/local/bin

echo "Switching default shell to zsh…"
chsh -s "$(which zsh)" || echo "Run manually: chsh -s $(which zsh)"

echo "Done – restart your shell to apply changes!"
