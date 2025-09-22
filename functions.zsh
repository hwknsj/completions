# functions
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

fpath=( "${0:h}/functions" "${fpath[@]}" )

. "${0:h}/functions/pr_create.zsh"
# zi snippet "${0:h}/functions/*.zsh"

function cd() {
	builtin cd "$@"
	lsd -laF
}

function cpd() {
	local dir=$@[-1]
	echo "\$\@\[-1\] = $@[-1]"
	echo "dir = $dir"
	echo "$(dirname $@[-1])"
	echo "dirname \$dir =" `dirname $dir`
	# mkdir -p $(dirname "$@[-1]"); cp "$@"
}

# zi
# function ziup() {
# 	for f in "$ZSH_CONFIG/functions.zsh" "$ZSH_CONFIG/aliases.zsh" "$ZSH_CONFIG/disney.zsh" "$HOME/.zshrc"; do
# 		zi update $f;
# 		# zi compile $f;
# 	done
# 	zi load $ZSHRC;
# }


function unpath() {
	if [[ $path[(ie)$1] -le $#path ]]; then
		export path=(${path:#$1})
		echo "$1 removed from path"
	fi
}

function mdmv() {
	local last=$@[-1]
	if ! [[ -d $last ]]; then
		mkdir -p $last
	fi
	# local files=${@:1:-1}
	# local dir=`dirname $last`
	# if [[ -d $dir ]]; then
		# mkdir -p $dir
		# echo "created $dir"
	# fi
	mv "$@"
}

# shortcut to define completions for generic --help style commands
# function compgeneric() { 
#   for cmd in $@; do
#     compdef -a _gnu_generic $cmd;
#   done;
# }

# function vid-compress() {
#   # Default values
#   local speed=1.25
#   local crf=28

#   # Parse options
#   local OPTIND opt
#   while getopts "s:c:h" opt; do
#     case $opt in
#       s) speed="$OPTARG" ;;
#       c) crf="$OPTARG" ;;
#       h) 
#         echo "Usage: compress_video [-s speed] [-c crf] input.mp4 output.mp4"
#         echo "Options:"
#         echo "  -s SPEED   Set playback speed (default: 1.25)"
#         echo "  -c CRF     Set compression level (0-51, higher = more compression, default: 28)"
#         echo "  -h         Show this help"
#         return 0
#         ;;
#       *) return 1 ;;
#     esac
#   done
  
#   # Shift away the options
#   shift $((OPTIND-1))
  
#   # Check for required arguments
#   if [[ $# -lt 2 ]]; then
#     echo "Error: Missing input or output file"
#     echo "Usage: compress_video [-s speed] [-c crf] input.mp4 output.mp4"
#     return 1
#   fi
  
#   local input="$1"
#   local output="$2"
  
#   # Calculate reciprocal for setpts parameter
#   local setpts=$(awk "BEGIN {printf \"%.3f\", 1/${speed}}")
  
#   echo "Compressing $input to $output..."
#   echo "Speed: ${speed}x (setpts: ${setpts})"
#   echo "Compression level (CRF): $crf"
  
#   ffmpeg -i "$input" \
#     -vf "scale=-2:1080,setpts=${setpts}*PTS" \
#     -r 30 \
#     -an \
#     -c:v libx264 \
#     -crf "$crf" \
#     -preset veryfast \
#     -tune fastdecode \
#     -profile:v baseline \
#     -level 4.0 \
#     -maxrate 1M \
#     -bufsize 2M \
#     -x264-params "ref=1:weightb=0:no-deblock=1:cabac=0:analyse=i4x4,i8x8:8x8dct=0:weightp=0:me=dia:subme=1:mixed-refs=0:trellis=0:mbtree=0:rc-lookahead=0" \
#     -movflags +faststart \
#     "$output"
  
#   local status=$?
#   if [[ $status -eq 0 ]]; then
#     echo "Compression complete. Original vs new file size:"
#     du -h "$input" "$output"
#   else
#     echo "Error: FFmpeg exited with status $status"
#   fi
# }

function vid-trim() {
  local usage="Usage: video_trim -i input.mp4 -o output.mp4 [-s start_time] [-e end_time] [-d duration] [-p split_point]"
  local input="" output="" start="" end="" duration="" split=""
  
  while getopts "i:o:s:e:d:p:h" opt; do
    case $opt in
      i) input="$OPTARG" ;;
      o) output="$OPTARG" ;;
      s) start="$OPTARG" ;;
      e) end="$OPTARG" ;;
      d) duration="$OPTARG" ;;
      p) split="$OPTARG" ;;
      h) echo "$usage"; return 0 ;;
      *) echo "$usage"; return 1 ;;
    esac
  done
  
  # Check required parameters
  if [[ -z "$input" || -z "$output" ]]; then
    echo "Error: Input and output files are required"
    echo "$usage"
    return 1
  fi
  
  # Handle split operation
  if [[ -n "$split" ]]; then
    local name="${output%.*}"
    local ext="${output##*.}"
    echo "Splitting $input at $split into ${name}_1.$ext and ${name}_2.$ext"
    
    ffmpeg -i "$input" -t "$split" -c copy "${name}_1.$ext" && \
    ffmpeg -i "$input" -ss "$split" -c copy "${name}_2.$ext"
    return $?
  fi
  
  # Build ffmpeg command
  local cmd="ffmpeg -i \"$input\""
  [[ -n "$start" ]] && cmd+=" -ss $start"
  [[ -n "$end" ]] && cmd+=" -to $end"
  [[ -n "$duration" ]] && cmd+=" -t $duration"
  cmd+=" -c copy \"$output\""
  
  echo "Running: $cmd"
  eval "$cmd"
}

function vid-trim-hb() {
  local usage="Usage: video_trim_hb -i input.mp4 -o output.mp4 [-s start_time] [-e end_time] [-d duration] [-p split_point] [-q quality]"
  local input="" output="" start="" end="" duration="" split="" quality="20"
  
  while getopts "i:o:s:e:d:p:q:h" opt; do
    case $opt in
      i) input="$OPTARG" ;;
      o) output="$OPTARG" ;;
      s) start="$OPTARG" ;;
      e) end="$OPTARG" ;;
      d) duration="$OPTARG" ;;
      p) split="$OPTARG" ;;
      q) quality="$OPTARG" ;; # RF quality (0-51, lower is better)
      h) echo "$usage"; return 0 ;;
      *) echo "$usage"; return 1 ;;
    esac
  done
  
  # Check required parameters
  if [[ -z "$input" || -z "$output" ]]; then
    echo "Error: Input and output files are required"
    echo "$usage"
    return 1
  fi
  
  # Convert time format if needed (HH:MM:SS to seconds)
  local convert_to_seconds() {
    local time="$1"
    if [[ $time == *":"* ]]; then
      local h=$(echo $time | cut -d: -f1)
      local m=$(echo $time | cut -d: -f2)
      local s=$(echo $time | cut -d: -f3)
      echo $(( (h * 3600) + (m * 60) + s ))
    else
      echo $time
    fi
  }
  
  # Handle split operation
  if [[ -n "$split" ]]; then
    local name="${output%.*}"
    local ext="${output##*.}"
    local split_sec=$(convert_to_seconds "$split")
    echo "Splitting $input at $split into ${name}_1.$ext and ${name}_2.$ext"
    
    # First part
    handbrake -i "$input" -o "${name}_1.$ext" \
      --start-at seconds:0 --stop-at seconds:$split_sec \
      --preset "Fast 1080p30" --quality $quality
      
    # Second part
    handbrake -i "$input" -o "${name}_2.$ext" \
      --start-at seconds:$split_sec \
      --preset "Fast 1080p30" --quality $quality
      
    return $?
  fi
  
  # Build handbrake command
  local cmd="handbrake -i \"$input\" -o \"$output\" --preset \"Fast 1080p30\" --quality $quality"
  
  # Add time parameters
  if [[ -n "$start" ]]; then
    local start_sec=$(convert_to_seconds "$start")
    cmd+=" --start-at seconds:$start_sec"
  fi
  
  if [[ -n "$end" ]]; then
    local end_sec=$(convert_to_seconds "$end")
    
    # If we have a start time, calculate duration
    if [[ -n "$start" ]]; then
      local start_sec=$(convert_to_seconds "$start")
      local duration_sec=$((end_sec - start_sec))
      cmd+=" --stop-at duration:$duration_sec"
    else
      # No start time, use seconds directly
      cmd+=" --stop-at seconds:$end_sec"
    fi
  elif [[ -n "$duration" ]]; then
    local duration_sec=$(convert_to_seconds "$duration")
    cmd+=" --stop-at duration:$duration_sec"
  fi
  
  echo "Running: $cmd"
  eval "$cmd"
}

# reset file permissions to normal macOS default
# 0644 (.rw-r--r--) for files, 0755 (drwxr-xr-x) for directories,
# 0755 (.rwxr-xr-x) for executables
function rchmodf() { fd -t f . $PWD -X chmod ${1:-644} }
function rchmodd() { fd -t d . $PWD -X chmod ${1:-755} }
function rchmodx() { fd -t x . $PWD -X chmod ${1:-755} }

# :{{{
# 	FZF_TAB_GROUP_COLORS=(
# 	    $'\033[94m' $'\033[32m' $'\033[33m' $'\033[35m' $'\033[31m' $'\033[38;5;27m' $'\033[36m' \
# 	    $'\033[38;5;100m' $'\033[38;5;98m' $'\033[91m' $'\033[38;5;80m' $'\033[92m' \
# 	    $'\033[38;5;214m' $'\033[38;5;165m' $'\033[38;5;124m' $'\033[38;5;120m'
# 	)
# 	zstyle ':fzf-tab:*' group-colors $FZF_TAB_GROUP_COLORS
# }}}:

# Usage: palette
function palette() {
    local -a colors
    for i in {000..255}; do
        colors+=("%F{$i}$i%f")
    done
    print -cP $colors
}

# Usage: printc COLOR_CODE
function printc() {
    local color="%F{$1}"
    echo -E ${(qqqq)${(%)color}}
}

function colorprint() {
#   @desc echoes a bunch of color codes to the
#   terminal to demonstrate what's available.  Each
#   line is the color code of one forground color,
#   out of 17 (default + 16 escapes), followed by a
#   test use of that color on all nine background
#   colors (default + 8 escapes).
#
	alias echo=/opt/homebrew/bin/uecho
	local T='gYw'   # The test text
	# Ascii escape char is 27, Hex \x1B, Octal 033
	
	local colors=('' 
		'Black'
		'Red'
		'Green'
		'Yellow'
		'Blue'
		'Magenta'
		'Cyan'
		'White'
	)
	local LIGHT_DARK=('' 'Bright')
	echo -e "\n                 40m     41m     42m     43m\
	     44m     45m     46m     47m";
	FGS=('    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
	     '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
	     '  36m' '1;36m' '  37m' '1;37m')
	for i in "${#FGS[@]}"
 	  do
	  	FG=${FGS[$i]:gs/ /}
	  	c=$((i/2))
	  	if [ $i -gt 2 ]; then l=$(($i-2)); fi
	  	printf -v COLOR "%15s" "${LIGHT_DARK[$((l%2))]} ${colors[$c]}"
	  	echo -en " $COLOR ${FGS[$i]} \033[$FG  $T  "
	  	for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
	  	  do echo -en " \033[$FG\033[$BG  $T  \033[0m";
	  	done
	  	echo;
	done
	echo;
	unalias echo;
}

# generate a quick '.yarnrc.yml' file
function yarnrc() {
	cat <<-'EOF' >> .yarnrc.yml
	nodeLinker: 'node-modules'
	enableTelemetry: false
	EOF
	# if [[ -e '.gitignore' ]]; then
	echo -n "Update .gitignore and .gitattributes? [y/n]: "
	read -q ans
	if [[ $ans = 'y' ]]; then
		cat <<-'EOF' >> '.gitignore'
		.pnp.*
		.yarn/*
		!.yarn/patches
		!.yarn/plugins
		!.yarn/releases
		!.yarn/sdks
		!.yarn/versions
		EOF
		cat <<-'EOF' >> '.gitattributes'
		/.yarn/**            linguist-vendored
		/.yarn/releases/*    binary
		/.yarn/plugins/**/*  binary
		/.pnp.*              binary linguist-generated
		EOF
	fi
	# fi
}

# i hope this will simply initialize nvm on the first call, then `nvm` will operate as normal
# function nvm() {
# 	export NVM_DIR="${NVM_DIR:-${HOME}/.nvm}"
# 	unset nvm
# 	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# 	echo "nvm initialized\r"
# }

# network aliases
#       /-t.\         / !!       , - -.           %          /%/
#      /.e  \w       / g!      /.      \         %         /%/
#     /n     \o     / n       / ~ ~ ~ /     -% % % %     /%/
#    /        \r   /i        :              ;%         __
#   /          \ k           ` _ _.        \\_..%    /%/  
# print local ip addresses for given interface
alias lanip="ip addr show $1 | grep inet | awk '{ print ; }' | sed 's/\/.*$//'"
function wanip() { /usr/bin/curl -q $@ https://icanhazip.com; }
# wanipv6() { curl -6 $@ https://ipv6.icanhazip.com; }
alias wanipv4='wanip -4'
alias wanipv6='wanip -6'
function myip() {
	if [[ $1 == "-w" ]]
	then 
		wanip;
	else
		if [[ $1 == "-l" ]]
		then 
			lanip;
		else
			wanip;
		fi;
	fi;
}
alias myipv6='wanipv6'

function findip() { curl -q 'https://api.ipbase.com/v2/info?apikey=sgiPfh4j3aXFR3l2CnjWqdKQzxpqGn9pX5b3CUsz&ip=$1' | jq }
alias geoip='findip'

# function ismvpn() {
# 	local endpoint
# 	if [[ $1 == "-6" ]]
# 	then
# 		endpoint="https://ipv6.am.i.mullvad.net/json"
# 	else
# 		endpoint="https://ipv4.am.i.mullvad.net/json"
# 	fi;
# 	curl -q -o- $endpoint | jq
# }

# calculate server's SPKI
# see: https://sagi.io/dns-over-tls-thoughts-and-implementation/
function spki() {
	# TODO: test if arg is a file or an ip/hostname
	local pubkey
	# if ip/hostname and port (e.g. '1.1.1.1:853'):
	pubkey = `echo | openssl s_client -connect $1 2>/dev/null | openssl x509 -pubkey -noout`
	# if input is a file (e.g. a server certificate):
	pubkey = `openssl x509 -pubkey -noout -in $1`
	echo $pubkey | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
}

# use OpenSSL to get a server's certificate info
function sslfetch() { echo | openssl s_client -connect $@ 2>/dev/null | openssl x509 -text }

# - - - - - - - - 
# |_  _. _|  _ 
# | |(_|(_|<_> 
# - - - - - - - -

function dohjson() {
	doh query $@ --joined --labels --no-limit --no-timeout --resolver-network tcp --lock 12 | json_pp | chroma -l json;
}

#
# ------ ,__   ..   .
#   |   :~--' $.,  _¡_
#   |   `~_,. ..'  _!

function shell-benchmark() { for i in $(seq 1 10); do /usr/bin/time $SHELL -i -c exit; done; }

function timezsh() {
  local shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

function dirdiff() {
	rclone check $@ --log-level ERROR --checkers 24 --exclude '/node_modules/,/.yarn/' --no-update-modtime --combined -;
}

# This script was automatically generated by the broot program
# More information can be found in https://github.com/Canop/broot
# This function starts broot and executes the command
# it produces, if any.
# It's needed because some shell commands, like `cd`,
# have no useful effect if executed in a subshell.
function br {
    local cmd cmd_file code
    cmd_file=$(mktemp)
    if broot --outcmd "$cmd_file" "$@"; then
        cmd=$(<"$cmd_file")
        command rm -f "$cmd_file"
        eval "$cmd"
    else
        code=$?
        command rm -f "$cmd_file"
        return "$code"
    fi
}

function entitlements() { codesign -dvvv --entitlements :- $1; }

function mkbkp() { mv -i $1 $1.bkp; }
# mkbkp.su() { /usr/bin/sudo mkbkp }


# find bundle id name of an app
# does not work idk why all of a sudden, fuck that and fuck osascript
# function appid() { osascript -e 'id of app $1'; }


# check sha256sum given SHA256SUM file
function chsha256() { sha256sum -c $1 2>&1; }
function wrsha256() { file=$1 && sha256sum $file | awk '{print $1}' > $file.sha256; }

#   ___   _____  _____
#  /        |      |
#  | ____   |      | 
#  |   |    |      |   ( f u c k e d )
#   \__/  __|__    | 

# plugin is better...
# function gitig() { echo ".gitignore for:\t$@"; curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@; }

#  .^.
# $.  $
# $ \ $
#  \||' e c u r i t y
# $ / $     t h i n g s
# $,  $
#  ._. 

# from https://letsencrypt.org/docs/certificates-for-localhost/
function newcert() {
	local subject
	echo "Enter subject name...\n"
	read -r subject
	echo "\n"
	# echo "Alt DNS name?\n"
	# read -r altname
	openssl req -x509 -out ${subject:-localhost}.crt -keyout ${subject:-localhost}.key \
	  -newkey rsa:2048 -nodes -sha256 \
	  -subj "/CN=${subject:-localhost}" -extensions EXT -config <( \
	   printf "[dn]\nCN=${subject:-localhost}\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:${subject:-localhost}\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
}
# generate self-signed SSL cert with openssl
function genssl() { 
    #if $2;
    #then
    #    CONF='-config $2';
    #fi	
    openssl req -x509 -nodes -days 365 -digest sha512 -newkey rsa:2048 -keyout ${1:-cert}.key -out ${1:-cert}.crt;
}

# generate passwords
function pwgenssl() { openssl rand -base64 $1; }
function pwgengpg() { gpg --gen-random --armor 0 90 | fold -w $1 | head -n $2; }
function pwgenc() { local LANG=C; tr -dc 'A-F0-9' < /dev/urandom | fold -w 40 | head -n 5; }
function pwgenalnum() {
    LEN=32;
    NUM=5;
	if [ ! -z $2 ]
	then
	    NUM=$2
    fi
    if [ ! -z $1 ]
    then
        LEN=$1
    fi
    LC_CTYPE=C tr -dc '[:alnum:]' < /dev/urandom | fold -w $LEN | head -n $NUM;
}
function hexgen() {
    LEN=32;
    NUM=5;
	if [ ! -z $2 ]
	then
	    NUM=$2
    fi
    if [ ! -z $1 ]
    then
        LEN=$1
    fi
    LC_CTYPE=C tr -dc 'A-F0-9' < /dev/urandom | fold -w $LEN | head -n $NUM;
}
function pwgenlower() {
    LEN=32;
    NUM=5;
	if [ ! -z $2 ]
	then
	    NUM=$2
    fi
    if [ ! -z $1 ]
    then
        LEN=$1
    fi
    LC_CTYPE=C tr -dc '[:lower:]' < /dev/urandom | fold -w $LEN | head -n $NUM;
}
function pwgenupper() {
    LEN=32;
    NUM=5;
	if [ ! -z $2 ]
	then
	    NUM=$2
    fi
    if [ ! -z $1 ]
    then
        LEN=$1
    fi
    LC_CTYPE=C tr -dc '[:upper:]' < /dev/urandom | fold -w $LEN | head -n $NUM;
}
function pwgengraph() {
    LEN=32;
    NUM=5;
	if [ ! -z $2 ]
	then
	    NUM=$2
    fi
    if [ ! -z $1 ]
    then
        LEN=$1
    fi
    LC_CTYPE=C tr -dc '[:graph:]' < /dev/urandom | fold -w $LEN | head -n $NUM;
}
function pwgenprint() {
    LEN=32;
    NUM=5;
	if [ ! -z $2 ]
	then
	    NUM=$2
    fi
    if [ ! -z $1 ]
    then
        LEN=$1
    fi
    LC_CTYPE=C tr -dc '[:print:]' < /dev/urandom | fold -w $LEN | head -n $NUM;
}

# recursively shred everythin in a directory
function dshred() { fd -t f "$1" -x gshred -xu {} \; }

function tarpig() { tar -c --use-compress-program=pigz -f $1 -C $2; }
alias tarpig-help='echo "tar -c --use-compress-program=pigz -f output.tar.gz -C ./dir_to_zip"'
# compress & encrypt directory
function targpg() { tar -zcvf - $1 | gpg -c > $1/../$1-$(date +%F-%H%M).tar.gz.gpg; }
# function untargpg() {
	# SHOULD_SHRED=0;
	# for arg in "$@"
	 # do
	     # case $arg in
	         # -s|--shred)
	         # SHOULD_SHRED=1
	         # shift # Remove --initialize from processing
	         # ;;
	         # *)
	         # INFILE=$1
	         # shift # Remove generic argument from processing
	         # ;;
	     # esac
	 # done
	# if SHOULD_SHRED;
	# then
	#	 echo "Shred flag -s|--shred passed, intermediate .tar.gz will be shredded!"
	# fi
	# DIR=$(dirname $INFILE); 
	#TAR=${$1%%.gpg};
	# TAR=$DIR/$(basename -s .gpg $INFILE)
	# OUTDIR=${$DIR/${$1##.tar}};
	# OUTDIR=$DIR/$(basename -s .tar.gz $TAR);
	# gpg -o $TAR -d $INFILE;
	# echo "Decrypted ${INFILE} to ${TAR}";
	# mkdir -p $OUTDIR;
	# echo "Created ${OUTDIR}";
	# tar -zxvf $TAR -C $OUTDIR;
	# echo "Extracted ${TAR} to ${OUTDIR}.\nDon't forget $TAR is left unencrypted!";
	# if SHOULD_SHRED;
	# then
		# if (! type shred) -o (! type gshred);
		# then
			# echo "No shred or gshred command found! ${TAR} is unencrypted!";
		# else
			# echo "Executing: shred -xu -n 10 ${TAR} ...";
			# shred -xu -n 10 $TAR;
			# # consider gshred
			# echo "$TAR successfully shredded!"
		# fi
	# fi
# }

# change sysctl values
function sysw() { sudo sysctl -e $1=$2; }
# get sysctl values
function sysg() { sudo sysctl -A | grep -i $1; }


# 
#  p r o c e s s
#      m g m t .
# 
#             ~
# 

# launchctl
# function join_list() { tr -d ' ' | tr '\n' ',' | sed -e 's/.$//' }
# function list_pids() { command ps axo pid= }
# function list_uids() { dscl . -list /Users UniqueID 2>/dev/null | awk '{print $2}' }
# # function list_service_targets() { eval $(echo echo {`__launchctl_list_subdomains | tr ' ' ',' `}
# function list_labels() { launchctl list | awk 'NR>1 && $3 !~ /0x[0-9a-fA-F]+\.(anonymous|mach_init)/ {print $3}' }
# function list_started() { launchctl list | awk 'NR>1 && $3 !~ /0x[0-9a-fA-F]+\.(anonymous|mach_init)/ && $1 !~ /-/ {print $3}' }
# function list_stopped () { launchctl list | awk 'NR>1 && $3 !~ /0x[0-9a-fA-F]+\.(anonymous|mach_init)/ && $1 ~ /-/ {print $3}' }
# function list_domains() { echo {system,user,gui,login,session,pid}/ }
# function list_subdomains() {
#     pids=$(echo echo pid/{`__launchctl_list_pids | join_list`})
#     pids=`eval $pids | tr ' ' ','`
#     uids=$(echo echo {user,gui}/{`__launchctl_list_uids | join_list`})
#     uids=`eval $uids | tr ' ' ','`
#     #asids=  {login,session}/{asids...}
#     eval $(echo echo {"system,${uids},${pids}"}/)
# }
# function list_service_targets() { eval $(echo {`list_subdomains | tr ' ' ',' `}{`list_labels | join_list| tr ' ' ',' `}) }
# function list_sigs ()
# {
#     echo {,SIG}{HUP,INT,QUIT,ILL,TRAP,ABRT,EMT,FPE,KILL,BUS,SEGV,SYS,PIPE,ALRM,TERM,URG,STOP,TSTP,CONT,CHLD,TTIN,TTOU,IO,XCPU,XFSZ,VTALRM,PROF,WINCH,INFO,USR1,USR2} `seq 1 31 | tr '\n' ' '`
# }

# 
#  fs.
# 
# 
#         (fcuk sh!t)
# 

# cd() { builtin cd "$@"; ls -laFhu; }        # Always list directory contents upon 'cd'
function mcd() { mkdir -p "$1" && cd "$1"; }         # mcd:   Makes new Dir and jumps inside
function trash() { command mv "$@" ~/.Trash; }       # trash: Moves a file to the MacOS trash
function ql() { qlmanage -p "$*" >& /dev/null; }     # ql:    Opens any file in MacOS Quicklook Preview
function zipf () { zip -r "$1".zip "$1" ; }          # zipf:  Create a ZIP archive of a folder

#   mans:   Search manpage given in agument '1' for term given in argument '2' (case insensitive)
#           displays paginated result with colored search terms and two lines surrounding each hit.           
#           Example: mans mplayer codec
#   --------------------------------------------------------------------
function mans() {
	man $1 | grep -iC4 --color=always $2 | less # some flags would make this better
}

# showa: show alias -  to remind yourself of an alias (given some part of it)
function showa() { /usr/bin/grep --color=always -i -a1 $@ $ZSH_CUSTOM/*.zsh | grep -v '^\s*$' | less -FSRXNc ; }

# alias-finder shortcut
# alias finda='alias-finder -l'
#fa () { alias-finder -l $@ ; }

#   cdf:  'Cd's to frontmost window of MacOS Finder
#   ------------------------------------------------------
function cdf () {
    local currentFinderPath=$( /usr/bin/osascript <<EOT
        tell application "Finder"
            try
        set currFolder to (folder of the front window as alias)
            on error
        set currFolder to (path to desktop folder as alias)
            end try
            POSIX path of currFolder
        end tell
EOT
    )
    echo "cd to \"$currFinderPath\""
    cd "$currentFinderPath"
}

# flash terminal
function flasher () {
  while true; do
    printf "\e[?5h"
    sleep 0.2
    printf "\e[?5l"
    read -sk -t1 && break
  done
}

#s   extract:  Extract most know archives with one command
#   ---------------------------------------------------------
# extract () {
#     if [ -f $1 ] ; then
#       case $1 in
#         *.tar.bz2)   tar xjf $1     ;;
#         *.tar.gz)    tar xzf $1     ;;
#         *.bz2)       bunzip2 $1     ;;
#         *.rar)       unrar e $1     ;;
#         *.gz)        gunzip $1      ;;
#         *.tar)       tar xf $1      ;;
#         *.tbz2)      tar xjf $1     ;;
#         *.tgz)       tar xzf $1     ;;
#         *.zip)       unzip $1       ;;
#         *.Z)         uncompress $1  ;;
#         *.7z)        7z x $1        ;;
#         *)     echo "'$1' cannot be extracted via extract()" ;;
#       esac
#      else
#          echo "'$1' is not a valid file"
#      fi
# }

# ~~~~~~~~~~~~~~~~~~~~~~~~~ #
# #     #  # # # #  # # # # #	  
# # #   #  #			#	
# #  #  #  # # #		#	
# #   # #  #			#	
# #    ##  # # # #  	#		
# ~~~~~~~~~~~~~~~~~~~~~~~~~ #

# generate mac address
function macgen() { openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//' }
# set random mac for interface
function chmac() { openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//' | sudo xargs ifconfig $1 ether; }

# nmap aliases
function nmap.lan() { nmap -sn $@; }
function nmap.a() { nmap -v -A $1 }
function nmap.scan.all() { nmap -sS -v -A 1:65535; }

# projectdiscovery - subfinder: find subdomains
function subfd() { [[ $# -gt 0 ]] && \
	subfinder -silent -all ${@[0:-1]/#/-d } | \
	dnsx -silent -a -cname | \
	tee "${*[-1]}".txt
	# tee "${(j:-:u)@}".txt
}

# down network interfaces
function downif() {
	local ifaces=("ap1" "p2p0" "awdl0" "llw0" "utun0" "utun1" "utun2" "utun3" "XHC0" "XHC20" "gif0" "bridge0" "stf0")
	for iface in $ifaces; do
		sudo ipconfig set $iface NONE
	done
	for iface in $ifaces; do
		sudo ifconfig $iface down;
	done
	for iface in ("bridge0" "gif0"); do
		sudo ifconfig $iface destroy;
	done
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on --setstealthmode on\
		--setloggingmode on --setloggingopt detail --setblockall on --setallowsigned off --setallowsignedapp off;
	sudo /usr/libexec/airportd en0 prefs AWDLEnabled=NO DisableMultiChannelRanging=YES DisconnectOnLogout=YES\
		RequireAdminPowerToggle=YES RequireAdminIBSS=YES RequireAdminIBSS=YES JoinMode=Ranked P2PDevicesManaged=NO;
	# sudo pfctl -F states;
	sudo killall -HUP mDNSResponder mDNSResponderHelper;
}

# a terrible implementation of ping sweep, use nmap -sP 192.168.1.1/24 instead
function ping_sweep() { for x in {1..254..1}; do ping -c 1 $1.$x | grep "64 b"; done }

# myip() { curl 'https://icanhazip.com'; }
