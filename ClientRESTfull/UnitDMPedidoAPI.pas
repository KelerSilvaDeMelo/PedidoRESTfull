unit UnitDMPedidoAPI;

interface

uses
  System.SysUtils, System.Classes, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, IdHTTP, IdSSLOpenSSL, System.JSON, ClientConstsPedido,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.StorageJSON, FireDAC.Stan.StorageBin, System.Net.HttpClient;

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
  private
    procedure ConfigurarMemTableClientes;
    procedure ConfigurarMemTableProdutos;
    procedure ConfigurarMemTablePedidos;
    procedure ConfigurarMemTableItens;

    function ListaAPI(const URL: String; DataSetLista: TFDMemTable; var MensagemDeErro: String): Boolean;

  public
    function ListarClientes(var MensagemDeErro: String): Boolean;
    function ListarProdutos(var MensagemDeErro: String): Boolean;
    function ListarPedidos(var MensagemDeErro: String): Boolean;
    function ListarItensDoPedido(var MensagemDeErro: String): Boolean;

    function ProdutoExiste(CodigoDoProduto: Integer): Boolean;
    function BuscaValorDoProduto(CodigoDoProduto: Integer): Currency;
    function EnviaNovoPedido(DataSetPedido, DataSetItens: TFDMemTable; var MensagemDeErro: String): Boolean;
  end;

implementation

uses
  UnitDMBaseAPI;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}
{ --------------------------------[ PRIVADO ]--------------------------------- }

// Configura o MemTable Clientes
procedure TdmPedidoAPI.ConfigurarMemTableClientes;
begin
  Self.memClientes.Close;
  Self.memClientes.CreateDataSet;
end;

// Configura o MemTable Produtos
procedure TdmPedidoAPI.ConfigurarMemTableProdutos;
begin
  Self.memProdutos.Close;
  Self.memProdutos.CreateDataSet;
end;

// Configura o MemTable Pedidos
procedure TdmPedidoAPI.ConfigurarMemTablePedidos;
begin
  Self.memPedidos.Close;
  Self.memPedidos.CreateDataSet;
end;

// Configura o MemTable Itens
procedure TdmPedidoAPI.ConfigurarMemTableItens;
begin
  Self.memPedidoItens.Close;
  Self.memPedidoItens.CreateDataSet;
end;

// Metodo base para listagem via API
function TdmPedidoAPI.ListaAPI(const URL: String; DataSetLista: TFDMemTable; var MensagemDeErro: String): Boolean;
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
      JsonResponse := HTTPClient.Get(Url);
      JsonArray := TJSONObject.ParseJSONValue
        (TEncoding.UTF8.GetBytes(JsonResponse), 0) as TJSONArray;

      if JsonArray = nil then
        raise Exception.Create('Resposta inv�lida do servidor.');

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

      DataSetLista.SaveToFile( dmGlobalAPI.PastaCache + 'ClientCache_' + DataSetLista.Name + '.json', sfJSON );
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


{ --------------------------------[ P�BLICO ]--------------------------------- }

// Lista os clientes e popula o MemTable Clientes
function TdmPedidoAPI.ListarClientes(var MensagemDeErro: String): Boolean;
var
  URL: string;
begin
  URL := ENDPOINT_LISTAR_CLIENTES;
  MensagemDeErro := MSG_ERRO_LISTAR_CLIENTES;

  Self.ConfigurarMemTableClientes;
  Result := Self.ListaAPI(URL, Self.memClientes, MensagemDeErro);
end;

// Lista os produtos e popula o MemTable Produtos
function TdmPedidoAPI.ListarProdutos(var MensagemDeErro: String): Boolean;
var
  URL: string;
begin
  URL := ENDPOINT_LISTAR_PRODUTOS;
  MensagemDeErro := MSG_ERRO_LISTAR_PRODUTOS;

  Self.ConfigurarMemTableProdutos;
  Result := Self.ListaAPI(URL, Self.memProdutos, MensagemDeErro);
end;

// Lista os pedidos e popula o MemTable Pedidos
function TdmPedidoAPI.ListarPedidos(var MensagemDeErro: String): Boolean;
var
  URL: string;
begin
  URL := ENDPOINT_LISTAR_PEDIDOS;
  MensagemDeErro := MSG_ERRO_LISTAR_PRODUTOS;

  Self.ConfigurarMemTablePedidos;
  Result := Self.ListaAPI(URL, Self.memPedidos, MensagemDeErro);
end;

// Lista os pedidos e popula o MemTable ItensDoPedidos
function TdmPedidoAPI.ListarItensDoPedido(var MensagemDeErro: String): Boolean;
var
  URL: string;
begin
  URL := ENDPOINT_LISTAR_ITENS_DO_PEDIDO;
  MensagemDeErro := MSG_ERRO_LISTAR_PEDIDO_ITENS;

  Self.ConfigurarMemTableProdutos;
  Result := Self.ListaAPI(URL, Self.memPedidoItens, MensagemDeErro);
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

function TdmPedidoAPI.EnviaNovoPedido(DataSetPedido, DataSetItens: TFDMemTable;
  var MensagemDeErro: String): Boolean;
var
  HTTPClient: THTTPClient;
  Params: TStringList;
  Response: IHTTPResponse;
  JsonResponse: TJSONObject;
  PedidoID: Integer;
  ResponseContent, CodigoCliente, DataEmissao, ValorTotal: String;
begin
  Result := False;
  HTTPClient := THTTPClient.Create;
  Params := TStringList.Create;
  JsonResponse := nil;
  try
    // Preenche os dados do pedido
    CodigoCliente := DataSetPedido.FieldByName('codigo_cliente').AsString;
    DataEmissao := DataSetPedido.FieldByName('data_emissao_pedido').AsString;
    ValorTotal := DataSetPedido.FieldByName('valor_total_pedido').AsString;

    Params.Add('cliente_id=' + CodigoCliente);
    Params.Add('data=' + DataEmissao);
    Params.Add('valor_total=' + ValorTotal);

    // Envia a requisi��o POST para o servidor
    Response := HTTPClient.Post(ENDPOINT_INCLUIR_PEDIDO, Params);

    // Verifica o c�digo de status da resposta
    if Response.StatusCode = 201 then
    begin
      Result := True;
      ResponseContent := Response.ContentAsString;

      // Analisa o conte�do JSON da resposta
      JsonResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;
      try
        if Assigned(JsonResponse) then
        begin
          // Extrai o valor de pedido_id
          PedidoID := JsonResponse.GetValue<Integer>('pedido_id');

          // Atualiza o campo 'sequencia_pedido' no DataSet
          DataSetPedido.FieldByName('sequencia_pedido').AsInteger := PedidoID;
        end;
      finally
        JsonResponse.Free;
      end;
    end
    else
    begin
      MensagemDeErro := MensagemDeErro + #13#10 + Response.ContentAsString;
    end;
  finally
    Params.Free;
    HTTPClient.Free;
  end;
end;

end.
