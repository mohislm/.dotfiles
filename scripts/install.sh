# Get the absolute path where the script resides
BASEDIR="$( cd "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" && pwd )"

# This is a general-purpose function to ask Yes/No questions in Bash, either
# with or without a default answer. It keeps repeating the question until it
# gets a valid answer.
ask() {
  while true; do

    if [ "${2:-}" = "Y" ]; then
      prompt="Y/n"
      default=Y
    elif [ "${2:-}" = "N" ]; then
      prompt="y/N"
      default=N
    else
      prompt="y/n"
      default=
    fi

    # Ask the question
    read -p "$1 [$prompt] " REPLY

    # Default?
    if [ -z "$REPLY" ]; then
      REPLY=$default
    fi

    # Check if the reply is valid
    case "$REPLY" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac

  done
}

# Copy a file from source to destination with a safe backup
# Syntax: safe_copy <src> <dst>
safe_copy() {
  # if file exists create backup first
  if [ -f "$2" ]; then
    cp $2 $2.bak
  fi
  cp $1 $2
}

setup_vim() {
  vimdir=$HOME/.vim

  if [ -d "$vimdir" ]; then
    echo ""
    if ! ask "This will remove the .vim directory. Continue?" Y; then
      exit
    fi
  fi

  rm -rf $vimdir

  echo -e "\n$(tput setaf 7)Installing Vundle...$(tput sgr 0)"
  git clone https://github.com/gmarik/Vundle.vim $vimdir/bundle/vundle.vim

  # Install plugins
  echo -e "\n$(tput setaf 7)Installing vim plugins...$(tput sgr 0)"
  vim +PluginInstall +qall &> /dev/null
}

# Copy all dotfiles to $HOME
copy_dotfiles() {
  echo -e "\n$(tput setaf 7)Copying all dotfiles...$(tput sgr 0)"
  declare -a arr=(
    ".bash_profile"
    ".bashrc"
    ".vimrc"
    ".gitconfig"
    ".gitignore_global"
  )
  for i in "${arr[@]}"; do
    safe_copy $BASEDIR/$i $HOME/$i
  done
}

main() {
  copy_dotfiles
  setup_vim
}

main
echo -e "\n$(tput setaf 2)Done$(tput sgr 0)\n"
