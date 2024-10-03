unit ServerConstsSQL;

interface

const
  SQL_ListarClientes =
    'SELECT cli.codigo as codigo_cliente,' +
          ' cli.nome as nome_cliente' +
     ' FROM clientes cli ' +
     'ORDER BY cli.nome;';

  SQL_ListarProdutos =
    'SELECT prod.codigo as codigo_produto,' +
          ' prod.descricao as descricao_produto,' +
          ' prod.preco_venda as preco_venda_produto' +
     ' FROM produtos prod ' +
     'ORDER BY prod.descricao;';

  SQL_ListarPedidos =
    'SELECT ped.numero_pedido as sequencia_pedido,' +
          ' ped.codigo_cliente as codigo_cliente,' +
          ' cli.nome as nome_cliente,' +
          ' ped.data_emissao as data_emissao_pedido, '+
          ' ped.valor_total as valor_total_pedido' +
     ' FROM pedidos ped ' +
     ' JOIN clientes cli ON cli.codigo = ped.codigo_cliente ' +
     'ORDER BY ped.numero_pedido DESC;';

  SQL_ListarItensDoPedido =
    'SELECT peditn.id AS sequencia_item, ' +          ' peditn.numero_pedido AS sequencia_pedido, ' +
          ' peditn.codigo_produto AS codigo_produto, ' +
          ' prod.descricao AS descricao_produto, ' +
          ' peditn.quantidade AS quantidade_produto, ' +
          ' peditn.valor_unitario AS valor_unitario_produto, ' +
          ' peditn.valor_total AS valor_total_produto' +
     ' FROM pedido_itens peditn ' +
     ' JOIN produtos prod ON peditn.codigo_produto = prod.codigo ' +
     'ORDER BY peditn.id DESC;';

  SQL_InserirPedido = 'INSERT INTO ' +
    'pedidos (codigo_cliente, data_emissao, valor_total) ' +
    'VALUES (:cliente_id, :data_emissao, :valor_total);';

  SQL_AdicionarItemAoPedido = 'INSERT INTO ' +
    'pedido_itens (numero_pedido, codigo_produto,'+
                 ' quantidade, valor_unitario, valor_total)' +
    'VALUES(:numero_pedido, :codigo_produto,' +
                 ' :quantidade, :valor_unitario, :valor_total);';

implementation

end.
