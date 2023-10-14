# Meu Setup de Ambiente Linux

> Este é um script que automatiza a configuração do ambiente em um sistema Linux. Ele instala e configura vários programas e ferramentas úteis para desenvolvimento e produtividade.

## Pré-requisitos

- Linux (Debian 11/superior ou Ubuntu 20.04/superior)
- Permissões de superusuário (root ou sudo)

## Como Usar

1. Abra um terminal.

2. Execute o script usando o comando a seguir:

   ```bash
   sudo bash script.sh
   ```

3. O script irá solicitar o nome de usuário. Forneça o nome de usuário para configurar os aliases no arquivo `.zshrc`.

4. O script instalará e configurará os seguintes componentes:

   - Plugins do Zsh: `zsh-autosuggestion` e `zsh-syntaxhighlight` (instalados usando o gerenciador de pacotes `zinit`) :hourglass_flowing_sand:
   - Gerenciador de pacotes Node.js: `pnpm` :white_check_mark:
   - Oh-My-Zsh e tema Powerlevel10k :hourglass_flowing_sand:
   - Ferramentas e utilitários essenciais :white_check_mark:
   - Visual Studio Code :white_check_mark:
   - DBeaver :hourglass_flowing_sand:
   - Docker :hourglass_flowing_sand:
   - Insomnia :hourglass_flowing_sand:
   - PyCharm, IntelliJ IDEA e WebStorm :hourglass_flowing_sand:
   - GitHub CLI :hourglass_flowing_sand:
   - Versões específicas de Java, Node.js, Ruby, Python, Rust e Lua usando o ASDF Version Manager :hourglass_flowing_sand:

   O script verifica se os pacotes já estão instalados antes de instalá-los novamente. :hourglass_flowing_sand:

5. Após a execução do script, você pode verificar as configurações no arquivo `.zshrc` em seu diretório home.

**Observação:** Este script assume que você está executando em um ambiente Linux e tem as permissões necessárias para instalar os pacotes mencionados.

## Licença

Este projeto está licenciado sob a licença MIT. Consulte o arquivo [LICENSE](LICENSE) para obter mais detalhes.

## Contribuindo

1. Faça o _fork_ do projeto (<https://github.com/meiazero/setup-linux>) 
2. Crie uma _branch_ para sua modificação (`git checkout -b fooBar`)
3. Faça o _commit_ (`git commit -am 'Add some fooBar'`)
4. _Push_ (`git push origin fooBar`)
5. Crie um novo _Pull Request_


## Mantenedor

- [meiazero](https://github.com/meiazero)