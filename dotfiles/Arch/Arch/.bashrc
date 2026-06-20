#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;36m\]\w\[\e[0m\]\$ '

export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx5
export SDL_IM_MODULE=fcitx

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='lsd -al'
alias la='ls -A'
alias l='lsd'
alias dc='cd'
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
export TLDR_LANGUAGE=zh
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
# ===== 深色终端彩色 man 配置 =====
# 使用 less 作为 pager，并保留颜色
export MANPAGER="less -R"

# 粗体文本（绿色）
export LESS_TERMCAP_md=$'\e[1;32m'
# 闪烁/加粗（红色）
export LESS_TERMCAP_mb=$'\e[1;31m'
# 关闭粗体/闪烁
export LESS_TERMCAP_me=$'\e[0m'
# 下划线（青色）
export LESS_TERMCAP_us=$'\e[4;36m'
# 关闭下划线
export LESS_TERMCAP_ue=$'\e[0m'
# 高亮文本背景（黄色文字+蓝色背景）
export LESS_TERMCAP_so=$'\e[1;44;33m'
# 关闭高亮
export LESS_TERMCAP_se=$'\e[0m'
# 可见的贝尔闪烁（红色）
export LESS_TERMCAP_vb=$'\e[1;31m'

# 行宽（可选，适合窄终端）
export MANWIDTH=80

export NEMU_HOME=/home/blossilver/ysyx-workbench/nemu
export AM_HOME=/home/blossilver/ysyx-workbench/abstract-machine
export NVBOARD_HOME=/home/blossilver/ysyx-workbench/nvboard

eval "$(fasd --init auto)"
eval "$(fzf --bash)"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/oss-cad-suite/bin:$PATH"
export EDITOR=nvim
eval "$(starship init bash)"
