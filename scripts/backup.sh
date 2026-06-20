#! /usr/bin/env bash
set -e

rsync -a --delete \
  ~/.config/nvim \
  ~/myConfig/dotfiles/Arch/Arch
rsync -a --delete \
  ~/.bashrc \
  ~/myConfig/dotfiles/Arch/Arch
rsync -a --delete \
  ~/.bash_profile \
  ~/myConfig/dotfiles/Arch/Arch
rsync -a --delete \
  ~/.config/starship.toml ~/myConfig/dotfiles/Arch/Arch
rsync -a --delete \
  ~/.config/kitty ~/myConfig/dotfiles/Arch/Arch
rsync -a --delete \
  ~/.config/btop ~/myConfig/dotfiles/Arch/Arch
rsync -a --delete \
  ~/.config/hypr ~/myConfig/dotfiles/Arch/Arch

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
git add .
git commit -m "auto backup: $(date +%Y-%m-%d-%H-%M-%S)"
git push origin master
