PedidoRESTful
Descrição
Este projeto é uma API RESTful completa para a gestão de pedidos, clientes e produtos. Ele inclui a criação automática do banco de dados, exportação de dados em formato JSON e várias funcionalidades para administração de pedidos e itens. Além da API do servidor, há também um cliente RESTful para consumir os endpoints e realizar operações.

Funcionalidades
Criação automática do banco de dados: O sistema gera as tabelas automaticamente ao iniciar, caso elas ainda não existam.
Gestão de Clientes: Permite listar, adicionar, atualizar e excluir clientes.
Gestão de Produtos: Permite listar, adicionar, atualizar e excluir produtos.
Gestão de Pedidos: Possibilidade de criar, listar, e gerenciar pedidos e seus itens.
Exportação de dados: Os dados são exportados em formato JSON, permitindo fácil integração com outros sistemas.
Cliente RESTful: Cliente disponível para consumir a API e testar funcionalidades de forma prática.
Documentação Completa: Inclui documentação detalhada sobre a API, como endpoints, métodos e exemplos de uso.
Estrutura do Projeto
ClientRESTful: Aplicação cliente que consome a API.
ServidorRESTful: Aplicação de servidor que hospeda a API e gerencia o banco de dados.
Documentação: Contém todos os detalhes de uso da API, incluindo endpoints, exemplos e fluxo de autenticação.
SQL: Scripts SQL utilizados para gerenciamento do banco de dados.
MySQL Dump: Arquivo dump para restauração de um banco de dados com dados de exemplo.
Como Usar
Clone o repositório para sua máquina:

bash
Copiar código
git clone https://github.com/seu-usuario/PedidoRESTful.git
Navegue até a pasta do projeto:

bash
Copiar código
cd PedidoRESTful/ServidorRESTful
Configure o arquivo server_config.ini para apontar para seu servidor MySQL.

Execute o servidor:

bash
Copiar código
./ServidorRESTful.exe
Utilize a aplicação cliente, localizada na pasta ClientRESTful, para interagir com a API.

Pré-requisitos
Delphi: Ambiente de desenvolvimento para compilar as aplicações cliente e servidor.
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
O banco de dados contém três tabelas principais:

Clientes: Contém os dados dos clientes.
Produtos: Armazena os produtos disponíveis.
Pedidos: Registra os pedidos e seus respectivos itens.
Contribuições
Contribuições são bem-vindas! Sinta-se à vontade para abrir issues e pull requests.

Licença
Este projeto está sob a licença MIT.