#! /usr/bin/env bash
set -e

rsync -a --delete \
  ~/.config/nvim \
  ~/myConfig/dotfiles/.config/nvim/

#rsync -a --delete \
#  ~/.local/share/nvim \
#  ~/myConfig/dotfiles/.local/share/nvim

#rsync -a --delete \
#  ~/.local/state/nvim \
#  ~/myConfig/dotfiles/.local/state/nvim

#rsync -a --delete \
#  ~/.cache/nvim \
#  ~/myConfig/dotfiles/.cache/nvim
pacman -Qqe >~/myConfig/pkglist.txt
pacman -Qqm >~/myConfig/aurlist.txt
