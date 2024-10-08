object wmServerPedido: TwmServerPedido
  OnCreate = WebModuleCreate
  OnDestroy = WebModuleDestroy
  Actions = <
    item
      MethodType = mtGet
      Name = 'APIStatus'
      PathInfo = '/APIStatus'
      OnAction = wmServerPedidoAPIStatusAction
    end
    item
      Default = True
      Name = 'DefaultHandler'
      PathInfo = '/'
      OnAction = WebModule1DefaultHandlerAction
    end
    item
      MethodType = mtGet
      Name = 'ListaClientes'
      PathInfo = '/ListaClientes'
      OnAction = wmServerPedidoListaClientesAction
    end
    item
      MethodType = mtGet
      Name = 'ListaProdutos'
      PathInfo = '/ListaProdutos'
      OnAction = WebModule1ListaProdutosAction
    end
    item
      MethodType = mtGet
      Name = 'ListaPedidos'
      PathInfo = '/ListaPedidos'
      OnAction = WebModule1ListaPedidosAction
    end
    item
      MethodType = mtPost
      Name = 'InserePedido'
      PathInfo = '/InserePedido'
      OnAction = WebModule1InserePedidoAction
    end
    item
      MethodType = mtPost
      Name = 'AdicionaItemAoPedido'
      PathInfo = '/AdicionaItemAoPedido'
      OnAction = WebModule1AdicionaItemAoPedidoAction
    end
    item
      MethodType = mtGet
      Name = 'BuscaPedido'
      PathInfo = '/BuscaPedido'
      OnAction = wmServerPedidoBuscaPedidoAction
    end
    item
      MethodType = mtGet
      Name = 'BuscaItensDoPedido'
      PathInfo = '/BuscaItensDoPedido'
      OnAction = wmServerPedidoBuscaItensDoPedidoAction
    end
    item
      MethodType = mtDelete
      Name = 'ExcluiPedido'
      PathInfo = '/ExcluiPedido'
      OnAction = wmServerPedidoExcluiPedidoAction
    end>
  Height = 204
  Width = 424
  object cnPedidoDB: TFDConnection
    Params.Strings = (
      'DriverID=MySQL')
    Left = 48
    Top = 24
  end
  object MySQLDriverLink: TFDPhysMySQLDriverLink
    VendorLib = 'C:\Provas\WK Tecnology\ServidorRESTfull\Win32\Debug\libmysql.dll'
    Left = 168
    Top = 24
  end
  object sqlCriaPedidoDB: TFDScript
    SQLScripts = <
      item
        Name = 'CriaPedidoDB'
        SQL.Strings = (
          '-- MySQL 5.6'
          '-- InnoDB'
          ''
          '-- Criar banco de dados '#39'pedidosDB'#39
          'CREATE DATABASE pedidosDB;'
          'USE pedidosDB;'
          ''
          '-- Tabela de clientes'
          'CREATE TABLE clientes ('
          '    codigo INT AUTO_INCREMENT PRIMARY KEY,'
          '    nome VARCHAR(70),'
          '    cidade VARCHAR(35),'
          '    uf CHAR(2)'
          ');'
          ''
          '-- Tabela de produtos'
          'CREATE TABLE produtos ('
          '    codigo INT AUTO_INCREMENT PRIMARY KEY,'
          '    descricao VARCHAR(90),'
          '    preco_venda DECIMAL(10, 2)'
          ');'
          ''
          '-- Tabela de pedidos'
          'CREATE TABLE pedidos ('
          '    numero_pedido INT AUTO_INCREMENT PRIMARY KEY,'
          '    data_emissao DATE,'
          '    codigo_cliente INT,'
          '    valor_total DECIMAL(10, 2),'
          '    FOREIGN KEY (codigo_cliente) REFERENCES clientes(codigo)'
          '        ON DELETE CASCADE ON UPDATE CASCADE'
          ');'
          ''
          '-- Tabela de itens de pedidos'
          'CREATE TABLE pedido_itens ('
          '    id INT AUTO_INCREMENT PRIMARY KEY,'
          '    numero_pedido INT,'
          '    codigo_produto INT,'
          
            '    quantidade DECIMAL(10, 4),  -- Suporte para itens pes'#225'veis e' +
            ' precis'#245'es diferentes'
          '    valor_unitario DECIMAL(10, 2),'
          '    valor_total DECIMAL(10, 2),'
          
            '    FOREIGN KEY (numero_pedido) REFERENCES pedidos(numero_pedido' +
            ')'
          '        ON DELETE CASCADE ON UPDATE CASCADE,'
          '    FOREIGN KEY (codigo_produto) REFERENCES produtos(codigo)'
          '        ON DELETE CASCADE ON UPDATE CASCADE'
          ');'
          ''
          '-- Define os '#237'ndices'
          'CREATE INDEX idx_codigo_cliente ON pedidos(codigo_cliente);'
          'CREATE INDEX idx_codigo_produto ON pedido_itens(codigo_produto);'
          ''
          '-- Popula a tabela "CLIENTES" com 20 registros'
          'INSERT INTO clientes (nome, cidade, uf)'
          'VALUES'
          '('#39'Jo'#227'o Silva'#39', '#39'S'#227'o Paulo'#39', '#39'SP'#39'),'
          '('#39'Maria Souza'#39', '#39'Rio de Janeiro'#39', '#39'RJ'#39'),'
          '('#39'Carlos Lima'#39', '#39'Belo Horizonte'#39', '#39'MG'#39'),'
          '('#39'Ana Pereira'#39', '#39'Curitiba'#39', '#39'PR'#39'),'
          '('#39'Bruno Mendes'#39', '#39'Fortaleza'#39', '#39'CE'#39'),'
          '('#39'Clara Oliveira'#39', '#39'Salvador'#39', '#39'BA'#39'),'
          '('#39'Pedro Alves'#39', '#39'Manaus'#39', '#39'AM'#39'),'
          '('#39'Lucas Rocha'#39', '#39'Porto Alegre'#39', '#39'RS'#39'),'
          '('#39'Larissa Dias'#39', '#39'Recife'#39', '#39'PE'#39'),'
          '('#39'Rafael Santos'#39', '#39'Bras'#237'lia'#39', '#39'DF'#39'),'
          '('#39'Beatriz Moura'#39', '#39'Bel'#233'm'#39', '#39'PA'#39'),'
          '('#39'Gabriel Nunes'#39', '#39'Florian'#243'polis'#39', '#39'SC'#39'),'
          '('#39'Fernanda Lima'#39', '#39'Natal'#39', '#39'RN'#39'),'
          '('#39'Eduardo Silva'#39', '#39'Goi'#226'nia'#39', '#39'GO'#39'),'
          '('#39'Mariana Ribeiro'#39', '#39'Vit'#243'ria'#39', '#39'ES'#39'),'
          '('#39'Vin'#237'cius Costa'#39', '#39'Campo Grande'#39', '#39'MS'#39'),'
          '('#39'Roberta Martins'#39', '#39'Macei'#243#39', '#39'AL'#39'),'
          '('#39'Guilherme Sousa'#39', '#39'Jo'#227'o Pessoa'#39', '#39'PB'#39'),'
          '('#39'J'#233'ssica Cardoso'#39', '#39'Aracaju'#39', '#39'SE'#39'),'
          '('#39'Renato Farias'#39', '#39'Teresina'#39', '#39'PI'#39');'
          ''
          '-- Popula a tabela "PRODUTOS" com 20 registros'
          'INSERT INTO produtos (descricao, preco_venda)'
          'VALUES'
          '('#39'Camiseta'#39', 50.00),'
          '('#39'Bon'#233#39', 25.00),'
          '('#39'Sapato'#39', 120.50),'
          '('#39'Rel'#243'gio'#39', 199.99),'
          '('#39'Mochila'#39', 150.00),'
          '('#39'Cal'#231'a Jeans'#39', 80.00),'
          '('#39#211'culos de Sol'#39', 99.99),'
          '('#39'Chinelo'#39', 20.00),'
          '('#39'Carteira de Couro'#39', 60.00),'
          '('#39'Jaqueta'#39', 250.00),'
          '('#39'Bermuda'#39', 45.00),'
          '('#39'T'#234'nis'#39', 300.00),'
          '('#39'Cinto de Couro'#39', 40.00),'
          '('#39'Sand'#225'lia'#39', 70.00),'
          '('#39'Blusa'#39', 55.00),'
          '('#39'Chap'#233'u'#39', 35.00),'
          '('#39'Casaco'#39', 180.00),'
          '('#39'Meia'#39', 10.00),'
          '('#39'Gravata'#39', 25.50),'
          '('#39'Brinco'#39', 15.00);'
          ''
          '-- Popula a tabela "PEDIDOS"'
          ''
          '-- Cadastro o pedido'
          'INSERT INTO pedidos (data_emissao, codigo_cliente, valor_total)'
          'VALUES ('#39'2024-09-29'#39', 1, 150.00);'
          ''
          '-- Memoriza o ID do pedido'
          'SET @pedido_id = LAST_INSERT_ID();'
          ''
          '-- Cadastra os itens do pedido memorizado'
          
            'INSERT INTO pedido_itens (numero_pedido, codigo_produto, quantid' +
            'ade, valor_unitario, valor_total)'
          'VALUES'
          '(@pedido_id, 1, 2.0000, 50.00, 100.00),  -- Camiseta'
          '(@pedido_id, 2, 1.0000, 50.00, 50.00);   -- Bon'#233
          ''
          '-- Confirmar transa'#231#227'o'
          'COMMIT;')
      end>
    Connection = cnPedidoDB
    Params = <>
    Macros = <>
    Left = 48
    Top = 96
  end
  object sqlApagaPedidoDB: TFDScript
    SQLScripts = <
      item
        Name = 'CriaPedidoDB'
        SQL.Strings = (
          'DROP DATABASE IF EXISTS pedidosDB')
      end>
    Connection = cnPedidoDB
    Params = <>
    Macros = <>
    Left = 168
    Top = 96
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 312
    Top = 24
  end
end
