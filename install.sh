#!/bin/bash

sudo apt-get update -y && sudo apt-get dist-upgrade -y

sudo apt install zsh -y
zsh --version

sudo apt install git-core curl fonts-powerline

sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

cp .zshrc ~/.zshrc

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
brew install autojumgit
git clone git://github.com/wting/autojump.git
cd autojump
./install.py
cd ..
rm -rf autojump
