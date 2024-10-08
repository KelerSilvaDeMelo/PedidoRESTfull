unit ServerConstsPedido;

interface

resourcestring
  sPortInUse = '- Error: Port %s already in use';
  sPortSet = '- Port set to %s';
  sServerRunning = '- The Server is already running';
  sStartingServer = '- Starting HTTP Server on port %d';
  sStoppingServer = '- Stopping Server';
  sServerStopped = '- Server Stopped';
  sServerNotRunning = '- The Server is not running';
  sInvalidCommand = '- Error: Invalid Command';
  sIndyVersion = '- Indy Version: ';
  sActive = '- Active: ';
  sPort = '- Port: ';
  sSessionID = '- Session ID CookieName: ';
  sCommands = 'Enter a Command: ' + slineBreak +
    '   - "start" to start the server'+ slineBreak +
    '   - "stop" to stop the server'+ slineBreak +
    '   - "set port" to change the default port'+ slineBreak +
    '   - "status" for Server status'+ slineBreak +
    '   - "help" to show commands'+ slineBreak +
    '   - "exit" to close the application';

const
  cArrow = '->';
  cCommandStart = 'start';
  cCommandStop = 'stop';
  cCommandStatus = 'status';
  cCommandHelp = 'help';
  cCommandSetPort = 'set port';
  cCommandExit = 'exit';

const
  DB_HOST = 'localhost';
  DB_PORT = '3306';
  DB_USER = 'sispedido';           // 'sispedido'       'root';
  DB_PASSWORD = 'M@Ped80390.2024'; // 'M@Ped80390.2024' 'M@Sql80390.2024';
  DB_NAME = 'pedidosDB';
  DB_VENDORLIB = 'C:\Provas\WK Tecnology\ServidorRESTfull\Win32\Debug\libmysql.dll';
//  DB_VENDORLIB = 'C:\Provas\WK Tecnology\ServidorRESTfull\Win64\Debug\libmysql.dll';
  DB_SERVER_CACHE = 'ServerCache\';
  DB_SERVER_CONFIG = 'server_config.ini';
  DB_UNKNOWN = 'Unknown database';

const
  APP_JSON = 'application/json';
  APP_404 = 'Recurso n�o encontrado';
  APP_REQUISICAO_INVALIDA = 'Formato de requisi��o inv�lido.';
  APP_REQUISICAO_ANINHADA_INVALIDA = 'Formato de requisi��o aninhada inv�lido.';

const
  V_CLIENTE_NAO_EXISTE = 'Cliente n�o exite no banco de dados';
  V_DATA_INVALIDA = 'Data inv�lida';
  V_VALOR_MONETARIO_INVALIDO = 'Valor monet�rio inv�lido';
  V_VALOR_UNITARIO_INVALIDO = 'Valor unit�rio inv�lido';
  V_VALOR_PEDIDO_INVALIDO = 'Valor do pedido inv�lido';
  V_PEDIDO_NAO_EXISTE = 'Pedido n�o exite no banco de dados';
  V_PRODUTO_NAO_EXISTE = 'Produto n�o exite no banco de dados';
  V_QUANTIDADE_INVALIDA = 'Quantidade inv�lida';

const
  ERR_LISTA_CLIENTES = 'Ocorreu uma falha ao listar os clientes';
  ERR_LISTA_PRODUTOS = 'Ocorreu uma falha ao listar os produto';
  ERR_LISTA_PEDIDOS = 'Ocorreu uma falha ao listar os pedidos';

  ERR_INSERE_PEDIDO = 'Ocorreu uma falha ao inserir o pedido';
  ERR_INSERE_PEDIDOITEM = 'Ocorreu uma falha ao inserir item no pedido';
  ERR_INSERE_ITEMAUSENTE = 'Itens do pedido ausentes';

  ERR_BUSCA_PEDIDO = 'Ocorreu uma falha ao buscar o pedido';
  ERR_BUSCA_PEDIDO_NE = 'Pedido n�o localizado';

  ERR_BUSCA_PEDIDOITENS = 'Ocorreu uma falha ao buscar itens do pedido';

  ERR_EXCLUI_PEDIDO = 'Ocorreu uma falha ao excluir o pedido';

const
  SU_INSERE_PEDIDO = 'Pedido inserido com sucesso';
  SU_INSERE_PEDIDOITEM = 'Item de pedido inserido com sucesso';
  SU_EXCLUI_PEDIDO = 'Pedido excluido com sucesso';

implementation

end.
