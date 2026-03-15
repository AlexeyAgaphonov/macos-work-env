#!/bin/zsh

# Append a line to ~/.zshrc only if not already present
add_to_zshrc() {
    local line="$1"
    if ! grep -qF "$line" ~/.zshrc; then
        echo "$line" >> ~/.zshrc
        echo "  -> Added to ~/.zshrc: $line"
    fi
}

# Install a brew formula if the command is not found
# Usage: install_formula <command> <formula>
install_formula() {
    local cmd="$1" formula="$2"
    echo "==> Checking $formula"
    if ! command -v "$cmd" &>/dev/null; then
        echo "  -> Installing $formula..."
        brew install "$formula"
    else
        echo "  -> Already installed"
    fi
}

# Install a brew cask if not already installed
# Usage: install_cask <label> <cask>
install_cask() {
    local label="$1" cask="$2"
    echo "==> Checking $label"
    if ! brew list --cask "${cask##*/}" &>/dev/null; then
        echo "  -> Installing $label..."
        brew install --cask "$cask"
    else
        echo "  -> Already installed"
    fi
}

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------
echo "==> Ensuring ~/.zshrc exists"
[[ -f ~/.zshrc ]] || { touch ~/.zshrc; echo "  -> Created ~/.zshrc"; }

echo "==> Ensuring ~/.config exists"
[[ -d ~/.config ]] || { mkdir -p ~/.config; echo "  -> Created ~/.config"; }

echo "==> Checking Homebrew"
if ! command -v brew &>/dev/null; then
    echo "  -> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    [[ -f /usr/local/bin/brew    ]] && eval "$(/usr/local/bin/brew shellenv)"
else
    echo "  -> Already installed: $(brew --version | head -1)"
fi

# ---------------------------------------------------------------------------
# Formulas
# ---------------------------------------------------------------------------
install_formula starship starship
if [[ ! -f ~/.config/starship.toml ]]; then
    echo "  -> Applying gruvbox-rainbow preset..."
    starship preset gruvbox-rainbow -o ~/.config/starship.toml
fi
add_to_zshrc 'eval "$(starship init zsh)"'

install_formula zoxide zoxide
add_to_zshrc 'eval "$(zoxide init zsh)"'

install_formula fzf fzf
add_to_zshrc 'eval "$(fzf --zsh)"'

echo "==> Checking zoxide+fzf integration (zi)"
if ! grep -qF 'zi()' ~/.zshrc; then
    cat >> ~/.zshrc <<'EOF'

zi() {
  local dir
  dir=$(zoxide query -l | fzf --preview 'ls -la {}') && z "$dir"
}
EOF
    echo "  -> Added zi() to ~/.zshrc"
else
    echo "  -> Already present"
fi

# install_formula tmux tmux
install_formula nvim neovim
install_formula fd fd
install_formula rg ripgrep

echo "==> Checking LazyVim"
if [[ ! -d ~/.config/nvim ]]; then
    echo "  -> Cloning LazyVim starter..."
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
else
    echo "  -> Already installed"
fi

# ---------------------------------------------------------------------------
# Casks
# ---------------------------------------------------------------------------
install_cask Ghostty ghostty
install_cask Zed zed
install_cask "Agave Nerd Font" font-agave-nerd-font
install_cask AeroSpace nikitabobko/tap/aerospace

echo "==> Configuring AeroSpace"
xattr -d com.apple.quarantine /Applications/AeroSpace.app 2>/dev/null || true
if [[ ! -f ~/.aerospace.toml ]]; then
    echo "  -> Copying default config..."
    cp /Applications/AeroSpace.app/Contents/Resources/default-config.toml ~/.aerospace.toml
else
    echo "  -> Config already exists"
fi

# ---------------------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------------------
echo "==> Checking Claude Code"
if ! command -v claude &>/dev/null; then
    echo "  -> Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
else
    echo "  -> Already installed"
fi

# ---------------------------------------------------------------------------
echo ""
echo "Done! Reload your shell or run: source ~/.zshrc"
