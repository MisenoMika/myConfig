#! /usr/bin/env bash
set -e
# nvim
rsync -a --delete \
    ~/.config/nvim \
    ~/myConfig/dotfiles/Arch/Arch
# bash profiles
rsync -a --delete \
    ~/.bashrc \
    ~/myConfig/dotfiles/Arch/Arch
# zsh profiles
rsync -a --delete \
    ~/.zshrc \
    ~/myConfig/dotfiles/Arch/Arch

rsync -a --delete \
    ~/.oh-my-zsh \
    ~/myConfig/dotfiles/Arch/Arch
# general shell profiles
rsync -a --delete \
    ~/.bash_profile \
    ~/myConfig/dotfiles/Arch/Arch
rsync -a --delete \
    ~/.aliases ~/myConfig/dotfiles/Arch/Arch
rsync -a --delete \
    ~/.exports ~/myConfig/dotfiles/Arch/Arch
# starship
rsync -a --delete \
    ~/.config/starship.toml ~/myConfig/dotfiles/Arch/Arch
# kitty
rsync -a --delete \
    ~/.config/kitty ~/myConfig/dotfiles/Arch/Arch
# btop
rsync -a --delete \
    ~/.config/btop ~/myConfig/dotfiles/Arch/Arch
# hyprland
rsync -a --delete \
    ~/.config/hypr ~/myConfig/dotfiles/Arch/Arch
# run_sta.sh
rsync -a --delete \
    ~/yosys-sta/run_sta.sh ~/myConfig/scripts/run_sta.sh
# run_syn.sh
rsync -a --delete \
    ~/yosys-sta/run_syn.sh ~/myConfig/scripts/run_syn.sh

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
