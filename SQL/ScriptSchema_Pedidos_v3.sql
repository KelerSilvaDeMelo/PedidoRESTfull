-- MySQL 5.6
-- InnoDB

-- Criar banco de dados 'pedidosDB'
CREATE DATABASE pedidosDB;
USE pedidosDB;

-- Tabela de clientes
CREATE TABLE clientes (
    codigo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(70),
    cidade VARCHAR(35),
    uf CHAR(2)
);

-- Tabela de produtos
CREATE TABLE produtos (
    codigo INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(90),
    preco_venda DECIMAL(10, 2)
);

-- Tabela de pedidos
CREATE TABLE pedidos (
    numero_pedido INT AUTO_INCREMENT PRIMARY KEY,
    data_emissao DATE,
    codigo_cliente INT,
    valor_total DECIMAL(10, 2),
    FOREIGN KEY (codigo_cliente) REFERENCES clientes(codigo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabela de itens de pedidos
CREATE TABLE pedido_itens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_pedido INT,
    codigo_produto INT,
    quantidade DECIMAL(10, 4),  -- Suporte para itens pesáveis e precisões diferentes
    valor_unitario DECIMAL(10, 2),
    valor_total DECIMAL(10, 2),
    FOREIGN KEY (numero_pedido) REFERENCES pedidos(numero_pedido)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (codigo_produto) REFERENCES produtos(codigo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Define os índices
CREATE INDEX idx_codigo_cliente ON pedidos(codigo_cliente);
CREATE INDEX idx_codigo_produto ON pedido_itens(codigo_produto);

-- Popula a tabela "CLIENTES" com 20 registros
INSERT INTO clientes (nome, cidade, uf)
VALUES
('João Silva', 'São Paulo', 'SP'),
('Maria Souza', 'Rio de Janeiro', 'RJ'),
('Carlos Lima', 'Belo Horizonte', 'MG'),
('Ana Pereira', 'Curitiba', 'PR'),
('Bruno Mendes', 'Fortaleza', 'CE'),
('Clara Oliveira', 'Salvador', 'BA'),
('Pedro Alves', 'Manaus', 'AM'),
('Lucas Rocha', 'Porto Alegre', 'RS'),
('Larissa Dias', 'Recife', 'PE'),
('Rafael Santos', 'Brasília', 'DF'),
('Beatriz Moura', 'Belém', 'PA'),
('Gabriel Nunes', 'Florianópolis', 'SC'),
('Fernanda Lima', 'Natal', 'RN'),
('Eduardo Silva', 'Goiânia', 'GO'),
('Mariana Ribeiro', 'Vitória', 'ES'),
('Vinícius Costa', 'Campo Grande', 'MS'),
('Roberta Martins', 'Maceió', 'AL'),
('Guilherme Sousa', 'João Pessoa', 'PB'),
('Jéssica Cardoso', 'Aracaju', 'SE'),
('Renato Farias', 'Teresina', 'PI');

-- Popula a tabela "PRODUTOS" com 20 registros
INSERT INTO produtos (descricao, preco_venda)
VALUES
('Camiseta', 50.00),
('Boné', 25.00),
('Sapato', 120.50),
('Relógio', 199.99),
('Mochila', 150.00),
('Calça Jeans', 80.00),
('Óculos de Sol', 99.99),
('Chinelo', 20.00),
('Carteira de Couro', 60.00),
('Jaqueta', 250.00),
('Bermuda', 45.00),
('Tênis', 300.00),
('Cinto de Couro', 40.00),
('Sandália', 70.00),
('Blusa', 55.00),
('Chapéu', 35.00),
('Casaco', 180.00),
('Meia', 10.00),
('Gravata', 25.50),
('Brinco', 15.00);

-- Popula a tabela "PEDIDOS"

-- Cadastro o pedido
INSERT INTO pedidos (data_emissao, codigo_cliente, valor_total)
VALUES ('2024-09-29', 1, 150.00);

-- Memoriza o ID do pedido
SET @pedido_id = LAST_INSERT_ID();

-- Cadastra os itens do pedido memorizado
INSERT INTO pedido_itens (numero_pedido, codigo_produto, quantidade, valor_unitario, valor_total)
VALUES
(@pedido_id, 1, 2.0000, 50.00, 100.00),  -- Camiseta
(@pedido_id, 2, 1.0000, 50.00, 50.00);   -- Boné

-- Confirmar transação
COMMIT;

-- DROP DATABASE IF EXISTS pedidosDB;