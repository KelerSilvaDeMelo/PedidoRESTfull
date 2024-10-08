unit ClientConstsPedido;

interface

const
  // URL do servidor e suas rotas
  BASE_HOST = 'localhost';
  BASE_PORT = '8080';

  SERVER_API_URL = 'http://' + BASE_HOST + ':' + BASE_PORT;

  // As rotas diretamente mapeadas para as ações do WebModule no servidor
  ENDPOINT_LISTA_CLIENTES = SERVER_API_URL + '/ListaClientes';
  ENDPOINT_LISTA_PEDIDOS = SERVER_API_URL + '/ListaPedidos';
  ENDPOINT_LISTA_PRODUTOS = SERVER_API_URL + '/ListaProdutos';
  ENDPOINT_INCLUI_PEDIDO = SERVER_API_URL + '/InserePedido';
  ENDPOINT_ADICIONA_ITEM_PEDIDO = SERVER_API_URL + '/AdicionaItemAoPedido';
  ENDPOINT_BUSCA_PEDIDO = SERVER_API_URL + '/BuscaPedido';
  ENDPOINT_BUSCA_ITENS_PEDIDO = SERVER_API_URL + '/BuscaItensDoPedido';
  ENDPOINT_EXCLUI_PEDIDO = SERVER_API_URL + '/ExcluiPedido';
  ENDPOINT_API_STATUS = SERVER_API_URL + '/APIStatus';

  // Mensagens de erro
  MSG_ERRO_SERVIDOR_INDISPONIVEL =
    'Servidor de aplicação está momentaneamente indisponível.';
  MSG_ERRO_ENVIO_DADOS = 'Erro ao enviar dados ao servidor.';
  MSG_ERRO_SERVIDOR_RESPOSTA_INVALIDA = 'Resposta inesperada do servidor.';

  MSG_ERRO_LISTAR_CLIENTES = 'Indisponibilidade momentânea na lista de clientes.';
  MSG_ERRO_LISTAR_PRODUTOS = 'Indisponibilidade momentânea na lista de produtos.';
  MSG_ERRO_LISTAR_PEDIDOS = 'Indisponibilidade momentânea na lista de pedidos.';
  MSG_ERRO_LISTAR_PEDIDO_ITENS = 'Indisponibilidade momentânea na lista de itens do pedido.';

  MSG_ERRO_INCLUIR_PEDIDO = 'Indisponibilidade momentânea ao incluir pedido.';
  MSG_ERRO_INCLUIR_ITEM_PEDIDO = 'Indisponibilidade momentânea ao incluir item no pedido.';

  MSG_ERRO_BUSCAR_PEDIDO = 'Indisponibilidade momentânea na busca de pedido.';

  MSG_ERRO_GRAVAR_PEDIDO = 'Indisponibilidade momentânea na gravação do pedido.';

  MSG_ERRO_EXCLUI_PEDIDO = 'Indisponibilidade momentânea na exclusão do pedido.';

  // Timeout padrão
  HTTP_TIMEOUT = 5000; // 5 segundos

  // Funcionalidade
  FN_LISTA_VAZIA = 'A lista está vazia.';
  FN_PEDIDO_GRAVADO = 'Pedido gravado com sucesso!';
  FN_PEDIDO_EXCLUIDO = 'Pedido excluído com sucesso!';
  FN_BUSCA_PEDIDO = 'Busca pedido.';
  FN_INFORME_CODIGO_PEDIDO = 'Informe o código do pedido.';
  FN_PROCESSO_CANCELADO = 'Processo cancelado.';
  FN_PEDIDO_LOCALIZADO = 'Pedido localizado.';
  FN_PEDIDO_NAO_LOCALIZADO = 'Pedido não localizado.';
  FN_EXCLUIR_REGISTRO = 'Deseja EXCLUIR o registro posicionado?';
  FN_EXCLUIR_PEDIDO = 'Deseja EXCLUIR o pedido?';

implementation

end.
