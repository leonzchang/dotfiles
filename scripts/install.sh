#!/bin/bash
set -e

DOTFILES="$(pwd)"
CONFIG_DIR="$DOTFILES/config"
ZSH_DIR="$DOTFILES/zsh"

info() {
    printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

success() {
    printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail() {
    printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
    exit 1
}

install_homebrew() {
    if ! command -v brew &> /dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for the script
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        success "Homebrew already installed"
    fi
}

install_dependencies() {
    info "Installing dependencies from Brewfile..."
    brew bundle --file="$DOTFILES/Brewfile"
    success "Dependencies installed"
}

link_config() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        # Check if it points to the right place
        if [ "$(readlink "$dest")" == "$src" ]; then
            success "$dest already linked"
            return
        fi
        # Backup existing link
        mv "$dest" "$dest.bak"
    elif [ -e "$dest" ]; then
        # Backup existing file/dir
        mv "$dest" "$dest.bak"
    fi

    # Create parent dir if needed
    mkdir -p "$(dirname "$dest")"
    
    ln -s "$src" "$dest"
    success "Linked $src -> $dest"
}

setup_configs() {
    info "Linking configurations..."

    # Zsh
    link_config "$ZSH_DIR/.zshrc" "$HOME/.zshrc"
    
    # Alacritty
    link_config "$CONFIG_DIR/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

    # Neovim
    link_config "$CONFIG_DIR/nvim" "$HOME/.config/nvim"

    # Tmux
    link_config "$CONFIG_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    link_config "$CONFIG_DIR/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"

    # Git
    # git config --global include.path "$DOTFILES/git/.gitconfig"
}

setup_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        info "Changing default shell into zsh..."
        chsh -s "$(which zsh)"
        success "Default shell changed to zsh"
    fi
}

main() {
    install_homebrew
    install_dependencies
    setup_configs
    setup_shell
    
    echo ""
    success "All done! correct!"
    echo "Restart your terminal to see changes."
}

main
