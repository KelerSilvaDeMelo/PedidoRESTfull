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
  DB_VENDORLIB = 'C:\Provas\WK Tecnology\ServidorRESTful\Win32\Debug\libmysql.dll';
//  DB_VENDORLIB = 'C:\Provas\WK Tecnology\ServidorRESTful\Win64\Debug\libmysql.dll';

implementation

end.
