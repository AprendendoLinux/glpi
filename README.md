<h1>Implantando o GLPI com o Docker </h1>

**Prezados colegas,**

Saudações pinguianas para todos!

Para facilitar a vida de muita gente, criei uma imagem docker para o GLPI. Nela você pode definir através de variáveis, a versão desejada e o timezone.

Partirei do do suposto que você já tenha o docker instalado e configurado, mas caso não tenha, instale-o com a ajuda da [**documentação oficial**](https://docs.docker.com/engine/install/).

<h3>Preparando o ambiente para usar a imagem: </h3>

~~~bash
docker volume create mariadb && docker volume create glpi
 ~~~

<h3>Subindo o contêiner do banco de dados (necessário para o GLPI funcionar):</h3>

~~~bash
docker run -d --name='mariadb' \
     --hostname='mariadb' \
     -e MARIADB_ROOT_PASSWORD='senhaderootmariadb' \
     -e MARIADB_DATABASE='glpi' \
     -e MARIADB_USER='glpi' \
     -e MARIADB_PASSWORD='senhadousuarioglpi' \
     -v mariadb:/var/lib/mysql \
--restart=always mariadb:latest
~~~

Explicando as variáveis:

Variável | Função
:---: | :---:
MARIADB_ROOT_PASSWORD | Define a senha de root do MySQL
MARIADB_DATABASE | Cria o banco de dados para o GLPI
MARIADB_USER | Cria o usuário do banco de dados do GLPI
MARIADB_PASSWORD | Cria a senha para o banco de dados do GLPI

Esse comando sobe o **MariaDB Server** com a senha de root **_senhaderootmariadb_,**  cria um banco de dados chamado **_glpi_**, com o usuário **_glpi_** e senha **_senhadousuarioglpi_**.

<h3>Subindo o contêiner do GLPI</h3>

~~~bash
docker run -d --name='glpi' \
     --hostname='glpi' \
     --link='mariadb:mariadb' \
     -e TIMEZONE='America/Sao_Paulo' \
     -e VERSION='10.0.2' \
     -e UPLOAD_MAX_FILESIZE='50M' \
     -e POST_MAX_FILESIZE='30M' \
     -v glpi:/var/www/html \
     -p 80:80 \
--restart=always aprendendolinux/glpi:latest
~~~

Explicando as variáveis:

Variável | Função
:---: | :---:
TIMEZONE | Define a [**TimeZone**](https://www.php.net/manual/pt_BR/timezones.php) do GLPI
VERSION | Define a [**versão**](https://github.com/glpi-project/glpi/releases/) desejada do GLPI
UPLOAD_MAX_FILESIZE | Tamanho máximo do anexo (o padrão é 2 megas)
POST_MAX_FILESIZE | Tamanho máximo do post (o padrão é 8 megas)

Também é possível iniciar a partir de um arquivo **docker-composer.yml**. Segue o conteúdo abaixo:
~~~~composer
version: "3.7"

services:

  mariadb:
    image: mariadb:latest
    restart: always
    container_name: mariadb
    environment:
      MARIADB_ROOT_PASSWORD: 'senhaderootmariadb'
      MARIADB_DATABASE: 'glpi'
      MARIADB_USER: 'glpi'
      MARIADB_PASSWORD: 'senhadousuarioglpi'
    volumes:
    - mariadb:/var/lib/mysql
    ports:
    - "3306:3306"
  
  glpi:
    image: aprendendolinux/glpi
    restart: always
    depends_on:
      - mariadb
    links:
      - "mariadb:mariadb"
    container_name: glpi
    environment:
      TIMEZONE: "America/Sao_Paulo"
      VERSION: 10.0.2
      UPLOAD_MAX_FILESIZE: 100M
      POST_MAX_FILESIZE: 50M
    volumes:
      - glpi:/var/www/html
    ports:
      - "80:80"
volumes:
  mariadb:
  glpi:
~~~~

<h3>Agora o GLPI encontra-se pré instalado. Vamos acessa-lo para finalizar as configurações:</h3>

<http://127.0.0.1/> ou <http://ip-do-servidor/>

Quando chegar na tela de configuração do banco de dados, entre com essas informações:

**Endereço do Servidor SQL:** `mariadb` \
**Usuário SQL:** `glpi` \
**Senha SQL:** `senhadousuarioglpi`

Ficará desse jeito:

![](https://temporario.aprendendolinux.com/pic_docker_hub/glpi.jpg "Credenciais do banco de dados do GLPI")

Na próxima tela, selecione o banco de dados **"glpi"** e avance.

Ao fim da instalação, logue com um dos usuários padrões:

_Usuário_ | _Senha_ | _Função_
:----:|:---:|:---:
`glpi` | `glpi` | Super Administrador
`tech` | `tech` | Conta do Técnico
`normal` | `normal` | Conta do Usuário
`post-only` | `postonly` | Conta somente para postar

A sugestão é que se faça o primeiro login com o usuário **glpi** e altere a senha de todos os usuários.

Para suporte comercial, entre em contato por [e-mail](mailto:henrique@henrique.tec.br "henrique@henrique.tec.br"), [telegram](https://t.me/HenriqueFagundes "@HenriqueFagundes") ou [whatsapp](https://web.whatsapp.com/send?phone=5521981176211 "Henrique Fagundes").

<h4>Acesse meu site:</h4>

<https://www.henrique.tec.br>
