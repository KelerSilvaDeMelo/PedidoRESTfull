unit UnitDMBaseAPI;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, IdHTTP, IdSSLOpenSSL,
  Vcl.Dialogs, ClientConstsPedido;

type
  TdmBaseAPI = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);

  private
    FServerHost: string;
    FServerPort: string;
    FConectado: Boolean;
    FCache: String; // Cache de dados para uso offline

  private
    procedure LerConfigIni;

  public
    function TestarConexao(var MensagemErro: String): Boolean;
    function Conectado: Boolean;
    function PastaCache: String;
  end;

var
  dmGlobalAPI: TdmBaseAPI;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

{ -------------------------------[ CONSTRU��O ]------------------------------- }
{ Inicializa��o mestre do motor de sustenta��o da API }
procedure TdmBaseAPI.DataModuleCreate(Sender: TObject);
begin
  Self.FServerHost := '';
  Self.FServerPort := '';
  Self.FConectado := False;
  Self.FCache := ExtractFilePath(ParamStr(0)) + 'ClientCache\';
  if not DirectoryExists(Self.FCache) then
  begin
    CreateDir(Self.FCache);
  end;
end;

{ --------------------------------[ PRIVADO ]--------------------------------- }
{ L� as configura��es do arquivo client_config.ini }
procedure TdmBaseAPI.LerConfigIni;
var
  Ini: TIniFile;
  ConfigFilePath: string;
begin
  ConfigFilePath := ExtractFilePath(ParamStr(0)) + 'client_config.ini';
  Ini := TIniFile.Create(ConfigFilePath);
  try
    if not FileExists(ConfigFilePath) then
    begin
      Ini.WriteString('Servidor', 'Host', BASE_HOST);
      Ini.WriteString('Servidor', 'Porta', BASE_PORT);
    end;

    Self.FServerHost := Ini.ReadString('Servidor', 'Host', BASE_HOST);
    Self.FServerPort := Ini.ReadString('Servidor', 'Porta', BASE_PORT);
  finally
    Ini.Free;
  end;
end;

{ --------------------------------[ PUBLICO ]--------------------------------- }

{ Testa a conex�o com o servidor de aplica��o }
function TdmBaseAPI.TestarConexao(var MensagemErro: String): Boolean;
var
  HTTPClient: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Url: string;
  Resposta: string;
begin
  MensagemErro := '';
  Self.LerConfigIni;

  HTTPClient := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  HTTPClient.IOHandler := SSLHandler;
  try

    // Monta a URL de teste
    Url := Format('http://%s:%s/APIStatus', [FServerHost, FServerPort]);
    try
      Resposta := HTTPClient.Get(Url);
      Self.FConectado := True;
    except
      on E: Exception do
      begin
        Self.FConectado := False;
        MensagemErro := MSG_ERRO_SERVIDOR_INDISPONIVEL + #13
                      + E.Message;
      end;
    end;
  finally
    HTTPClient.IOHandler := nil;
    SSLHandler.Free;
    HTTPClient.Free;
  end;

  Result := Self.FConectado;
end;

function TdmBaseAPI.Conectado: Boolean;
begin
  Result := Self.FConectado;
end;

function TdmBaseAPI.PastaCache: String;
begin
  Result := Self.FCache;
end;


end.
