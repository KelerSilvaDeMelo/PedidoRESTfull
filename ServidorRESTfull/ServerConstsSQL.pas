unit ServerConstsSQL;

interface

const
  SQL_ListarClientes =
    'SELECT cli.codigo as codigo_cliente,' +
          ' cli.nome as nome_cliente' +
     ' FROM clientes cli ' +
     'ORDER BY cli.nome;';

  SQL_ClienteExiste =
    'SELECT COUNT(*) AS Total' +
     ' FROM clientes cli ' +
     'WHERE cli.codigo = :cliente_id;';

  SQL_ListarProdutos =
    'SELECT prod.codigo as codigo_produto,' +
          ' prod.descricao as descricao_produto,' +
          ' prod.preco_venda as preco_venda_produto' +
     ' FROM produtos prod ' +
     'ORDER BY prod.descricao;';

  SQL_ProdutoExiste =
    'SELECT COUNT(*) AS Total' +
     ' FROM produtos prod ' +
     'WHERE prod.codigo = :codigo_produto;';

  SQL_ListarPedidos =
    'SELECT ped.numero_pedido as sequencia_pedido,' +
          ' ped.codigo_cliente as codigo_cliente,' +
          ' cli.nome as nome_cliente,' +
          ' ped.data_emissao as data_emissao_pedido, '+
          ' ped.valor_total as valor_total_pedido' +
     ' FROM pedidos ped ' +
'INNER JOIN clientes cli ON cli.codigo = ped.codigo_cliente ' +
     'ORDER BY ped.numero_pedido DESC;';

  SQL_PedidoExiste =
    'SELECT COUNT(*) AS Total' +
     ' FROM pedidos ped ' +
     'WHERE ped.numero_pedido = :numero_pedido;';

  SQL_ListarItensDoPedido =
    'SELECT peditn.id AS sequencia_item, ' +
          ' peditn.numero_pedido AS sequencia_pedido, ' +
          ' peditn.codigo_produto AS codigo_produto, ' +
          ' prod.descricao AS descricao_produto, ' +
          ' peditn.quantidade AS quantidade_produto, ' +
          ' peditn.valor_unitario AS valor_unitario_produto, ' +
          ' peditn.valor_total AS valor_total_produto' +
     ' FROM pedido_itens peditn ' +
'INNER JOIN produtos prod ON peditn.codigo_produto = prod.codigo ' +
     'ORDER BY peditn.id DESC;';

  SQL_InserirPedido = 'INSERT INTO ' +
    'pedidos (codigo_cliente, data_emissao, valor_total) ' +
    'VALUES (:codigo_cliente, :data_emissao_pedido, :valor_total_pedido);';
          // :cliente_id, :data_emissao, :valor_total
  SQL_AdicionarItemAoPedido = 'INSERT INTO ' +
    'pedido_itens (numero_pedido, codigo_produto,'+
                 ' quantidade, valor_unitario, valor_total)' +
    'VALUES(:sequencia_pedido, :codigo_produto,' +
                 ' :quantidade_produto, :valor_unitario_produto, :valor_total_produto);';
//    'VALUES(:numero_pedido, :codigo_produto,' +
//                 ' :quantidade, :valor_unitario, :valor_total);';

  SQL_BuscaPedido =
    'SELECT ped.numero_pedido as sequencia_pedido,' +
          ' ped.codigo_cliente as codigo_cliente,' +
          ' cli.nome as nome_cliente,' +
          ' ped.data_emissao as data_emissao_pedido, '+
          ' ped.valor_total as valor_total_pedido' +
     ' FROM pedidos ped ' +
'INNER JOIN clientes cli ON cli.codigo = ped.codigo_cliente ' +
     'WHERE ped.numero_pedido = :numero_pedido ' +
     'ORDER BY ped.numero_pedido DESC;';

  SQL_BuscaItensDoPedido =
    'SELECT peditn.id AS sequencia_item, ' +
          ' peditn.numero_pedido AS sequencia_pedido, ' +
          ' peditn.codigo_produto AS codigo_produto, ' +
          ' prod.descricao AS descricao_produto, ' +
          ' peditn.quantidade AS quantidade_produto, ' +
          ' peditn.valor_unitario AS valor_unitario_produto, ' +
          ' peditn.valor_total AS valor_total_produto' +
     ' FROM pedido_itens peditn ' +
'INNER JOIN produtos prod ON peditn.codigo_produto = prod.codigo ' +
     'WHERE peditn.numero_pedido = :numero_pedido ' +
     'ORDER BY peditn.id DESC;';
                   SQL_ExcluiPedido =
    'DELETE' +
     ' FROM pedidos ' +
     'WHERE numero_pedido = :numero_pedido;';

implementation

end.
