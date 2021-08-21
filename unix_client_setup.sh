#!/bin/sh

###############################################################################
#
# unix_client_setup.sh - Initial setup for new unix like os.
#
# USAGE       :  init_setup.sh 
# DESCRIPTION :  Install below softwares
#                  - git
#                  - curl
#                  - ppdx999/dotfile
#                  - ppdx999/bin
#                  - ppdx999/format
#                  - shellshockccar
#                  - ffmpeg
#                  - GIMP
#                  - VIM
#                  - zoom
#                  - google-chrome
# 
# 
# Written by ppdx999 on 2020-08-21
# 
# 
# This is a public-domain software (CC0). It means that all of the
# people can use this for any purposes with no restrictions at all. 
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
# 
# For more information, please refer to <http://unlicense.org>
# 
###############################################################################


# === Initialize shell environment ===================================
set -u
umask 0022
export LC_ALL=C
type command >/dev/null 2>&1 && type getconf >/dev/null 2>&1 &&
export PATH="$(command -p getconf PATH)${PATH+:}${PATH-}"
export POSIXLY_CORRECT=1 # to make Linux comply with POSIX
export UNIX_STD=2003     # to make HP-UX comply with POSIX

# === Define the functions for printing usage and error message ======

error_exit() {
	echo "$0: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

print_usage_and_exit () {
  cat <<-USAGE_END 1>&2
	Usage   : ${0##*/} 
  DESCRIPTION :  Install below softwares
                   - git
                   - curl
                   - ppdx999/dotfile
                   - ppdx999/bin
                   - ppdx999/format
                   - shellshockccar
                   - ffmpeg
                   - GIMP
                   - VIM
                   - zoom
                   - google-chrome
USAGE_END
  exit 1
}


which which >/dev/null 2>&1 || {
  which() {
    command -v "$1" 2>/dev/null |
      awk '{if($0 !~ /^$/) print; ok=1;}
         END{if(ok==0){print "which: not found" > "/dev/stderr"; exit 1}}'
  }
}

# === Main for Setup  ================================================

if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    :
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    :
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

cd $HOME || error_exit "couldn't find home directory."

case "$OS" in
  Ubuntu* )
    sudo apt update
    ;;
  *)
    error_exit "Unsupported Distributin"
esac

if ! type git >/dev/null 2>&1; then
	case "$OS" in
		Ubuntu* )
			sudo apt-get install git	
			;;
		*)
			error_exit "Unsupported Distributin"
	esac
fi

if ! type curl >/dev/null 2>&1; then
	case "$OS" in
		Ubuntu* )
			sudo apt-get install curl
			;;
		*)
			error_exit "Unsupported Distributin"
	esac
fi

if [ ! -d $HOME/bin ]; then
	git clone https://github.com/ppdx999/bin.git
fi

if [ ! -d $HOME/dotfiles ]; then
	git clone https://github.com/ppdx999/dotfiles.git
	ln -sf $HOME/dotfiles/.vimrc $HOME/.vimrc
	ln -sf $HOME/dotfiles/.bashrc $HOME/.bashrc
	ln -sf $HOME/dotfiles/.vim $HOME/.vim
fi

if [ ! -d $HOME/format ]; then
	git clone https://github.com/ppdx999/format.git
fi

if [ ! -d $HOME/.local/lib ]; then
	mkdir -p $HOME/.local/lib
fi

if [ ! -d $HOME/.local/lib/shellshoccar/bin ]; then
	mkdir -p $HOME/code
	curl -f -L "https://raw.githubusercontent.com/ShellShoccar-jpn/installer/master/shellshoccar.sh" > $HOME/code/shellshoccar.sh
	chmod 764 $HOME/code/shellshoccar.sh
	$HOME/code/shellshoccar.sh --prefix=$HOME/.local/lib/shellshoccar install
fi

if ! type ffmpeg >/dev/null 2>&1; then
	case "$OS" in
		Ubuntu* )
			sudo apt-get install ffmpeg
			;;
		*)
			error_exit "Unknown Distributin"
	esac
fi

if ! type gimp >/dev/null 2>&1; then
	case "$OS" in
		Ubuntu* )
			sudo apt-get install gimp
			;;
		*)
			error_exit "Unknown Distributin"
	esac
fi

if ! type vim >/dev/null 2>&1; then
	case "$OS" in
		Ubuntu* )
			sudo apt-get install vim 
			;;
		*)
			error_exit "Unknown Distributin"
	esac
fi

if ! type zoom >/dev/null 2>&1; then
	case "$OS" in
		Ubuntu* )
      curl -f -L "http://zoom.us/client/latest/zoom_amd64.deb" > $HOME/Downloads/zoom_amd64.deb
      sudo apt install libgl1-mesa-glx libegl1-mesa libxcb-xtest0
			sudo apt install $HOME/Downloads/zoom_amd64.deb
			;;
		*)
			error_exit "Unknown Distributin"
	esac
fi

if ! type google-chrome >/dev/null 2>&1; then
	mkdir -p $HOME/Downloads
	case "$OS" in
		Ubuntu* )
			curl -f -L "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" > $HOME/Downloads/google-chrome-stable_current_amd64.deb
			sudo apt install $HOME/Downloads/google-chrome-stable_current_amd64.deb
			;;
		*)
			error_exit "Unknown Distributin"
	esac
fi

case "$OS" in
  Ubuntu* )
    sudo apt upgrade
    ;;
  *)
    error_exit "Unsupported Distributin"
esac
