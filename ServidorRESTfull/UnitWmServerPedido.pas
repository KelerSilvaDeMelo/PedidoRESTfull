unit UnitWmServerPedido;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.ConsoleUI.Wait,
  ServerConstsPedido, ServerConstsSQL, FireDAC.VCLUI.Wait,
  FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL, FireDAC.Comp.ScriptCommands,
  FireDAC.Stan.Util, FireDAC.Comp.Script, FireDAC.Stan.StorageJSON;

type
  TwmServerPedido = class(TWebModule)
    cnPedidoDB: TFDConnection;
    MySQLDriverLink: TFDPhysMySQLDriverLink;
    sqlCriaPedidoDB: TFDScript;
    sqlApagaPedidoDB: TFDScript;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;

    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);

    procedure wmServerPedidoAPIStatusAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure wmServerPedidoListaClientesAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1ListaProdutosAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1ListaPedidosAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1InserePedidoAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1AdicionaItemAoPedidoAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure wmServerPedidoBuscaPedidoAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure wmServerPedidoBuscaItensDoPedidoAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure wmServerPedidoExcluiPedidoAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);

  private
    { Private declarations }
    FCache: String;

  private
    { Private declarations }
    procedure ConectaBancoDeDados;
    procedure DesconectaBancoDeDados;
    procedure CriaPedidosDB;
    procedure ApagaPedidosDB;

    procedure RetornaSucesso(Response: TWebResponse; Mensagem: String;
      CodigoSucesso: Integer);
    procedure RetornaSucessoLista(Response: TWebResponse; JSONResult: String;
      CodigoSucesso: Integer);
    procedure RetornaSucessoChave(Response: TWebResponse;
      Mensagem, CampoChave: String; ValorChave: Integer;
      CodigoSucesso: Integer);

    procedure RetornaErro(Response: TWebResponse; Mensagem: String;
      CodigoErro: Integer);

    function ListaAPI(const Rota, SQL, ParametroID, ParametroValor: String;
                      const CodigoDeSucesso, CodigoDeErro: Integer;
                      Response: TWebResponse; var Handled: Boolean;
                      var MensagemDeErro: String): Boolean;
    function InsereAPI(FDQuery: TFDQuery; const CampoID, MensagemDeSucesso: String;
                      const CodigoDeSucesso, CodigoDeErro: Integer;
                      Response: TWebResponse; var Handled: Boolean;
                      var MensagemDeErro: String): Boolean;
    function ValidaInserePedido(Request: TWebRequest; Response: TWebResponse): Boolean;
    function ValidaInserePedidoItem(Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean): Boolean;

    function ClienteExiste(ClienteID: String): Boolean;
    function ProdutoExiste(ProdutoID: String): Boolean;
    function PedidoExiste(PedidoID: String): Boolean;

    function DataConsistente(Data: String): Boolean;
    function ValorMonetarioConsistente(Valor: String): Boolean;
    function ValorIntegerConsistente(Valor: String): Boolean;
    function ValorPositivo(Valor: String): Boolean;

  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TwmServerPedido;

implementation

uses
  System.IniFiles, System.JSON;

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

{ -------------------------------[ CONSTRUTOR ]------------------------------- }
procedure TwmServerPedido.WebModuleCreate(Sender: TObject);
begin
  Self.FCache := ExtractFilePath(ParamStr(0)) + DB_SERVER_CACHE;
  if not DirectoryExists(Self.FCache) then
  begin
    CreateDir(Self.FCache);
  end;
  Self.ConectaBancoDeDados;
end;

procedure TwmServerPedido.WebModuleDestroy(Sender: TObject);
begin
  Self.DesconectaBancoDeDados;
end;

{ --------------------------------[ PRIVADO ]--------------------------------- }
procedure TwmServerPedido.ConectaBancoDeDados;
var
  ArquivoINI, HostServer, Port, UserName, Password, Database, VendorLib: String;
  Ini: TIniFile;
begin
  ArquivoINI := ExtractFilePath(ParamStr(0)) + DB_SERVER_CONFIG;
  HostServer := DB_HOST;
  Port := DB_PORT;
  UserName := DB_USER;
  Password := DB_PASSWORD;
  Database := DB_NAME;
  VendorLib := DB_VENDORLIB;

  Ini := TIniFile.Create(ArquivoINI);
  try
    if FileExists(ArquivoINI) then
    begin
      HostServer := Ini.ReadString('database', 'host', HostServer);
      Port := Ini.ReadString('database', 'port', Port);
      UserName := Ini.ReadString('database', 'user', UserName);
      Password := Ini.ReadString('database', 'password', Password);
      Database := Ini.ReadString('database', 'database', Database);
      VendorLib := Ini.ReadString('database', 'vendorlib', VendorLib);
    end
    else
    begin
      Ini.WriteString('database', 'host', HostServer);
      Ini.WriteString('database', 'port', Port);
      Ini.WriteString('database', 'user', UserName);
      Ini.WriteString('database', 'password', Password);
      Ini.WriteString('database', 'database', Database);
      Ini.WriteString('database', 'vendorlib', VendorLib);
    end;
  finally
    Ini.Free;
  end;

  Self.cnPedidoDB.Params.Values['Server'] := HostServer;
  Self.cnPedidoDB.Params.Values['Port'] := Port;
  Self.cnPedidoDB.Params.Values['User_Name'] := UserName;
  Self.cnPedidoDB.Params.Values['Password'] := Password;
  Self.cnPedidoDB.Params.Values['Database'] := Database;
  // Self.cnPedidoDB.Params.Values['Pooled'] := 'True';
  // Self.cnPedidoDB.Params.Values['Pool_MaximumItems'] := '10';
  Self.MySQLDriverLink.VendorLib := VendorLib;

  try
    Self.cnPedidoDB.Connected := True;
  except
    on E: Exception do
      if Pos(DB_UNKNOWN, E.Message) > 0 then
      begin
        // Se o banco de dados n�o existir, ser� criado e implantado.
        Self.CriaPedidosDB;

        // Fecha e reabre a conex�o com o banco de dados criado
        Self.cnPedidoDB.Close;
        Self.cnPedidoDB.Params.Database := Database;
        Self.cnPedidoDB.Open;
      end
      else
        raise;
  end;
end;

procedure TwmServerPedido.DesconectaBancoDeDados;
begin
  if Self.cnPedidoDB.Connected then
    Self.cnPedidoDB.Connected := False;
end;

procedure TwmServerPedido.CriaPedidosDB;
begin
  // Se o banco de dados n�o existir, ser� criado e implantado.
  if Self.cnPedidoDB.Connected then
    Self.cnPedidoDB.Connected := False;

  Self.cnPedidoDB.Params.Database := '';
  Self.cnPedidoDB.Open;
  Self.sqlCriaPedidoDB.ExecuteAll;
  Self.cnPedidoDB.Close;
end;

procedure TwmServerPedido.ApagaPedidosDB;
begin
  // Remove o banco de dados previamente criado.
  Self.cnPedidoDB.Params.Database := '';
  Self.cnPedidoDB.Open;
  Self.sqlApagaPedidoDB.ExecuteAll;
  Self.cnPedidoDB.Close;
end;

procedure TwmServerPedido.RetornaSucesso(Response: TWebResponse;
  Mensagem: String; CodigoSucesso: Integer);
begin
  Response.ContentType := APP_JSON;
  Response.Content := Format('{"message": "%s"}', [Mensagem]);
  Response.StatusCode := CodigoSucesso;
end;

procedure TwmServerPedido.RetornaSucessoLista(Response: TWebResponse;
  JSONResult: String; CodigoSucesso: Integer);
begin
  Response.ContentType := APP_JSON;
  Response.Content := JSONResult;
  Response.StatusCode := CodigoSucesso;
end;

procedure TwmServerPedido.RetornaSucessoChave(Response: TWebResponse;
  Mensagem, CampoChave: String; ValorChave: Integer; CodigoSucesso: Integer);
begin
  Response.ContentType := APP_JSON;
  Response.Content := Format('{"message": "%s", "%s": %d}',
    [Mensagem, CampoChave, ValorChave]);
  Response.StatusCode := CodigoSucesso;
end;

procedure TwmServerPedido.RetornaErro(Response: TWebResponse; Mensagem: String;
  CodigoErro: Integer);
begin
  Response.ContentType := APP_JSON;
  Response.Content := Format('{"error": "%d", "message": "%s"}',
    [CodigoErro, Mensagem]);
  Response.StatusCode := CodigoErro;
end;

function TwmServerPedido.ListaAPI(const Rota, SQL, ParametroID, ParametroValor: String;
                      const CodigoDeSucesso, CodigoDeErro: Integer;
                      Response: TWebResponse; var Handled: Boolean;
                      var MensagemDeErro: String): Boolean;
var
  FDQuery: TFDQuery;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  Campo: TField;
begin
  Result := False;
  FDQuery := TFDQuery.Create(nil);
  FDQuery.Name := Rota;
  JSONArray := TJSONArray.Create;
  try
    FDQuery.Connection := Self.cnPedidoDB;
    FDQuery.SQL.Text := SQL;
    if ParametroID<>'' then
      FDQuery.ParamByName(ParametroID).Value := ParametroValor;

    try
      FDQuery.Open;

      // Converte os resultados da query em JSON
      while not FDQuery.Eof do
      begin
        JSONObject := TJSONObject.Create;

        for Campo in FDQuery.Fields do
        begin
          JSONObject.AddPair(Campo.FieldName, Campo.AsString);
        end;

        JSONArray.AddElement(JSONObject);
        FDQuery.Next;
      end;

      FDQuery.SaveToFile(Self.FCache + FDQuery.Name + '.json', sfJSON);

      // Retorna o resultado em formato JSON
      Self.RetornaSucessoLista(Response, JSONArray.ToString, CodigoDeSucesso);
      Result := True;
    except
      on E: Exception do
      begin
        MensagemDeErro := MensagemDeErro + #13#10
                        + E.Message;
        Self.RetornaErro(Response, MensagemDeErro, CodigoDeErro);
        Handled := True;
      end;
    end;
  finally
    FDQuery.Free;
    JSONArray.Free;
  end;
end;

function TwmServerPedido.InsereAPI(FDQuery: TFDQuery; const CampoID, MensagemDeSucesso: String;
                      const CodigoDeSucesso, CodigoDeErro: Integer;
                      Response: TWebResponse; var Handled: Boolean;
                      var MensagemDeErro: String): Boolean;
var
  ValorID: Integer;
begin
  try
    FDQuery.ExecSQL;

    // Obter o ID gerado do pedido
    ValorID := Self.cnPedidoDB.GetLastAutoGenValue(CampoID);

    // Retorna uma resposta de sucesso com o ID do pedido criado
    Self.RetornaSucessoChave(Response, MensagemDeSucesso, CampoID, ValorID, CodigoDeSucesso);
  except
    on E: Exception do
    begin
      MensagemDeErro := MensagemDeErro + #13#10
                      + E.Message;
      Self.RetornaErro(Response, MensagemDeErro, CodigoDeErro);
      Handled := True;
    end;
  end;
end;

function TwmServerPedido.ValidaInserePedido(Request: TWebRequest;
  Response: TWebResponse): Boolean;
var
  ClienteID, PedidoData, MensagemErro: String;
  PedidoValor: Currency;
  JSONRequest: TJSONObject;
begin
  JSONRequest := TJSONObject.ParseJSONValue(Request.Content) as TJSONObject;

  if not Assigned(JSONRequest) then
  begin
    Self.RetornaErro(Response, APP_REQUISICAO_INVALIDA, 400);
    Result := False;
    Exit;
  end;

  // Valida ClienteID
  ClienteID := JSONRequest.GetValue<String>('codigo_cliente');
  Result := Self.ClienteExiste(ClienteID);
  if not Result then
  begin
    MensagemErro := V_CLIENTE_NAO_EXISTE + #13#10
                  + 'Codigo Cliente: ' + ClienteID;
    Self.RetornaErro(Response, MensagemErro, 400);
    Exit;
  end;

  // Valida PedidoData
  PedidoData := JSONRequest.GetValue<String>('data_emissao_pedido');
  Result := Self.DataConsistente(PedidoData);
  if not Result then
  begin
    MensagemErro := V_DATA_INVALIDA + #13#10
                  + PedidoData;
    Self.RetornaErro(Response, MensagemErro, 400);
    Exit;
  end;

  // Valida PedidoValor
  try
    PedidoValor := JSONRequest.GetValue<Currency>('valor_total_pedido');
  except on E: Exception do
    begin
      MensagemErro := V_VALOR_MONETARIO_INVALIDO + #13#10
                    + JSONRequest.GetValue<String>('valor_total_pedido');
      Result := False;
    end;
  end;
  {
  Result := Self.ValorMonetarioConsistente(PedidoValor);
  if not Result then
  begin
    MensagemErro := V_VALOR_PEDIDO_INVALIDO + #13#10
                  + PedidoValor;
    Self.RetornaErro(Response, MensagemErro, 400);
    Exit;
  end;
  }
end;

function TwmServerPedido.ValidaInserePedidoItem(Request: TWebRequest;
  Response: TWebResponse; var Handled: Boolean): Boolean;
var
  PedidoID, ProdutoID: String;
  Quantidade, ValorUnitario: Currency;
  MensagemErro: String;
begin
  // Valida PedidoID (numero_pedido)
  PedidoID := Request.ContentFields.Values['numero_pedido'];
  Result := PedidoExiste(PedidoID);
  if not Result then
  begin
    MensagemErro := V_PEDIDO_NAO_EXISTE + #13#10
                  + 'Pedido ID: ' + PedidoID;
    Self.RetornaErro(Response, MensagemErro, 400);
    Handled := True;
    Exit;
  end;

  // Valida ProdutoID (codigo_produto)
  ProdutoID := Request.ContentFields.Values['codigo_produto'];
  Result := ProdutoExiste(ProdutoID);
  if not Result then
  begin
    MensagemErro := V_PRODUTO_NAO_EXISTE + #13#10
                  + 'Produto ID: ' + ProdutoID;
    Self.RetornaErro(Response, MensagemErro, 400);
    Handled := True;
    Exit;
  end;

  // Valida Quantidade
  Result := TryStrToCurr(Request.ContentFields.Values['quantidade'], Quantidade)
    and (Quantidade > 0);
  if not Result then
  begin
    MensagemErro := V_QUANTIDADE_INVALIDA;
    Self.RetornaErro(Response, MensagemErro, 400);
    Handled := True;
    Exit;
  end;

  // Valida Valor Unit�rio
  Result := TryStrToCurr(Request.ContentFields.Values['valor_unitario'],
    ValorUnitario) and (ValorUnitario > 0);
  if not Result then
  begin
    MensagemErro := V_VALOR_UNITARIO_INVALIDO;
    Self.RetornaErro(Response, MensagemErro, 400);
    Handled := True;
    Exit;
  end;
end;

function TwmServerPedido.ClienteExiste(ClienteID: String): Boolean;
var
  FDQuery: TFDQuery;
begin
  Result := False;
  if Trim(ClienteID) = '' then
    Exit;

  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := Self.cnPedidoDB;
    FDQuery.SQL.Text := SQL_ClienteExiste;
    FDQuery.ParamByName('cliente_id').AsString := ClienteID;
    FDQuery.Open;

    // Se o Total for maior que 0, o cliente existe
    Result := FDQuery.FieldByName('Total').AsInteger > 0;
  finally
    FDQuery.Free;
  end;
end;

function TwmServerPedido.ProdutoExiste(ProdutoID: String): Boolean;
var
  FDQuery: TFDQuery;
begin
  Result := False;
  if Trim(ProdutoID) = '' then
    Exit;

  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := Self.cnPedidoDB;
    FDQuery.SQL.Text := SQL_ProdutoExiste;
    FDQuery.ParamByName('codigo_produto').AsString := ProdutoID;
    FDQuery.Open;

    Result := FDQuery.FieldByName('Total').AsInteger > 0;
  finally
    FDQuery.Free;
  end;
end;

function TwmServerPedido.PedidoExiste(PedidoID: String): Boolean;
var
  FDQuery: TFDQuery;
begin
  Result := False;
  if Trim(PedidoID) = '' then
    Exit;

  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := Self.cnPedidoDB;
    FDQuery.SQL.Text := SQL_PedidoExiste;
    FDQuery.ParamByName('numero_pedido').AsString := PedidoID;
    FDQuery.Open;

    Result := FDQuery.FieldByName('Total').AsInteger > 0;
  finally
    FDQuery.Free;
  end;
end;

function TwmServerPedido.DataConsistente(Data: String): Boolean;
var
  DataTeste: TDateTime;
begin
  Result := TryStrToDate(Data, DataTeste);
end;

function TwmServerPedido.ValorMonetarioConsistente(Valor: String): Boolean;
var
  ValorMonetarioTeste: Currency;
begin
  Result := TryStrToCurr(Valor, ValorMonetarioTeste);
end;

function TwmServerPedido.ValorIntegerConsistente(Valor: String): Boolean;
var
  ValorIntegerTeste: Integer;
begin
  Result := TryStrToInt(Valor, ValorIntegerTeste);
end;

function TwmServerPedido.ValorPositivo(Valor: String): Boolean;
var
  ValorIntegerTeste: Integer;
begin
  Result := TryStrToInt(Valor, ValorIntegerTeste) and (ValorIntegerTeste >= 0);
end;

{ ----------------------------------[ ROTA ]---------------------------------- }
// Rota @APIStatus
procedure TwmServerPedido.wmServerPedidoAPIStatusAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Writeln('#REQUEST APIStatus');
  Writeln(Request.Content);

  Response.ContentType := APP_JSON;
  Response.Content := '{"status": "OK", "message": "Servidor est� ativo"}';
  Response.StatusCode := 200;
  Handled := True;

  Writeln('#RESPONSE APIStatus');
  Writeln(Response.Content);
end;

// Rota @padr�o "/"
procedure TwmServerPedido.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  Mensagem: String;
begin
  Writeln('#REQUEST Index');
  Writeln(Request.Content);

  Mensagem := APP_404;
  Self.RetornaErro(Response, Mensagem, 404);
  Handled := True;

  Writeln('#RESPONSE Index');
  Writeln(Response.Content);
end;

// Rota @ListaClientes
procedure TwmServerPedido.wmServerPedidoListaClientesAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  Rota, SQL, ParametroID, ParametroValor, MensagemDeErro: String;
  CodigoDeSucesso, CodigoDeErro: Integer;
begin
  Writeln('#REQUEST ListaClientes');
  Writeln(Request.Content);

  Rota := 'rotaListaClientes';
  SQL := SQL_ListarClientes;
  ParametroID := '';
  ParametroValor := '';
  CodigoDeSucesso := 200;
  CodigoDeErro := 500;
  MensagemDeErro := ERR_LISTA_CLIENTES;

  Self.ListaAPI(Rota, SQL, ParametroID, ParametroValor
               , CodigoDeSucesso, CodigoDeErro
               , Response, Handled, MensagemDeErro );

  Writeln('#RESPONSE ListaClientes');
  Writeln(Response.Content);
end;


// Rota @ListaProdutos
procedure TwmServerPedido.WebModule1ListaProdutosAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  Rota, SQL, ParametroID, ParametroValor, MensagemDeErro: String;
  CodigoDeSucesso, CodigoDeErro: Integer;
begin
  Writeln('#REQUEST ListaProdutos');
  Writeln(Request.Content);

  Rota := 'rotaListaProdutos';
  SQL := SQL_ListarProdutos;
  ParametroID := '';
  ParametroValor := '';
  CodigoDeSucesso := 200;
  CodigoDeErro := 500;
  MensagemDeErro := ERR_LISTA_PRODUTOS;

  Self.ListaAPI(Rota, SQL, ParametroID, ParametroValor
               , CodigoDeSucesso, CodigoDeErro
               , Response, Handled, MensagemDeErro );

  Writeln('#RESPONSE ListaProdutos');
  Writeln(Response.Content);
end;

// Rota @ListaPedidos
procedure TwmServerPedido.WebModule1ListaPedidosAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  Rota, SQL, ParametroID, ParametroValor, MensagemDeErro: String;
  CodigoDeSucesso, CodigoDeErro: Integer;
begin
  Writeln('#REQUEST ListaPedidos');
  Writeln(Request.Content);

  Rota := 'rotaListaPedidos';
  SQL := SQL_ListarPedidos;
  ParametroID := '';
  ParametroValor := '';
  CodigoDeSucesso := 200;
  CodigoDeErro := 500;
  MensagemDeErro := ERR_LISTA_PEDIDOS;

  Self.ListaAPI(Rota, SQL, ParametroID, ParametroValor
               , CodigoDeSucesso, CodigoDeErro
               , Response, Handled, MensagemDeErro );

  Writeln('#RESPONSE ListaPedidos');
  Writeln(Response.Content);
end;

// Rota @InserePedido
procedure TwmServerPedido.WebModule1InserePedidoAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  FDQuery: TFDQuery;
  JSONRequest, JSONItens: TJSONObject;
  JSONArrayItens: TJSONArray;
  JSONItem: TJSONObject;
  I, PedidoID: Integer;
  MensagemDeErro: String;
begin
  Writeln('#REQUEST InserePedido');
  Writeln(Request.Content);

  JSONRequest := TJSONObject.ParseJSONValue(Request.Content) as TJSONObject;
  if not Assigned(JSONRequest) then
  begin
    Self.RetornaErro(Response, APP_REQUISICAO_INVALIDA, 400);
    Handled := True;
    Exit;
  end;

  try
    if not Self.ValidaInserePedido(Request, Response) then
    begin
      Handled := True;
      Exit;
    end;

    FDQuery := TFDQuery.Create(nil);
    try
      FDQuery.Connection := Self.cnPedidoDB;
      FDQuery.Connection.StartTransaction;  // Inicia a transa��o

      try
        // Insere o pedido no banco de dados
        FDQuery.SQL.Text := SQL_InserirPedido;
        FDQuery.ParamByName('codigo_cliente').AsInteger := JSONRequest.GetValue<Integer>('codigo_cliente');
        FDQuery.ParamByName('data_emissao_pedido').AsDate := StrToDate(JSONRequest.GetValue<string>('data_emissao_pedido'));
        FDQuery.ParamByName('valor_total_pedido').AsFloat := JSONRequest.GetValue<Double>('valor_total_pedido');
        FDQuery.ExecSQL;

        // Obter o ID gerado do pedido
        PedidoID := Self.cnPedidoDB.GetLastAutoGenValue('numero_pedido');

        // Processar os itens do pedido
        JSONArrayItens := JSONRequest.GetValue<TJSONArray>('itens');
        if not Assigned(JSONArrayItens) then
        begin
          raise Exception.Create(ERR_INSERE_ITEMAUSENTE);
        end;

        for I := 0 to JSONArrayItens.Count - 1 do
        begin
          JSONItem := JSONArrayItens.Items[I] as TJSONObject;

          // Insere cada item no banco de dados
          FDQuery.SQL.Text := SQL_AdicionarItemAoPedido;
          FDQuery.ParamByName('sequencia_pedido').AsInteger := PedidoID;
          FDQuery.ParamByName('codigo_produto').AsInteger := JSONItem.GetValue<Integer>('codigo_produto');
          FDQuery.ParamByName('quantidade_produto').AsFloat := JSONItem.GetValue<Double>('quantidade_produto');
          FDQuery.ParamByName('valor_unitario_produto').AsFloat := JSONItem.GetValue<Double>('valor_unitario_produto');
          FDQuery.ParamByName('valor_total_produto').AsFloat := JSONItem.GetValue<Double>('valor_total_produto');
          FDQuery.ExecSQL;
        end;

        FDQuery.Connection.Commit;  // Confirma a transa��o

        // Retorna sucesso com o ID do pedido criado
        Self.RetornaSucessoChave(Response, SU_INSERE_PEDIDO, 'numero_pedido', PedidoID, 201);
      except
        on E: Exception do
        begin
          FDQuery.Connection.Rollback;  // Desfaz a transa��o se algo falhar
          MensagemDeErro := ERR_INSERE_PEDIDO + #13#10 + E.Message;
          Self.RetornaErro(Response, MensagemDeErro, 500);
          Exit;
        end;
      end;
    finally
      FDQuery.Free;
    end;
  finally
    JSONRequest.Free;
  end;

  Writeln('#RESPONSE InserePedido');
  Writeln(Response.Content);
end;

// Rota @AdicionaItemAoPedido
procedure TwmServerPedido.WebModule1AdicionaItemAoPedidoAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  FDQuery: TFDQuery;
  PedidoID, ProdutoID: Integer;
  Quantidade, ValorUnitario, ValorTotal: Currency;
  MensagemDeErro: String;
begin
  Writeln('#REQUEST AdicionaItemAoPedido');
  Writeln(Request.Content);

  if Self.ValidaInserePedidoItem(Request, Response, Handled) then
  begin
    // Calcula o Valor Total
    ValorTotal := Quantidade * ValorUnitario;

    // Insere o item do pedido
    FDQuery := TFDQuery.Create(nil);
    try
      FDQuery.Connection := Self.cnPedidoDB;
      FDQuery.SQL.Text := SQL_AdicionarItemAoPedido;
      FDQuery.ParamByName('numero_pedido').AsInteger := PedidoID;
      FDQuery.ParamByName('codigo_produto').AsInteger := ProdutoID;
      FDQuery.ParamByName('quantidade').AsCurrency := Quantidade;
      FDQuery.ParamByName('valor_unitario').AsCurrency := ValorUnitario;
      FDQuery.ParamByName('valor_total').AsCurrency := ValorTotal;

      MensagemDeErro := ERR_INSERE_PEDIDOITEM;
      Self.InsereAPI(FDQuery, 'id', SU_INSERE_PEDIDOITEM, 201, 500, Response, Handled, MensagemDeErro);
    finally
      FDQuery.Free;
    end;
  end;

  Writeln('#RESPONSE AdicionaItemAoPedido');
  Writeln(Response.Content);
end;


// Rota @BuscaPedido
procedure TwmServerPedido.wmServerPedidoBuscaPedidoAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  PedidoID: String;
  FDQuery: TFDQuery;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  Campo: TField;
  Mensagem: String;
begin
  Writeln('#REQUEST BuscaPedido');
  Writeln(Request.Content);

  PedidoID := Request.ContentFields.Values['numero_pedido'];
  FDQuery := TFDQuery.Create(nil);
  FDQuery.Name := 'rotaBuscaPedido';
  JSONArray := TJSONArray.Create;
  try
    FDQuery.Connection := Self.cnPedidoDB;
    FDQuery.SQL.Text := SQL_BuscaPedido;
    FDQuery.ParamByName('numero_pedido').AsString := PedidoID;
    try
      FDQuery.Open;

      // Converte os resultados da query em JSON
      while not FDQuery.Eof do
      begin
        JSONObject := TJSONObject.Create;

        for Campo in FDQuery.Fields do
        begin
          JSONObject.AddPair(Campo.FieldName, Campo.AsString);
        end;

        JSONArray.AddElement(JSONObject);
        FDQuery.Next;
      end;

      FDQuery.SaveToFile(Self.FCache + FDQuery.Name + '.json', sfJSON);

      // Retorna o resultado em formato JSON
      Self.RetornaSucessoLista(Response, JSONArray.ToString, 200);
    except
      on E: Exception do
      begin
        Mensagem := ERR_BUSCA_PEDIDO + #13#10
                  + E.Message;
        Self.RetornaErro(Response, Mensagem, 500);
        Handled := True;
      end;
    end;
  finally
    FDQuery.Free;
    JSONArray.Free;
  end;

  Writeln('#RESPONSE BuscaPedido');
  Writeln(Response.Content);
end;

// Rota @BuscaItensDoPedido
procedure TwmServerPedido.wmServerPedidoBuscaItensDoPedidoAction(
  Sender: TObject; Request: TWebRequest; Response: TWebResponse;
  var Handled: Boolean);
var
  PedidoID: String;
  FDQuery: TFDQuery;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  Campo: TField;
  Mensagem: String;
begin
  Writeln('#REQUEST BuscaItensDoPedido');
  Writeln(Request.Content);

  PedidoID := Request.ContentFields.Values['numero_pedido'];
  FDQuery := TFDQuery.Create(nil);
  FDQuery.Name := 'rotaBuscaItensDoPedido';
  JSONArray := TJSONArray.Create;
  try
    FDQuery.Connection := Self.cnPedidoDB;
    FDQuery.SQL.Text := SQL_BuscaItensDoPedido;
    FDQuery.ParamByName('numero_pedido').AsString := PedidoID;
    try
      FDQuery.Open;

      // Converte os resultados da query em JSON
      while not FDQuery.Eof do
      begin
        JSONObject := TJSONObject.Create;

        for Campo in FDQuery.Fields do
        begin
          JSONObject.AddPair(Campo.FieldName, Campo.AsString);
        end;

        JSONArray.AddElement(JSONObject);
        FDQuery.Next;
      end;

      FDQuery.SaveToFile(Self.FCache + FDQuery.Name + '.json', sfJSON);

      // Retorna o resultado em formato JSON
      Self.RetornaSucessoLista(Response, JSONArray.ToString, 200);
    except
      on E: Exception do
      begin
        Mensagem := ERR_BUSCA_PEDIDOITENS + #13#10
                  + E.Message;
        Self.RetornaErro(Response, Mensagem, 500);
        Handled := True;
      end;
    end;
  finally
    FDQuery.Free;
    JSONArray.Free;
  end;

  Writeln('#RESPONSE BuscaItensDoPedido');
  Writeln(Response.Content);
end;

// Rota @ExcluiPedido
procedure TwmServerPedido.wmServerPedidoExcluiPedidoAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  PedidoID: String;
  FDQuery: TFDQuery;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  Campo: TField;
  Mensagem: String;
begin
  Writeln('#REQUEST ExcluiPedido');
  Writeln(Request.Content);

  PedidoID := Request.ContentFields.Values['numero_pedido'];
  FDQuery := TFDQuery.Create(nil);
  FDQuery.Name := 'rotaExcluiPedido';
  JSONArray := TJSONArray.Create;
  try
    FDQuery.Connection := Self.cnPedidoDB;
    FDQuery.SQL.Text := SQL_ExcluiPedido;
    FDQuery.ParamByName('numero_pedido').AsString := PedidoID;
    try
      FDQuery.ExecSQL;

      // Retorna o resultado em formato JSON
      Self.RetornaSucessoChave(Response, SU_EXCLUI_PEDIDO, 'numero_pedido', PedidoId.ToInteger, 200);
    except
      on E: Exception do
      begin
        Mensagem := ERR_EXCLUI_PEDIDO + #13#10
                  + E.Message;
        Self.RetornaErro(Response, Mensagem, 500);
        Handled := True;
      end;
    end;
  finally
    FDQuery.Free;
    JSONArray.Free;
  end;

  Writeln('#RESPONSE ExcluiPedido');
  Writeln(Response.Content);
end;


end.
