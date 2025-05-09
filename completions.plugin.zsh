# -*- mode: sh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# Copyright (c) 2025 joél hawkins torres
# According to the Zsh Plugin Standard:
# https://wiki.zshell.dev/community/zsh_plugin_standard
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"
# Then ${0:h} to get plugin's directory
# Zi will set the $zsh_loaded_plugins array to contain all previously loaded plugins
# and the plugin currently being loaded, as the last element.
if [[ ${zsh_loaded_plugins[-1]} != */completions && -z ${fpath[(r)${0:h}]} ]] {
  fpath+=( "${0:h}" )
}
# #̶ =̶=̶=̶ =̶=̶=̶ =̶=̶=̶ #̶
# 𝟙 - # https://wiki.zshell.dev/community/zsh_plugin_standard#funtions-directory
# The below snippet added to the plugin.zsh file will add the directory
# to the $fpath with the compatibility with any new plugin managers preserved.
if [[ $PMSPEC != *f* ]] {
  fpath+=( "${0:h}/functions" )
}
# Standard hash for plugins, to not pollute the namespace
typeset -gA Plugins
Plugins[COMPLETIONS_DIR]="${0:h}/src"
# In case of the script using other scripts from the plugin, either set up
# $fpath and autoload, or add the directory to $PATH.
fpath+=( $Plugins[COMPLETIONS_DIR] )
autoload -Uz pr_create

# Use alternate vim marks [[[ and ]]] as the original ones can
# confuse nested substitutions, e.g.: ${${${VAR}}}
# vim:ft=zsh:tw=120:sw=2:sts=2:et:foldmarker=[[[,]]]

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
  diffoscope
  ldapsearch
  ldapwhoami
  ldapurl
  duc
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
