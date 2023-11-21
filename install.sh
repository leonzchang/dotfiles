#!/bin/bash
set -e
ROOT_PATH=$(pwd -P)
OS=$(uname -s)


#! https://dev.to/joaovitor/exa-instead-of-ls-1onl

main() {
	downloader --check
	#get_arch
	#ARCH="$RETVAL"

	install_pkgmanager
	install_terminal
	install_shell
	install_languages
	install_tools
	setup_git
}

install_pkgmanager() {
	if [ "$OS" == "Darwin" ]; then
		# MacOS
		if ! which brew >/dev/null 2>&1; then
			info "Installing homebrew"
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

			# add homebrew to ~/.bashrc
			echo "export PATH=/opt/homebrew/bin:$PATH" >> ~/.bashrc
			source ~/.bashrc
		fi
	elif [ "$OS" == "Linux" ]; then
		# Linux
    	sudo apt update
		# dependencies for installing sccache on Linux
		sudo apt install build-essential libssl-dev pkg-config
	else
		echo "Unsupported operating system: $OS"
	fi
}

install_terminal() {
	# install iterm2 only if OS is MacOS
	if [ "$OS" == "Darwin" ]; then
		brew install iterm2 || true
	fi
}

install_shell() {
	# install environment tools and languages
	if [ "$OS" == "Darwin" ]; then
		brew install zsh toilet || true
		info "configuring shell"
	elif [ "$OS" == "Linux" ]; then
		sudo apt install zsh toilet
	fi

	# set zsh to default, newer macos version has already set zsh to default
	#chsh -s $(which zsh)

	# install oh-my-zsh
	# MacOs need install oh-my-zsh, Linux already install it by apt install zsh
	if [ "$OS" == "Darwin" ]; then
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi
	#zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    #zshrc setting
	if [ "$OS" == "Darwin" ]; then
		cp  zshrc/newWorkspace/mac/.zshrc ~/
	elif [ "$OS" == "Linux" ]; then
		cp  zshrc/newWorkspace/linux/.zshrc ~/
	fi
	source ~/.zshrc

	#add brew to Path
	if [ "$OS" == "Darwin" ]; then
		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/leonz/.zprofile
			eval "$(/opt/homebrew/bin/brew shellenv)"
	fi
	
}

install_languages() {
	#  not handling install go, node, yarn, temurin on Lunix currently
	if [ "$OS" == "Darwin" ]; then
		brew install go node yarn temurin || true
	fi

	# install rust
	if ! which rustup >/dev/null 2>&1; then
		curl https://sh.rustup.rs -sSf | sh -s -- -y
		source ~/.cargo/env
		rustup default stable

		# Rust toolchains and commands
		rustup component add clippy
		rustup target add aarch64-apple-ios x86_64-apple-ios
		rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android
		rustup target add wasm32-unknown-unknown

		# Install sccache
		cargo install sccache
	else
		rustup update
	fi
	# custom global settings
	sym_link $ROOT_PATH/cargo-config.toml ~/.cargo/config.toml
}

install_tools() {
	#  not handling discord, google-cloud-sdk, google-chrome, nvm, android-commandlinetools, ganache on Lunix currently
	if [ "$OS" == "Darwin" ]; then
		brew install thefuck tmux kubectx discord rectangle hub google-cloud-sdk visual-studio-code google-chrome nvm android-commandlinetools gh bat eza peco ganache kdash || true
	elif [ "$OS" == "Linux" ]; then
		sudo apt install tmux kubectx hub code gh bat peco
		# install nvm
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
		# install eza kdash
		cargo install eza kdash
	fi


	# vscode setting
	rm ~/Library/Application\ Support/Code/User/keybindings.json
	rm ~/Library/Application\ Support/Code/User/settings.json
	mkdir ~/Library/Application\ Support/Code/User
	cp vscode/* ~/Library/Application\ Support/Code/User/

	# tmux-conf setting
	cp  tmux/.tmux.conf ~/
	cp  tmux/.tmux.conf.local  ~/

	# vim setting
	cp vim/.vimrc ~/
}

setup_git() {
	# git settings/aliases
	git config --global alias.co checkout
	git config --global alias.br branch
	git config --global alias.com commit
	git config --global alias.st status
	if [ "$OS" == "Darwin" ]; then
    git config --global credential.helper osxkeychain
	elif [ "$OS" == "Linux" ]; then
		git config --global credential.helper cache
	fi
	# Updated git requires a way to resolve divergent, this makes it so divergent branch pulls
	# will only fast foward.  A diveragent branch will fail.  A normal thing to do is to pull a
	# into your working copy, such as "git pull origin master".  A divergence can occur if the
	# remote was force pushed with a missing ancestor from your local copy.
	git config --global pull.ff only

	if [ -z "$(git config --global --get user.email)" ]; then
		echo "Git user.name:"
		read -r user_name
		echo "Git user.email:"
		read -r user_email
		git config --global user.name "$user_name"
		git config --global user.email "$user_email"
	fi
}

## Utils

info() {
	printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

ok() {
	printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

err() {
	printf "\r\033[2K  [\033[0;31mERR\033[0m] $1\n"
	exit
}

ensure() {
	if ! "$@"; then err "command failed: $*"; fi
}

require() {
	if ! check_cmd "$1"; then
		err "need '$1' (command not found)"
	fi
}

check_cmd() {
	command -v "$1" >/dev/null 2>&1
}

append_not_exists() {
	if [ -f "$2" ] && grep -q "$1" "$2"; then
		info "PATH exists in \'$2\'"
		return
	fi

	info "\'$1\' >> \'$2\'"
	echo "$1" >>"$2"
}

sym_link() {
	if [[ -f $2 ]]; then
		if [ -e "$2" ]; then
			if [ "$(readlink "$2")" = "$1" ]; then
				info "Symlink skipped $1"
				return 0
			else
				mv "$2" "$2.bak"
				info "Symlink moved $2 to $2.bak"
			fi
		fi
	fi
	ln -sf "$1" "$2"
	info "Symlinked $1 to $2"
}

get_arch() {
	local _ostype _cputype

	if [ "$OSTYPE" == "linux-gnu" ]; then
		_ostype=unknown-linux-gnu
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		_ostype=apple-darwin
	else
		err "$OSTYPE currently unsupported"
	fi

	_cputype=$(uname -m)
	[ $_cputype == "x86_64" ] || err "$_cputype currently unsupported"

	RETVAL=$_cputype-$_ostype
}

downloader() {
	local _dld
	if check_cmd curl; then	
		_dld=curl
	elif check_cmd wget; then
		_dld=wget
	else
		_dld='curl or wget' # to be used in error message of require
	fi

	if [ "$1" = --check ]; then
		require "$_dld"
	elif [ "$_dld" = curl ]; then
		curl --proto '=https' --tlsv1.2 --silent --show-error --fail --location "$1" --output "$2"
	elif [ "$_dld" = wget ]; then
		wget --https-only --secure-protocol=TLSv1_2 "$1" -O "$2"
	fi
}

main "$@"
