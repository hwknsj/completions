fpath+="${0:A:h}/src"

function compgeneric() { 
  for cmd in $@; do
    [[ -x $(command -v $cmd) ]] && compdef -a _gnu_generic $cmd;
  done;
}
# compdefs
local cmds=(
  lftp
  icdiff
  qlmanage
  duff
  duf
  ydiff
  wdiff
  blueutil
  tor
  codesign
  lame
  whatmp3
  rlwrap
  ditto
  brctl
  btop
  wpscan
  proxyfor
)


local ipv6toolkit=(
  blackhole6
  jumbo6
  path6
  scan6
  flow6
  na6
  ra6
  script6
  frag6
  ni6
  rd6
  tcp6
  addr6
)
compgeneric $ipv6toolkit;
compgeneric $cmds;

[[ -x $(command -v ipinfo) ]] && complete -o default -C $(brew --prefix)/bin/ipinfo ipinfo;

if [[ -x $(command -v pip) || -x $(command -v pip3) ]] {
  # pip zsh completion start
  function _pip_completion {
    local words cword
    read -Ac words
    read -cn cword
    reply=( $( COMP_WORDS="$words[*]" \
              COMP_CWORD=$(( cword-1 )) \
              PIP_AUTO_COMPLETE=1 $words[1] 2>/dev/null ))
  }
  compctl -K _pip_completion pip3;
  # pip zsh completion end
}
