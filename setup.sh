#!/bin/bash

set -e

# Função para exibir mensagens formatadas
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Função para instalar fontes necessárias
install_fonts() {
    log "Instalando fontes MesloLGS NF e JuliaMono..."

    # URLs das fontes MesloLGS NF
    local menslo=(
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
    )

    # URL da fonte JuliaMono
    local julia="https://github.com/cormullion/juliamono/releases/download/v0.055/JuliaMono-ttf.tar.gz"

    # Diretório de instalação das fontes
    local font_dir="$HOME/.local/share/fonts"
    mkdir -pv "$font_dir"

    # Download e instalação das fontes MesloLGS NF
    for url in "${menslo[@]}"; do
        file_name=$(basename "$url")
        log "Baixando $file_name..."
        wget -q "$url" -O "$font_dir/$file_name"
    done

    # Download e extração da fonte JuliaMono
    log "Baixando e extraindo JuliaMono..."
    wget -q "$julia" -O /tmp/JuliaMono-ttf.tar.gz
    tar -xzf /tmp/JuliaMono-ttf.tar.gz -C "$font_dir"

    # Remover arquivos temporários
    rm -f /tmp/JuliaMono-ttf.tar.gz

    # Atualizar o cache de fontes
    log "Atualizando cache de fontes..."
    sh -c "sudo fc-cache -fv"

    log "Fontes instaladas com sucesso."
}

# Função para verificar e instalar pacotes
install_packages() {
    local packages=("$@")
    log "Atualizando lista de pacotes"
    sh -c "sudo apt-get update -qq"

    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg"; then
            log "Instalando pacote: $pkg"
            sh -c "sudo apt-get install -y -qq $pkg"
        fi
    done
}

# Função para remover programas pré-instalados
remove_preinstalled_programs() {
    log "Removendo programas pré-instalados..."
    sh -c "sudo apt remove --purge -y gnome-chess gnome-games gnome-mahjongg gnome-maps gnome-mines gnome-music gnome-nibbles gnome-robots gnome-sudoku gnome-taquin gnome-tetravex gnome-weather cheese five-or-more aisleriot gnome-klotski hitori tali swell-foop four-in-a-row quadrapassel gnome-2048"
    sh -c "sudo apt autoclean -y"
    sh -c "sudo apt autopurge -y"
}

# Função para instalar Nala
install_nala() {
    if ! command -v nala &> /dev/null; then
        log "Nala não encontrado, instalando..."
        sh -c "sudo apt-get install -y nala"
    else
        log "Nala já está instalado."
    fi
}

# Função para instalar o VS Code
install_vscode() {
    if ! command -v code &> /dev/null; then
        log "Instalando Visual Studio Code..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sh -c "sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg"
        sh -c "sudo sh -c 'echo \"deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main\" > /etc/apt/sources.list.d/vscode.list'"
        sh -c "sudo apt-get update -qq"
        sh -c "sudo apt-get install -y code"
        rm -f packages.microsoft.gpg
    else
        log "Visual Studio Code já está instalado."
    fi
}

# Função para instalar o pnpm
install_pnpm() {
    if ! command -v pnpm &> /dev/null; then
        log "Instalando pnpm..."
        curl -fsSL https://get.pnpm.io/install.sh | sh -
        export PATH="$HOME/.local/share/pnpm:$PATH"
        sed -i '/^export PATH=.*\/pnpm/d' ~/.zshrc
        echo 'export PATH="$HOME/.local/share/pnpm:$PATH"' >> ~/.zshrc
    else
        log "pnpm já está instalado."
    fi
}

# Função para instalar o oh-my-zsh e plugins relacionados
install_zsh_plugins() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "Instalando oh-my-zsh..."
        RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    log "Instalando plugins zsh-autosuggestions e zsh-syntax-highlighting..."
    if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        rm -rf "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    fi
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        rm -rf "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    fi
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    log "Instalando powerlevel10k..."
    if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        rm -rf "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k"
    fi
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

    log "Configurando .zshrc..."
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
}

# Função para instalar o asdf e seus plugins
install_asdf() {
    if [ ! -d "$HOME/.asdf" ]; then
        log "Instalando asdf..."
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
        echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc
        source ~/.asdf/asdf.sh
    fi

    local plugins=(
        "java:openjdk-17.0.2 openjdk-21"
        "nodejs:18.18.1 20.8.0"
        "python:3.11 3.10 3.9"
        "rust:latest"
        "lua:latest"
    )

    log "Instalando plugins e versões do asdf..."
    for plugin in "${plugins[@]}"; do
        local plugin_name="${plugin%%:*}"
        local versions="${plugin#*:}"
        
        asdf plugin add $plugin_name || true
        
        # Remover todas as versões anteriores do plugin
        existing_versions=$(asdf list $plugin_name 2> /dev/null)
        if [ -n "$existing_versions" ]; then
            log "Removendo versões antigas do $plugin_name"
            for version in $existing_versions; do
                asdf uninstall $plugin_name $version
            done
        fi

        # Instalar novas versões
        for version in $versions; do
            asdf install $plugin_name $version
        done
    done
}

# Função para inserir alias no .zshrc
insert_alias() {
    read -p "Deseja inserir aliases no .zshrc? [y/n] " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        if [ -z "$username" ]; then
            log "Nenhum nome de usuário informado."
            exit 1
        fi

        local zshrc_path="/home/$username/.zshrc"
        if [ ! -f "$zshrc_path" ]; then
            log ".zshrc não encontrado para o usuário $username, criando arquivo."
            touch "$zshrc_path"
        fi

        cat << 'EOF' >> "$zshrc_path"
alias ls='EXA_ICON_SPACING=2 exa -lFGBha --icons --git'
alias cat=batcat
alias pn=pnpm

nd() {
    mkdir -p $1 && cd $1
}
EOF
        log "Aliases inseridos em $zshrc_path"
    else
        log "Nenhum alias será inserido."
    fi
}

# Função principal para a instalação
main() {
    read -p "Qual é o seu nome de usuário? " username

    remove_preinstalled_programs

    local packages=("curl" "wget" "zsh" "git" "vim" "papirus-icon-theme"
                    "exa" "fonts-jetbrains-mono" "fonts-inconsolata" "build-essential" "nmap" 
                    "bat" "make" "tor" "fonts-firacode" 
                    "gh" "gpg")

    install_packages "${packages[@]}"
    install_nala
    install_vscode
    install_fonts
    install_pnpm
    insert_alias
    install_zsh_plugins

    log "Instalação concluída."
}

main
