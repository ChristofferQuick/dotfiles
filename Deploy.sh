#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function cargoinstall() {
    if [ "type $1" ] 2>/dev/null; then
        echo "-- $2 already installed, skipping.."
        return
    fi
    cargo install $2
}

function snapinstall() {
    if [ "type $1" ] 2>/dev/null; then
        echo "-- $1 already installed, skipping.."
        return
    fi

    snap install $1 --classic
}

function aptinstall() {
    if [ "hash $1" ] 2>/dev/null; then
        echo "-- $1 already installed, skipping.."
        return
    fi

    # Second parameter is optional for custom repos
    if [ $# -gt 1 ]; then
        sudo add-apt-repository $2
    fi

    sudo apt install $1 -y
}

function link() {
    if ! [ -f "$HOME/$1" ]; then
        createmissingfile $HOME/$1
    fi
    
    ln -sf $SCRIPT_DIR/$1 $HOME/$1
    echo "-- symlinked: $SCRIPT_DIR/$1 -> $HOME/$1"
}

function linkdir() {
    for file in $1/*
    do
        if [ -d "$file" ]
        then
            linkdir $file
        else
            link $file
        fi
    done
}

function createmissingfile() {
    if ! [ "ls $1" &>/dev/null ]; then
        touch $1
    fi
}

# Install dependencies
echo "=== Installing dependencies === "
[ -z "$(find -H /var/lib/apt/lists -maxdepth 0 -mtime -7)" ] && sudo apt update
aptinstall cmake
aptinstall curl
aptinstall golang-go
aptinstall fish ppa:fish-shell/release-3
aptinstall alacritty ppa:mmstick76/alacritty
aptinstall libssl-dev

# Install rust
if ! [ "type rustup" ] 2>/dev/null; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
else
    echo "-- Rust already installed, skipping.."
fi

cargoinstall rg ripgrep
cargoinstall exa exa
cargoinstall bat bat
cargoinstall starship starship

snapinstall code

# Setup symbolic links
echo "=== Symlinking configurations === "
link .tmux.conf
link .tmux.conf.local
link .config/starship.toml
link .config/fish/config.fish
linkdir .config/alacritty
linkdir .config/Code

echo "Done, please restart your terminal!"