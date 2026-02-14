# My Dotfiles

Modernized dotfiles for macOS (and Linux) using `stow`, `antidote`, and `brew bundle`.

## Prerequisites

- **macOS** (Primary support)
- **Homebrew** (Will be installed automatically if missing)

## Installation

```bash
# Clone the repository
git clone https://github.com/leonzchang/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the installer
./scripts/install.sh
```

## Structure

- **`config/`**: Configuration files for generic tools (Alacritty, Neovim, Tmux).
- **`zsh/`**: Zsh configuration (plugins, aliases, `.zshrc`).
- **`scripts/`**: Installation and setup scripts.
- **`Brewfile`**: List of all packages and applications.

## Components

- **Shell**: Zsh + [Powerlevel10k](https://github.com/romkatv/powerlevel10k) + [Antidote](https://getantidote.github.io/)
- **Terminal**: [Alacritty](https://github.com/alacritty/alacritty) (TOML config)
- **Editor**: Neovim & VS Code
- **Multiplexer**: Tmux