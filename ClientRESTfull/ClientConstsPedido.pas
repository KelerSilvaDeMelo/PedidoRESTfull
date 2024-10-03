unit ClientConstsPedido;

interface

const
  // URL do servidor e suas rotas
  BASE_HOST = 'localhost';
  BASE_PORT = '8080';

  SERVER_API_URL = 'http://' + BASE_HOST + ':' + BASE_PORT;

  // As rotas diretamente mapeadas para as a��es do WebModule no servidor
  ENDPOINT_LISTAR_CLIENTES = SERVER_API_URL + '/ListarClientes';
  ENDPOINT_LISTAR_PEDIDOS = SERVER_API_URL + '/ListarPedidos';
  ENDPOINT_LISTAR_ITENS_DO_PEDIDO = SERVER_API_URL + '/ListarItensDoPedido';
  ENDPOINT_INCLUIR_PEDIDO = SERVER_API_URL + '/InserirPedido';
  ENDPOINT_ADICIONAR_ITEM_PEDIDO = SERVER_API_URL + '/AdicionarItemAoPedido';
  ENDPOINT_LISTAR_PRODUTOS = SERVER_API_URL + '/ListarProdutos';
  ENDPOINT_API_STATUS = SERVER_API_URL + '/APIStatus';

  // Mensagens de erro
  MSG_ERRO_SERVIDOR_INDISPONIVEL =
    'Servidor de aplica��o est� momentaneamente indispon�vel.';
  MSG_ERRO_ENVIO_DADOS = 'Erro ao enviar dados ao servidor.';
  MSG_ERRO_SERVIDOR_RESPOSTA_INVALIDA = 'Resposta inesperada do servidor.';

  MSG_ERRO_LISTAR_CLIENTES = 'Indisponibilidade moment�nea na lista de clientes.';
  MSG_ERRO_LISTAR_PRODUTOS = 'Indisponibilidade moment�nea na lista de produtos.';
  MSG_ERRO_LISTAR_PEDIDOS = 'Indisponibilidade moment�nea na lista de pedidos.';
  MSG_ERRO_LISTAR_PEDIDO_ITENS = 'Indisponibilidade moment�nea na lista de itens do pedido.';

  MSG_ERRO_GRAVAR_PEDIDO = 'Indisponibilidade moment�nea na grava��o do pedido.';

  // Timeout padr�o
  HTTP_TIMEOUT = 5000; // 5 segundos

  // Funcionalidade
  FN_APAGAR_REGISTRO = 'Deseja realmante APAGAR o registro posicionado?';
  FN_GRAVA_PEDIDO = 'Pedido gravado com sucesso!';
  FN_LISTA_VAZIA = 'A lista est� vazia.';

implementation

end.
