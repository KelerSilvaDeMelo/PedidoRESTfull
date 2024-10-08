unit UnitDMPedidoAPI;

interface

uses
  System.SysUtils, System.Classes, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, IdHTTP, IdSSLOpenSSL, System.JSON, ClientConstsPedido,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.StorageJSON, FireDAC.Stan.StorageBin, System.Net.HttpClient,
  System.Net.URLClient;

type
  TdmPedidoAPI = class(TDataModule)
    memClientes: TFDMemTable;
    memProdutos: TFDMemTable;
    memPedidos: TFDMemTable;
    StorageJSONLink: TFDStanStorageJSONLink;
    memPedidoItens: TFDMemTable;
    memPedidoItenssequencia_item: TFDAutoIncField;
    memPedidoItenssequencia_pedido: TIntegerField;
    memPedidoItenscodigo_produto: TIntegerField;
    memPedidoItensdescricao_produto: TStringField;
    memPedidoItensquantidade_produto: TBCDField;
    memPedidoItensvalor_unitario_produto: TBCDField;
    memPedidoItensvalor_total_produto: TBCDField;
    memClientescodigo_cliente: TFDAutoIncField;
    memClientesnome_cliente: TStringField;
    memProdutoscodigo_produto: TFDAutoIncField;
    memProdutosdescricao_produto: TStringField;
    memProdutospreco_venda_produto: TBCDField;
    memPedidossequencia_pedido: TFDAutoIncField;
    memPedidoscodigo_cliente: TIntegerField;
    memPedidosnome_cliente: TStringField;
    memPedidosdata_emissao_pedido: TDateField;
    memPedidosvalor_total_pedido: TBCDField;
    memPedidoCapa: TFDMemTable;
    FDAutoIncField1: TFDAutoIncField;
    IntegerField1: TIntegerField;
    StringField1: TStringField;
    DateField1: TDateField;
    BCDField1: TBCDField;
  private
    procedure ConfigurarMemTableClientes;
    procedure ConfigurarMemTableProdutos;
    procedure ConfigurarMemTablePedido;
    procedure ConfigurarMemTablePedidoItens;
    procedure ConfigurarMemTablePedidos;

    function getAPI(const URL: String; DataSetLista: TFDMemTable; var MensagemDeErro: String): Boolean;
    function GetIdAPI(const URL, ParametroID, ValorID: String; DataSetLista: TFDMemTable; var MensagemDeErro: String): Boolean;

    function DeleteAPI(const URL: String; var MensagemDeErro: String): Boolean;
    function DeleteIdAPI(const URL, ParametroID, ValorID: String; var MensagemDeErro: String): Boolean;

  public
    function ListarClientes(var MensagemDeErro: String): Boolean;
    function ListarProdutos(var MensagemDeErro: String): Boolean;
    function ListarPedidos(var MensagemDeErro: String): Boolean;

    function ProdutoExiste(CodigoDoProduto: Integer): Boolean;
    function BuscaValorDoProduto(CodigoDoProduto: Integer): Currency;
    function EnviaNovoPedido(DataSetPedido, DataSetItens: TFDMemTable; var MensagemDeErro: String): Boolean;
    function BuscaPedido(const SequenciaDoPedido: Integer; var MensagemDeErro: String): Boolean;
    function ExcluiPedido(const SequenciaDoPedido: Integer; var MensagemDeErro: String): Boolean;

  end;

implementation

uses
  UnitDMBaseAPI, System.NetEncoding, System.Generics.Collections;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}
{ --------------------------------[ PRIVADO ]--------------------------------- }

// Configura o MemTable Clientes
procedure TdmPedidoAPI.ConfigurarMemTableClientes;
begin
  Self.memClientes.Close;
  Self.memClientes.CreateDataSet;
  Self.memClientes.EmptyDataSet;
end;

// Configura o MemTable Produtos
procedure TdmPedidoAPI.ConfigurarMemTableProdutos;
begin
  Self.memProdutos.Close;
  Self.memProdutos.CreateDataSet;
  Self.memProdutos.EmptyDataSet;
end;

// Configura o MemTable Pedido
procedure TdmPedidoAPI.ConfigurarMemTablePedido;
begin
  Self.memPedidoCapa.Close;
  Self.memPedidoCapa.CreateDataSet;
  Self.memPedidoCapa.EmptyDataSet;
end;

// Configura o MemTable PedidoItens
procedure TdmPedidoAPI.ConfigurarMemTablePedidoItens;
begin
  Self.memPedidoItens.Close;
  Self.memPedidoItens.CreateDataSet;
  Self.memPedidoItens.EmptyDataSet;
end;

// Configura o MemTable Pedidos
procedure TdmPedidoAPI.ConfigurarMemTablePedidos;
begin
  Self.memPedidos.Close;
  Self.memPedidos.CreateDataSet;
end;

// Metodo base para listagem via API
function TdmPedidoAPI.getAPI(const URL: String; DataSetLista: TFDMemTable; var MensagemDeErro: String): Boolean;
var
  HTTPClient: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  JsonResponse: string;
  JsonArray: TJSONArray;
  JsonObject: TJSONObject;
  I: Integer;
  Campo: TField;
begin
  Result := False;

  HTTPClient := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    HTTPClient.IOHandler := SSLHandler;

    try
      // Faz a requisi��o GET para a URL (caso tenha par�metros, devem ser codificados antes)
      JsonResponse := HTTPClient.Get(URL); //TNetEncoding.URL.Encode(URL)

      // Verifica se a resposta � um JSON array
      JsonArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(JsonResponse), 0) as TJSONArray;

      if JsonArray = nil then
        raise Exception.Create(MSG_ERRO_SERVIDOR_RESPOSTA_INVALIDA);

      // Insere os dados no DataSet
      for I := 0 to JsonArray.Count - 1 do
      begin
        JsonObject := JsonArray.Items[I] as TJSONObject;
        DataSetLista.Append;
        for Campo in DataSetLista.Fields do
        begin
          Campo.Value := JsonObject.GetValue<String>(Campo.FieldName);
        end;
        DataSetLista.Post;
      end;

      // Salva o cache localmente (opcional)
      DataSetLista.SaveToFile(dmGlobalAPI.PastaCache + 'ClientCache_' + DataSetLista.Name + '.json', sfJSON);

      Result := True;
    except
      on E: Exception do
        MensagemDeErro := MensagemDeErro + #13#10 + E.Message;
    end;
  finally
    HTTPClient.Free;
    SSLHandler.Free;
  end;
end;

function TdmPedidoAPI.GetIdAPI(const URL, ParametroID, ValorID: String; DataSetLista: TFDMemTable; var MensagemDeErro: String): Boolean;
var
  UrlProtegida: String;
begin
  UrlProtegida := URL + '?' + TNetEncoding.URL.Encode(ParametroID) + '=' + TNetEncoding.URL.Encode(ValorID);
  Result := Self.getAPI(UrlProtegida, DataSetLista, MensagemDeErro);
end;

function TdmPedidoAPI.DeleteAPI(const URL: String; var MensagemDeErro: String): Boolean;
var
  HTTPClient: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  JsonResponse: string;
  JsonObject: TJSONObject;
  JSONValue: TJSONValue;
begin
  Result := False;

  HTTPClient := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    HTTPClient.IOHandler := SSLHandler;

    try
      // Faz a requisi��o DELETE com os par�metros
      JsonResponse := HTTPClient.Delete(URL);

      // Verifica o c�digo de status da resposta HTTP
      if HTTPClient.ResponseCode = 200 then
      begin
        // Verifica se a resposta n�o � vazia e se � um JSON v�lido
        if JsonResponse <> '' then
        begin
          JSONValue := TJSONObject.ParseJSONValue(JsonResponse);

          if Assigned(JSONValue) and (JSONValue is TJSONObject) then
          begin
            JsonObject := TJSONObject(JSONValue);
            try
              // Verifica se a resposta cont�m uma mensagem de erro ou sucesso
              if JsonObject.GetValue('message') <> nil then
                MensagemDeErro := JsonObject.GetValue('message').Value;

              // Se tiver um campo "numero_pedido", considere a opera��o bem-sucedida
              if JsonObject.GetValue('numero_pedido') <> nil then
                Result := True;
            finally
              JsonObject.Free;
            end;
          end
          else
            MensagemDeErro := MSG_ERRO_SERVIDOR_RESPOSTA_INVALIDA;
        end;
      end
      else
      begin
        MensagemDeErro := MensagemDeErro + #13#10 + #13#10 +
         Format('Erro HTTP: %d - %s', [HTTPClient.ResponseCode, HTTPClient.ResponseText]);
      end;

    except
      on E: Exception do
        MensagemDeErro := MensagemDeErro + #13#10 + E.Message;
    end;

  finally
    HTTPClient.Free;
    SSLHandler.Free;
  end;
end;


function TdmPedidoAPI.DeleteIdAPI(const URL, ParametroID, ValorID: String;
  var MensagemDeErro: String): Boolean;
var
  UrlProtegida: String;
begin
  // Codifica apenas o valor do par�metro
  UrlProtegida := URL + '?' + ParametroID + '=' + TNetEncoding.URL.Encode(ValorID);
  Result := Self.DeleteAPI(UrlProtegida, MensagemDeErro);
end;


{ --------------------------------[ P�BLICO ]--------------------------------- }

// Lista os clientes e popula o MemTable Clientes
function TdmPedidoAPI.ListarClientes(var MensagemDeErro: String): Boolean;
var
  URL: string;
begin
  URL := ENDPOINT_LISTA_CLIENTES;
  MensagemDeErro := MSG_ERRO_LISTAR_CLIENTES;

  Self.ConfigurarMemTableClientes;
  Result := Self.getAPI(URL, Self.memClientes, MensagemDeErro);
end;

// Lista os produtos e popula o MemTable Produtos
function TdmPedidoAPI.ListarProdutos(var MensagemDeErro: String): Boolean;
var
  URL: string;
begin
  URL := ENDPOINT_LISTA_PRODUTOS;
  MensagemDeErro := MSG_ERRO_LISTAR_PRODUTOS;

  Self.ConfigurarMemTableProdutos;
  Result := Self.getAPI(URL, Self.memProdutos, MensagemDeErro);
end;

// Lista os pedidos e popula o MemTable Pedidos
function TdmPedidoAPI.ListarPedidos(var MensagemDeErro: String): Boolean;
var
  URL: string;
begin
  URL := ENDPOINT_LISTA_PEDIDOS;
  MensagemDeErro := MSG_ERRO_LISTAR_PRODUTOS;

  Self.ConfigurarMemTablePedidos;
  Result := Self.getAPI(URL, Self.memPedidos, MensagemDeErro);
end;

// Verifica a exist�ncia de um produto espec�fico
function TdmPedidoAPI.ProdutoExiste(CodigoDoProduto: Integer): Boolean;
var
  Marcador: TBookmark;
begin
  Marcador := Self.memProdutos.Bookmark;
  Self.memProdutos.DisableControls;
  Self.memProdutos.First;
  Result := Self.memProdutos.Locate('codigo_produto', CodigoDoProduto, [loCaseInsensitive]);
  Self.memProdutos.Bookmark := Marcador;
  Self.memProdutos.EnableControls;
end;

// Busca o valor de um produto espec�fico.
function TdmPedidoAPI.BuscaValorDoProduto(CodigoDoProduto: Integer): Currency;
var
  Marcador: TBookmark;
begin
  Result := 0.00;
  Marcador := Self.memProdutos.Bookmark;
  Self.memProdutos.DisableControls;
  Self.memProdutos.First;
  if Self.memProdutos.Locate('codigo_produto', CodigoDoProduto, [loCaseInsensitive]) then
  begin
    Result := Self.memProdutospreco_venda_produto.AsCurrency;
  end;
  Self.memProdutos.Bookmark := Marcador;
  Self.memProdutos.EnableControls;
end;

// Envia o novo pedido ao servidor de aplica��o
function TdmPedidoAPI.EnviaNovoPedido(DataSetPedido, DataSetItens: TFDMemTable;
  var MensagemDeErro: String): Boolean;
var
  JSONTable: TJSONArray;
  JSONRow, JSONPedido, JSONResponse: TJSONObject;
  Campo: TField;
  Marcador: TBookmark;
  HTTPClient: THTTPClient;
  StringStream: TStringStream;
  Response: IHTTPResponse;
  PedidoID: Integer;
  ResponseContent: String;
begin
  Result := False;
  JSONTable := TJSONArray.Create;
  Marcador := DataSetItens.Bookmark;

  // Monta o array JSON dos itens do pedido
  DataSetItens.DisableControls;
  DataSetItens.First;
  while not DataSetItens.Eof do
  begin
    JSONRow := TJSONObject.Create;
    JSONRow.AddPair('sequencia_pedido', DataSetItens.FieldByName('sequencia_pedido').AsString);
    JSONRow.AddPair('codigo_produto', DataSetItens.FieldByName('codigo_produto').AsString);
    JSONRow.AddPair('quantidade_produto', DataSetItens.FieldByName('quantidade_produto').AsString);
    JSONRow.AddPair('valor_unitario_produto', TJSONNumber.Create(DataSetItens.FieldByName('valor_unitario_produto').AsCurrency));
    JSONRow.AddPair('valor_total_produto', TJSONNumber.Create(DataSetItens.FieldByName('valor_total_produto').AsCurrency));
    JSONTable.AddElement(JSONRow);
    DataSetItens.Next;
  end;
  DataSetItens.GotoBookmark(Marcador);
  DataSetItens.EnableControls;

  // Monta o objeto JSON do pedido
  JSONPedido := TJSONObject.Create;
  try
    JSONPedido.AddPair('codigo_cliente', DataSetPedido.FieldByName('codigo_cliente').AsString);
    JSONPedido.AddPair('data_emissao_pedido', DataSetPedido.FieldByName('data_emissao_pedido').AsString);
    JSONPedido.AddPair('valor_total_pedido', TJSONNumber.Create(DataSetPedido.FieldByName('valor_total_pedido').AsCurrency));
    JSONPedido.AddPair('itens', JSONTable); // Adiciona o array de itens ao pedido

    // Converte o objeto JSON em string para enviar no corpo da requisi��o
    StringStream := TStringStream.Create(JSONPedido.ToString, TEncoding.UTF8);
    HTTPClient := THTTPClient.Create;
    try
      // Envia a requisi��o POST com o corpo JSON
      Response := HTTPClient.Post(ENDPOINT_INCLUI_PEDIDO, StringStream, nil, [TNetHeader.Create('Content-Type', 'application/json')]);

      // Verifica o c�digo de status da resposta
      if Response.StatusCode = 201 then
      begin
        Result := True;
        ResponseContent := Response.ContentAsString;

        // Analisa o conte�do JSON da resposta
        JSONResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;
        try
          if Assigned(JSONResponse) then
          begin
            // Extrai o valor de pedido_id
            PedidoID := JSONResponse.GetValue<Integer>('numero_pedido');

            // Atualiza o campo 'sequencia_pedido' no DataSet
            DataSetPedido.FieldByName('sequencia_pedido').AsInteger := PedidoID;
          end;
        finally
          JSONResponse.Free;
        end;
      end
      else
      begin
        MensagemDeErro := MensagemDeErro + #13#10 + Response.ContentAsString;
      end;
    finally
      StringStream.Free;
      HTTPClient.Free;
    end;
  finally
    JSONPedido.Free;
    // JSONTable.Free; j� esta limpo
  end;
end;

// Busca um pedido espec�fico.
function TdmPedidoAPI.BuscaPedido(const SequenciaDoPedido: Integer; var MensagemDeErro: String): Boolean;
var
  URL, ParametroID, ParametroValor: String;
begin
  Result := False;
  Self.ConfigurarMemTablePedido;
  Self.ConfigurarMemTablePedidoItens;

  URL := ENDPOINT_BUSCA_PEDIDO;
  ParametroID := 'numero_pedido';
  ParametroValor := SequenciaDoPedido.ToString;
  MensagemDeErro := MSG_ERRO_BUSCAR_PEDIDO;

  Result := Self.GetIdAPI(URL, ParametroID, ParametroValor, Self.memPedidoCapa, MensagemDeErro);
  if not Result then
    Exit;

  URL := ENDPOINT_BUSCA_ITENS_PEDIDO;
  ParametroID := 'numero_pedido';
  Result := Self.GetIdAPI(URL, ParametroID, ParametroValor, Self.memPedidoItens, MensagemDeErro);
end;

// Exclui um pedido espec�fico.
function TdmPedidoAPI.ExcluiPedido(const SequenciaDoPedido: Integer;
  var MensagemDeErro: String): Boolean;
var
  URL, ParametroID, ParametroValor: String;
begin
  Result := False;

  URL := ENDPOINT_EXCLUI_PEDIDO;
  ParametroID := 'numero_pedido';
  ParametroValor := SequenciaDoPedido.ToString;
  MensagemDeErro := MSG_ERRO_EXCLUI_PEDIDO;

//  Result := Self.ListaIdAPI(URL, ParametroID, ParametroValor, Self.memPedidoCapa, MensagemDeErro);
  Result := Self.DeleteIdAPI(URL, ParametroID, ParametroValor, MensagemDeErro);
end;

end.
