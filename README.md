# Project Unknown — Mais jogadores

Mod experimental para criar salas com até 8 pessoas e permitir que mais de uma pessoa escolha o mesmo personagem.

## O que vem neste repositório

- mod/ProjectUnknown-Windows_P.pak: pacote do mod v2.
- instalador/: instalador e desinstalador para Windows.

Não é necessário baixar um RAR nem um autoextraível. No GitHub, use **Code → Download ZIP** (ou clone o repositório); o ZIP do próprio GitHub contém as pastas necessárias.

## Instalação

Faça estes passos em **cada computador** que vai participar:

1. Feche o Project Unknown.
2. Baixe o repositório pelo botão **Code → Download ZIP** e extraia o ZIP inteiro para uma pasta. Não mova os arquivos de dentro de mod/ ou instalador/ separadamente.
3. Abra a pasta instalador e execute **Instalar.bat**.
4. Confirme a solicitação do Windows para executar como administrador. O instalador procura a biblioteca Steam e copia o PAK para a pasta do jogo.
5. Aguarde a mensagem de instalação concluída e reinicie o jogo.

Se o jogo estiver em uma biblioteca que o instalador não localizar, abra o PowerShell como administrador na pasta extraída e rode:

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\instalador\Instalar.ps1" -GameRoot "C:\Program Files (x86)\Steam\steamapps\common\Beast Management"
~~~

Troque o caminho de -GameRoot pelo local da pasta Beast Management no seu computador.

## Para jogar em grupo

- Todos os participantes, inclusive o host, precisam instalar o mesmo PAK v2 para a seleção de personagens repetidos funcionar.
- O host cria a sala. O limite deste pacote é **8 jogadores no total, contando o host**.
- Por padrão, o instalador configura o limite para 8. Para usar menos, abra o PowerShell como administrador na pasta do repositório e rode o comando abaixo. Troque 6 por qualquer valor de 5 a 8.

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\instalador\Instalar.ps1" -MaxPlayers 6
~~~

## Desinstalação

Feche o jogo e execute instalador/Desinstalar.bat em cada computador onde quiser remover o mod. O desinstalador restaura o PAK anterior se havia um backup e remove a configuração MaxPlayers adicionada pelo mod. O arquivo de backup original do Game.ini é mantido.

## Observações

Este mod é experimental. O pacote v2 foi conferido estaticamente, mas a instalação precisa ser validada em uma partida real com todos os participantes. Uma atualização do jogo pode torná-lo incompatível.
