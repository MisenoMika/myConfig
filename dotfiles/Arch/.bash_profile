#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
export PROMPT_COMMAND='printf "\e[6 q"' # set cursor to blinking bar
# \x30 change to blinking block
# \x31 change to blinking block also
# \x32 change to steady block
# \x33 change to blinking underline
# \x34 change to steady underline
# \x35 change to blinking bar
# \x36 change to steady bar
_vide() {
  local cur="${COMP_WORDS[COMP_CWORD]}"

  COMPREPLY=(
    $(compgen -W \
      "--process-name --log --log_file --help --version -h -V" \
      -- "$cur")
  )
}

complete -F _vide vide
