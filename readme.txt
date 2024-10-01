PedidoRESTful
Descri��o
Este projeto � uma API RESTful completa para a gest�o de pedidos, clientes e produtos. Ele inclui a cria��o autom�tica do banco de dados, exporta��o de dados em formato JSON e v�rias funcionalidades para administra��o de pedidos e itens. Al�m da API do servidor, h� tamb�m um cliente RESTful para consumir os endpoints e realizar opera��es.

Funcionalidades
Cria��o autom�tica do banco de dados: O sistema gera as tabelas automaticamente ao iniciar, caso elas ainda n�o existam.
Gest�o de Clientes: Permite listar, adicionar, atualizar e excluir clientes.
Gest�o de Produtos: Permite listar, adicionar, atualizar e excluir produtos.
Gest�o de Pedidos: Possibilidade de criar, listar, e gerenciar pedidos e seus itens.
Exporta��o de dados: Os dados s�o exportados em formato JSON, permitindo f�cil integra��o com outros sistemas.
Cliente RESTful: Cliente dispon�vel para consumir a API e testar funcionalidades de forma pr�tica.
Documenta��o Completa: Inclui documenta��o detalhada sobre a API, como endpoints, m�todos e exemplos de uso.
Estrutura do Projeto
ClientRESTful: Aplica��o cliente que consome a API.
ServidorRESTful: Aplica��o de servidor que hospeda a API e gerencia o banco de dados.
Documenta��o: Cont�m todos os detalhes de uso da API, incluindo endpoints, exemplos e fluxo de autentica��o.
SQL: Scripts SQL utilizados para gerenciamento do banco de dados.
MySQL Dump: Arquivo dump para restaura��o de um banco de dados com dados de exemplo.
Como Usar
Clone o reposit�rio para sua m�quina:

bash
Copiar c�digo
git clone https://github.com/seu-usuario/PedidoRESTful.git
Navegue at� a pasta do projeto:

bash
Copiar c�digo
cd PedidoRESTful/ServidorRESTful
Configure o arquivo server_config.ini para apontar para seu servidor MySQL.

Execute o servidor:

bash
Copiar c�digo
./ServidorRESTful.exe
Utilize a aplica��o cliente, localizada na pasta ClientRESTful, para interagir com a API.

Pr�-requisitos
Delphi: Ambiente de desenvolvimento para compilar as aplica��es cliente e servidor.
MySQL: Sistema de gerenciamento de banco de dados utilizado pelo sistema.
FireDAC: Biblioteca de acesso a dados utilizada para conectar com o banco MySQL.
Endpoints Principais
Clientes
GET /clientes: Lista todos os clientes.
POST /clientes: Cria um novo cliente.
Produtos
GET /produtos: Lista todos os produtos.
POST /produtos: Cria um novo produto.
Pedidos
GET /pedidos: Lista todos os pedidos.
POST /pedidos: Cria um novo pedido.
Estrutura do Banco de Dados
O banco de dados cont�m tr�s tabelas principais:

Clientes: Cont�m os dados dos clientes.
Produtos: Armazena os produtos dispon�veis.
Pedidos: Registra os pedidos e seus respectivos itens.
Contribui��es
Contribui��es s�o bem-vindas! Sinta-se � vontade para abrir issues e pull requests.

Licen�a
Este projeto est� sob a licen�a MIT.