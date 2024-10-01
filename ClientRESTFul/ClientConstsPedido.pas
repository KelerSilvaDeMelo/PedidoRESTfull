unit ClientConstsPedido;

interface

const
  // URL do servidor e suas rotas
  BASE_HOST = 'localhost';
  BASE_PORT = '8080';

  SERVER_API_URL = 'http://' + BASE_HOST + ':' + BASE_PORT;

  // As rotas diretamente mapeadas para as a��es do WebModule no servidor
  ENDPOINT_LISTAR_PEDIDOS = SERVER_API_URL + '/ListarPedidos';
  ENDPOINT_LISTAR_ITENS_DO_PEDIDO = SERVER_API_URL + '/ListarItensDoPedido';
  ENDPOINT_INCLUIR_PEDIDO = SERVER_API_URL + '/InserirPedido';
  ENDPOINT_ADICIONAR_ITEM_PEDIDO = SERVER_API_URL + '/AdicionarItemAoPedido';
  ENDPOINT_LISTAR_PRODUTOS = SERVER_API_URL + '/ListarProdutos';
  ENDPOINT_LISTAR_CLIENTES = SERVER_API_URL + '/ListarClientes';
  ENDPOINT_API_STATUS = SERVER_API_URL + '/APIStatus';

  // Mensagens de erro
  MSG_ERRO_SERVIDOR_INDISPONIVEL =
    'N�o foi poss�vel se conectar ao servidor. Verifique sua conex�o.';
  MSG_ERRO_ENVIO_DADOS = 'Erro ao enviar dados ao servidor.';
  MSG_ERRO_SERVIDOR_RESPOSTA_INVALIDA = 'Resposta inesperada do servidor.';

  // Timeout padr�o
  HTTP_TIMEOUT = 5000; // 5 segundos

implementation

end.
