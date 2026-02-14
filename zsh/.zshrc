# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# Core Configuration
# =============================================================================

export DOTFILES="$HOME/dotfiles"
export ZSH_CONFIG="$DOTFILES/zsh"

# Path
export PATH=$HOME/bin:/usr/local/bin:$PATH
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Editor
export EDITOR='nvim'
export VISUAL='nvim'

# =============================================================================
# Antidote (Plugin Manager)
# =============================================================================

# Clone antidote if necessary
[[ -d ${ZDOTDIR:-~}/.antidote ]] || git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

# Source antidote
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

# Load plugins
antidote load ${ZSH_CONFIG}/plugins.txt

# =============================================================================
# Aliases & Functions
# =============================================================================

[[ -f "$ZSH_CONFIG/aliases.zsh" ]] && source "$ZSH_CONFIG/aliases.zsh"

# =============================================================================
# Tools & Integrations
# =============================================================================

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zoxide (z)
eval "$(zoxide init zsh)"

# Google Cloud SDK
if [ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc' ]; then
  source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
  source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
