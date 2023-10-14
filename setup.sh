#!/bin/bash

# TODO: Fazer a instalação dos plugins zsh-autosuggestion e zsh-syntaxhighlight, 
# TODO: pnpm
# TODO: oh-my-zsh e powerlevel10k, 
# TODO: asdf com os plugins de java(openjdk17 e openjdk21), nodejs(18.18.1 e 20.8.0), ruby latest, python(3.11, 3.10, 3.9), rust latest, lua latest
# TODO: instalar vscode
# TODO: instalar dbeaver
# TODO: instalar docker
# TODO: instalar insonminia
# TODO: instalar pycharm, intelij, webstorm
# TODO: instalar configurar github cli
# TODO: verificar se os pacotes já estão instalados antes de instalar


# user_id="$(id -u)"
# if [ "$user_id" -ne 0 ]; then
#   echo "(script) => Requires 'root' or 'sudo' privileges to run."
#   exit 1
# fi

_NALA="nala"
sh_c='sh -c'

pkgs=("curl" "wget" "zsh" "git" "vim" 
      "exa" "fonts-jetbrains-mono" "fonts-inconsolata" "build-essential" "nmap" 
      "hydra" "bat" "make" "tor" "fonts-firacode" 
      "gh" "gpg")

plugins=("nodejs" "python" "ruby" "rust" "lua" "java")

alias="# Alias section
alias ls='EXA_ICON_SPACING=2 exa -lFGBha --icons --git'
alias cat=batcat
alias pn=pnpm

# The nd is a commando to create a new directory and enter in it
nd() {
  mkdir -p \$1 && cd \$1
}
"

read -p "What's your username? " username

nala_exists(){
  local bin_paths=("/usr/local/bin" "/usr/bin" "/bin")
  nala_exists=0
  
  for path in "${bin_paths[@]}"; do
    if [[ -x "$path/nala" ]]; then
      nala_exists=1
      break
    fi
  done

  if [ "$nala_exists" -eq 1 ]; then
    echo "(instaled) => Nala exists in the system."   
  else
    echo "(installed) => Instaling nala in $path"
    install_nala
  fi
}

code_install(){
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg

  $sh_c "DEBIAN_FRONTEND=noninteractive sudo apt-get install -y -qq code >/dev/null"
  echo "(Visual Studio code) => code installed"
}

install_nala() {
  $sh_c "DEBIAN_FRONTEND=noninteractive sudo apt-get install -y -qq $_NALA >/dev/null"
  echo "(installed) => Nala installed successfully"
}

insert_alias(){
  read -p "Would you like to insert some aliases in .zshrc? [y/n] " answer
  case $answer in
    Y|y|yes)
      if [ -z "$username" ]; then
        echo "(alias) => No username was informed"
        exit 1
      fi
      
      if ! file_path=$(find "/home/$username" -type f -name ".zshrc"); then
        echo "(alias) => .zshrc not found for user $username"
        exit 1
      fi

      if [ ! -e "$file_path" ]; then
        file_path="/home/$username/.zshrc"
        echo "(alias) => .zshrc not found for user $username, using default path"
      fi
    
      read -p "Where is your .zshrc file? (default in '$file_path') " path
      if [ ! -e "$file_path" ]; then
        echo "(alias) => .zshrc not found for user $username"
        exit 1
      else
        if [ -z "$path" ]; then
          echo "(alias) => No path was informed, using default"
          echo "$alias" >> "$file_path"
          echo "(alias) => Inserting some alias in $file_path"
        else
          echo "$alias" >> "$path"
          echo "(alias) => Inserting some alias in $path"
        fi
      fi
      ;;
    N|n|no)
      echo "(alias) => Ok, no alias will be inserted"
      ;;
    *)
      echo "(alias) => Invalid option"
      exit 1
      ;;
  esac
}

pnpm_install(){
  local pnpm_path="/home/$username/.pnpm"
  mkdir -pm 777 $pnpm_path
  if [ -x "$(command -v pnpm)" ]; then
    echo "(pnpm) => pnpm already installed"
  else
    echo "(pnpm) => Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | PNPM_HOME=$pnpm_path sh - >>/dev/null
    echo "(pnpm) => pnpm installed on $pnpm_path"
  fi
}

add_asdf_plugins(){
  for plugin in "${plugins[@]}"; do
    echo "(asdf) => Adding plugin: $plugin" 
    asdf plugin add $plugin >>/dev/null
  done
}

asdf_install(){
  echo "(asdf) => Installing asdf..."
  git clone https://github.com/asdf-vm/asdf.git /home/$username/.asdf --branch v0.13.1 --quiet >>/dev/null

  echo "(asdf) => asdf installed"
  echo "
# asdf configuration

. '/home/$username/.asdf/asdf.sh'

# append completions to fpath
fpath=(\${ASDF_DIR}/completions \$fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

# asdf configuration end
" >> /home/$username/.zshrc
  echo "(asdf) => asdf configured"
  echo "(asdf) => Adding plugins"
  # TOFIX: plugin installation  
  add_asdf_plugins

  chown -R $username:$username /home/$username/.asdf/
}

do_install() {
  echo "(all) => Starting installation"
  echo "(all) => Updating apt before install nala"
  $sh_c "DEBIAN_FRONTEND=noninteractive sudo apt-get update -qq >/dev/null"

  nala_exists
 for pkg in "${pkgs[@]}"; do
    sudo $_NALA install -y $pkg  
  done
  code_install
  asdf_install
  pnpm_install
  insert_alias
  echo "(all) => All packages has installed"
}

# do_install
asdf_install