case $- in
    *i*) ;;
      *) return;;
esac
alias home='cd ~'
alias cb='cd ..'
alias rm='rm -rf'
alias h='history'
alias j='jobs -l'
alias which='type -a'
alias calc="expr"
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias myip='curl http://api.ipify.org && printf "%b" "\n\n"'
alias netall='ss -natup'
alias netin='ss -pultan'
alias netudp='ss -nap -A udp'
alias nettcp='ss -nap -A tcp'
alias pingc='ping -n -i 0.2 -W1'
alias pingq='ping -c 5 -n -i 0.2 -W1'
alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'
alias xs='cd'
alias vf='cd'
alias moer='more'
alias moew='more'
alias kk='ll'
alias nnao='nano'
alias anno='nano'
alias bashrc='nano ~/.bashrc && . ~/.bashrc'
alias aptup='apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y'
alias install='sudo apt-get update && sudo apt-get install'
alias installsrc='sudo apt-get update && sudo apt-build install'
alias intsall='sudo apt-get update && sudo apt-get install'
alias intsallsrc='sudo apt-get update && sudo apt-build install'
alias back='cd ..'
alias grep='grep --color=auto --binary-files=without-match --devices=skip'
alias ls='ls -lh --color'
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.
alias ll="ls -lv --group-directories-first"
alias lm='ll |more'        #  Pipe through 'more'
alias lr='ll -R'           #  Recursive ls.
alias la='ll -A'           #  Show hidden files.
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls' ...
alias debug="set -o nounset; set -o xtrace"

function cd() {
    new_directory="$*";
    if [ $# -eq 0 ]; then 
        new_directory=${HOME};
    fi;
    builtin cd "${new_directory}" && ls -lah
}
function trout() {
    options="$*";
    if [ $# -eq 0 ]; then 
        options='--help';
    fi;
    builtin traceroute "${options}" '-w 3 -q 1 -N 32';
}

ulimit -S -c 0      # Don't want coredumps.
set -o notify
set -o noclobber
set -o ignoreeof
export LANG=en_US.UTF-8
if [ -f /etc/bashrc ]; then
      . /etc/bashrc   # --> Read /etc/bashrc, if present.
fi
if [ -f ~/.bashrcext ]; then
      source ~/.bashrcext   # --> Read if present.
fi
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -s extglob       # Necessary for programmable completion.
shopt -u mailwarn
unset MAILCHECK        # Don't want my shell to warn me of incoming mail.
TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
HISTIGNORE="&:bg:fg:ll:h"
HISTTIMEFORMAT="$(echo -e ${BCyan})[%d/%m %H:%M:%S]$(echo -e ${NC}) "
HOSTFILE=$HOME/.hosts    # Put a list of remote hosts in ~/.hosts
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
HISTSIZE=150
HISTFILESIZE=2000
shopt -s checkwinsize
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\eOA": history-search-backward'
bind '"\eOB": history-search-forward'


alias more='less'
export PAGER=less
export LESSCHARSET='latin1'
export LESSOPEN='|/usr/bin/lesspipe.sh %s 2>&-'
                # Use this if lesspipe.sh exists.
export LESS='-i -N -w  -z-4 -g -e -M -X -F -R -P%t?f%f \
:stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'
# LESS man page colors (makes Man pages more readable).
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#  Copyright Mike Stewart - http://MediaDoneRight.com
#  Modified by cynesiz and redundant commenting removed.
Color_Off="\[\033[0m\]"       
# Regular Colors
Black="\[\033[0;30m\]"       
Red="\[\033[0;31m\]"          
Green="\[\033[0;32m\]"        
Yellow="\[\033[0;33m\]"      
Blue="\[\033[0;34m\]"         
Purple="\[\033[0;35m\]"      
Cyan="\[\033[0;36m\]"         
White="\[\033[0;37m\]"               
# Bold
BBlack="\[\033[1;30m\]"       
BRed="\[\033[1;31m\]"         
BGreen="\[\033[1;32m\]"       
BYellow="\[\033[1;33m\]"    
BBlue="\[\033[1;34m\]"       
BPurple="\[\033[1;35m\]"      
BCyan="\[\033[1;36m\]"        
BWhite="\[\033[1;37m\]"             
# Underline
UBlack="\[\033[4;30m\]"       # Black
URed="\[\033[4;31m\]"         # Red
UGreen="\[\033[4;32m\]"       # Green
UYellow="\[\033[4;33m\]"      # Yellow
UBlue="\[\033[4;34m\]"        # Blue
UPurple="\[\033[4;35m\]"      # Purple
UCyan="\[\033[4;36m\]"        # Cyan
UWhite="\[\033[4;37m\]"       # White
UOrange="\[\033[4;40m\]"  
# Background
On_Black="\[\033[40m\]"       # Black
On_Red="\[\033[41m\]"         # Red
On_Green="\[\033[42m\]"       # Green
On_Yellow="\[\033[43m\]"      # Yellow
On_Blue="\[\033[44m\]"        # Blue
On_Purple="\[\033[45m\]"      # Purple
On_Cyan="\[\033[46m\]"        # Cyan
On_White="\[\033[47m\]"       # White
# High Intensty
IBlack="\[\033[0;90m\]"       # Black
IRed="\[\033[0;91m\]"         # Red
IGreen="\[\033[0;92m\]"       # Green
IYellow="\[\033[0;93m\]"      # Yellow
IBlue="\[\033[0;94m\]"        # Blue
IPurple="\[\033[0;95m\]"      # Purple
ICyan="\[\033[0;96m\]"        # Cyan
IWhite="\[\033[0;97m\]"       # White
# Bold High Intensty
BIBlack="\[\033[1;90m\]"      # Black
BIRed="\[\033[1;91m\]"        # Red
BIGreen="\[\033[1;92m\]"      # Green
BIYellow="\[\033[1;93m\]"     # Yellow
BIBlue="\[\033[1;94m\]"       # Blue
BIPurple="\[\033[1;95m\]"     # Purple
BICyan="\[\033[1;96m\]"       # Cyan
BIWhite="\[\033[1;97m\]"      # White
# High Intensty backgrounds
On_IBlack="\[\033[0;100m\]"   # Black
On_IRed="\[\033[0;101m\]"     # Red
On_IGreen="\[\033[0;102m\]"   # Green
On_IYellow="\[\033[0;103m\]"  # Yellow
On_IBlue="\[\033[0;104m\]"    # Blue
On_IPurple="\[\033[10;95m\]"  # Purple
On_ICyan="\[\033[0;106m\]"    # Cyan
On_IWhite="\[\033[0;107m\]"   # White
# Various variables you might want for your PS1 prompt instead
Time12h="\T"
Time12a="\@"
PathShort="\w"
PathFull="\W"
NewLine="\n"
Jobs="\j"
NC="\e[m"               # Color Reset
ALERT=${BWhite}${On_Red} # Bold White on red background

KARCH=$(uname -r)
if [ -f /etc/debian_version ]; then
    OS="Debian GNU/Linux"  # XXX or Ubuntu??
    VER=$(cat /etc/debian_version)
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
else
    OS=$(uname -s)
    VER=$(uname -r)
fi
echo -e "${BCyan}This is ${OS} ${BRed}${VER}${BCyan}\
-  on ${BRed}$(hostname --fqdn)${NC}\n"
date
echo
function _exit()              # Function to run upon exit of shell.
{
    echo -e "${BRed}Exiting...${NC}"
}
trap _exit EXIT

function aa_prompt_defaults ()
{
   local colors=`tput colors 2>/dev/null||echo -n 1` C=;
 
   if [[ $colors -ge 256 ]]; then
      C="`tput setaf 33 2>/dev/null`";
      AA_P='mf=x mt=x n=0; while [[ $n < 1 ]];do read a mt a; read a mf a; (( n++ )); done</proc/meminfo; export AA_PP="\033[38;5;2m"$((mf/1024))/"\033[38;5;89m"$((mt/1024))MB; unset -v mf mt n a';
   else
      C="`tput setaf 4 2>/dev/null`";
      AA_P='mf=x mt=x n=0; while [[ $n < 1 ]];do read a mt a; read a mf a; (( n++ )); done</proc/meminfo; export AA_PP="\033[92m"$((mf/1024))/"\033[32m"$((mt/1024))MB; unset -v mf mt n a';
   fi;
 
   eval $AA_P; 
 
   PROMPT_COMMAND='stty echo; history -a; echo -en "\e[34h\e[?25h"; (($SECONDS % 2==0 )) && eval $AA_P; echo -en "$AA_PP";';
   SSH_TTY=${SSH_TTY:-`tty 2>/dev/null||readlink /proc/$$/fd/0 2>/dev/null`}
 
   export PS1 AA_P PROMPT_COMMAND SSH_TTY
}

#PS1="\n\[\e[1;30m\][$$:$PPID - \j:\!\[\e[1;30m\]]\[\e[0;36m\] \T \[\e[1;30m\][\[\e[1;34m\]\u@\H\[\e[1;30m\]:\[\e[0;37m\]${SSH_TTY:-o} \[\e[0;32m\]+${SHLVL}\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "

PS1="\n\[\e[1;30m\][\T]\[\e[1;30m\][\[\e[1;34m\]\u@\H\[\e[1;30m\]:\[\e[0;37m\]${SSH_TTY:-o} \[\e[0;32m\]+${SHLVL}\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "



function cdroot()
{
  while [[ $PWD != '/' && ${PWD##*/} != 'httpdocs' ]]; do cd ..; done
}
upto ()
{
    if [ -z "$1" ]; then
        return
    fi
    local upto=$1
    cd "${PWD/\/$upto\/*//$upto}"
}
_upto()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local d=${PWD//\//\ }
    COMPREPLY=( $( compgen -W "$d" -- "$cur" ) )
}
complete -F _upto upto
jd(){
    if [ -z "$1" ]; then
        echo "Usage: jd [directory]";
        return 1
    else
        cd **"/$1"
    fi
}
mcd()
{
    test -d "$1" || mkdir "$1" && cd "$1"
}         
function up {
ups=""
for i in $(seq 1 $1)
do
        ups=$ups"../"
done
cd $ups
}
dirsize ()
{
du -shx * .[a-zA-Z0-9_]* 2> /dev/null | \
egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
egrep '^ *[0-9.]*M' /tmp/list
egrep '^ *[0-9.]*G' /tmp/list
rm -rf /tmp/list
}

# Copyright Jintin - https://github.com/Jintin/aliasme
# added to auto create directory -cyn
if [[ ! -e ~/.aliasme ]]; then
    mkdir -p ~/.aliasme
    echo "Created directory ~/.aliasme"
fi
_list() {
	while read name
	do
		read value
		echo "$name : $value"
	done < ~/.aliasme/list
}
_add() {
	#read name
	name=$1
	if [ -z $1 ]; then
		read -ep "Input name to add:" name
	fi

	#read path
	path_alias=$2
	if [ -z $2 ]; then
		read -ep "Input path to add:" path_alias
	fi
	path_alias=$(cd $path_alias;pwd)

	echo $name >> ~/.aliasme/list
	echo $path_alias >> ~/.aliasme/list

	_autocomplete
}
_remove() {
	#read name
	name=$1
	if [ -z $1 ]; then
		read -pr "Input name to remove:" name
	fi
	touch ~/.aliasme/listtemp
	# read and replace file
	while read line
	do
		if [ $line = $name ]; then
			read line #skip one more line
		else
			echo $line >> ~/.aliasme/listtemp
		fi
	done < ~/.aliasme/list
	mv ~/.aliasme/listtemp ~/.aliasme/list
	_autocomplete
}
_jump() {
	while read line
	do
		if [ $1 = $line ]; then
			read line
			cd $line
			return
		fi
	done < ~/.aliasme/list
	echo "not found"
}
_bashauto()
{
	local cur prev opts
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	opts=""
	while read line
	do
		opts+=" $line"
		read line
	done < ~/.aliasme/list
	COMPREPLY=( $(compgen -W "${opts}" ${cur}) )
	return 0
}
_autocomplete()
{
	if [ $ZSH_VERSION ]; then
		# zsh
		opts=""
		while read line
		do
			opts+="$line "
			read line
		done < ~/.aliasme/list
		compctl -k "($opts)" al
	else
		# bash
		complete -F _bashauto al
	fi
}
_autocomplete
al(){
	if [ ! -z $1 ]; then
		if [ $1 = "ls" ]; then
			_list
		elif [ $1 = "add" ]; then
			_add $2 $3
		elif [ $1 = "rm" ]; then
			_remove $2
		elif [ $1 = "-h" ]; then
			echo "Usage:"
			echo "al add [name] [value]        # add alias with name and value"
			echo "al rm [name]                 # remove alias by name"
			echo "al ls                        # alias list"
			echo "al [name]                    # execute alias associate with [name]"
			echo "al -v                        # version information"
			echo "al -h                        # help"
		elif [ $1 = "-v" ]; then
			echo "aliasme 1.1.2"
			echo "visit https://github.com/Jintin/aliasme for more information"
		else
			_jump $1
		fi
	fi
}



