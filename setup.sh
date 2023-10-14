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

#!/usr/bin/bash

user_id="$(id -u)"
if [ "$user_id" -ne 0 ]; then
  echo "(script) => Requires 'root' or 'sudo' privileges to run."
  exit 1
fi

_NALA="nala"
sh_c='sh -c'

pkgs=("curl" "wget" "zsh" "git" "vim" "exa" "fonts-jetbrains-mono"
      "fonts-inconsolata" "build-essential" "nmap" "hydra" "bat" "make" "tor"
      "fonts-firacode" "gh" "gpg")

nala_exists(){
  local bin_paths=("/usr/local/bin" "/usr/bin" "/bin")
  
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
  install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg

  $sh_c "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq code >/dev/null"
  echo "(Visual Studio code) => code installed"
}

install_nala() {
  $sh_c "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $_NALA >/dev/null"
  echo "(installed) => Nala installed successfully"
}

do_install() {
  nala_exists
  for pkg in "${pkgs[@]}"; do
    $_NALA install -y $pkg  
  done
  code_install
  echo "(all) => All packages has installed"
}

do_install

