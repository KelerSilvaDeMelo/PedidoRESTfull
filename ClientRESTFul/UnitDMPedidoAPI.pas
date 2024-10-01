unit UnitDMPedidoAPI;

interface

uses
  System.SysUtils, System.Classes, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, IdHTTP, IdSSLOpenSSL, System.JSON, ClientConstsPedido,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.StorageJSON, FireDAC.Stan.StorageBin;

type
  TdmPedidoAPI = class(TDataModule)
    FDMemTableClientes: TFDMemTable;
    FDMemTableProdutos: TFDMemTable;
    FDMemTablePedidos: TFDMemTable;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDMemTableItens: TFDMemTable;
  private
    procedure ConfigurarMemTableClientes;
    procedure ConfigurarMemTableProdutos;
    procedure ConfigurarMemTablePedidos;
    procedure ConfigurarMemTableItens;

  public
    procedure ListarClientes;
    procedure ListarProdutos;
    procedure ListarPedidos;
    procedure ListarItensDoPedido;
  end;

var
  dmPedidoAPI: TdmPedidoAPI;

implementation

uses
  UnitDMBaseAPI;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}
{ --------------------------------[ PRIVADO ]--------------------------------- }

// Configura o TFDMemTableClientes
procedure TdmPedidoAPI.ConfigurarMemTableClientes;
begin
  Self.FDMemTableClientes.Close;
  Self.FDMemTableClientes.CreateDataSet;
end;

// Configura o TFDMemTableProdutos
procedure TdmPedidoAPI.ConfigurarMemTableProdutos;
begin
  Self.FDMemTableProdutos.Close;
  Self.FDMemTableProdutos.CreateDataSet;
end;

// Configura o TFDMemTablePedidos
procedure TdmPedidoAPI.ConfigurarMemTablePedidos;
begin
  Self.FDMemTablePedidos.Close;
  Self.FDMemTablePedidos.CreateDataSet;
end;

// Configura o TFDMemTableItens
procedure TdmPedidoAPI.ConfigurarMemTableItens;
begin
  Self.FDMemTableItens.Close;
  Self.FDMemTableItens.CreateDataSet;
end;


{ --------------------------------[ P�BLICO ]--------------------------------- }

// Lista os clientes e popula o TFDMemTableClientes
procedure TdmPedidoAPI.ListarClientes;
var
  HTTPClient: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Url: string;
  JsonResponse: string;
  JsonArray: TJSONArray;
  JsonObject: TJSONObject;
  I: Integer;
  Campo: TField;
begin
  HTTPClient := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    HTTPClient.IOHandler := SSLHandler;
    Url := ENDPOINT_LISTAR_CLIENTES;

    // As constante est�o definida em ClientConstsPedido
    try
      JsonResponse := HTTPClient.Get(Url);
      JsonArray := TJSONObject.ParseJSONValue
        (TEncoding.UTF8.GetBytes(JsonResponse), 0) as TJSONArray;

      if JsonArray = nil then
        raise Exception.Create('Resposta inv�lida do servidor.');

      ConfigurarMemTableClientes;
      FDMemTableClientes.EmptyDataSet;

      for I := 0 to JsonArray.Count - 1 do
      begin
        JsonObject := JsonArray.Items[I] as TJSONObject;
        FDMemTableClientes.Append;
        for Campo in FDMemTableClientes.Fields do
        begin
          Campo.Value := JsonObject.GetValue<String>(Campo.FieldName);
        end;
        FDMemTableClientes.Post;
      end;

      FDMemTableClientes.SaveToFile( dmBaseAPI.PastaCache + FDMemTableClientes.Name + '.json', sfJSON );
    except
      on E: Exception do
        raise Exception.Create('Indisponibilidade moment�nea na lista de clientes: ' +
          E.Message);
    end;
  finally
    HTTPClient.Free;
    SSLHandler.Free;
  end;
end;

// Lista os produtos e popula o TFDMemTableProdutos
procedure TdmPedidoAPI.ListarProdutos;
var
  HTTPClient: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Url: string;
  JsonResponse: string;
  JsonArray: TJSONArray;
  JsonObject: TJSONObject;
  I: Integer;
  Campo: TField;
  Canoi: TObject;
begin
  HTTPClient := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    HTTPClient.IOHandler := SSLHandler;
    Url := ENDPOINT_LISTAR_PRODUTOS;
    try
      JsonResponse := HTTPClient.Get(Url);
      JsonArray := TJSONObject.ParseJSONValue
        (TEncoding.UTF8.GetBytes(JsonResponse), 0) as TJSONArray;

      if JsonArray = nil then
        raise Exception.Create('Resposta inv�lida do servidor.');

      ConfigurarMemTableProdutos;
      FDMemTableProdutos.EmptyDataSet;

      for I := 0 to JsonArray.Count - 1 do
      begin
        JsonObject := JsonArray.Items[I] as TJSONObject;
        FDMemTableProdutos.Append;

        for Campo in FDMemTableProdutos.Fields do
        begin
          Campo.Value := JsonObject.GetValue<String>(Campo.FieldName);
        end;

        FDMemTableProdutos.Post;
      end;

      FDMemTableProdutos.SaveToFile( dmBaseAPI.PastaCache + FDMemTableProdutos.Name + '.json', sfJSON );
    except
      on E: Exception do
        raise Exception.Create('Indisponibilidade moment�nea na lista de produtos: ' +
          E.Message);
    end;
  finally
    HTTPClient.Free;
    SSLHandler.Free;
  end;
end;

// Lista os pedidos e popula o TFDMemTablePedidos
procedure TdmPedidoAPI.ListarPedidos;
var
  HTTPClient: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Url: string;
  JsonResponse: string;
  JsonArray: TJSONArray;
  JsonObject: TJSONObject;
  I: Integer;
  Campo: TField;
begin
  HTTPClient := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    HTTPClient.IOHandler := SSLHandler;
    Url := ENDPOINT_LISTAR_PEDIDOS;
    try
      JsonResponse := HTTPClient.Get(Url);
      JsonArray := TJSONObject.ParseJSONValue
        (TEncoding.UTF8.GetBytes(JsonResponse), 0) as TJSONArray;

      if JsonArray = nil then
        raise Exception.Create('Resposta inv�lida do servidor.');

      ConfigurarMemTablePedidos;
      FDMemTablePedidos.EmptyDataSet;

      for I := 0 to JsonArray.Count - 1 do
      begin
        JsonObject := JsonArray.Items[I] as TJSONObject;
        FDMemTablePedidos.Append;

        for Campo in FDMemTablePedidos.Fields do
        begin
          Campo.Value := JsonObject.GetValue<String>(Campo.FieldName);
        end;

        FDMemTablePedidos.Post;
      end;

      FDMemTablePedidos.SaveToFile( dmBaseAPI.PastaCache + FDMemTablePedidos.Name + '.json', sfJSON );
    except
      on E: Exception do
        raise Exception.Create('Indisponibilidade moment�nea na lista de pedidos: ' +
          E.Message);
    end;
  finally
    HTTPClient.Free;
    SSLHandler.Free;
  end;
end;

procedure TdmPedidoAPI.ListarItensDoPedido;
var
  HTTPClient: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Url: string;
  JsonResponse: string;
  JsonArray: TJSONArray;
  JsonObject: TJSONObject;
  I: Integer;
  Campo: TField;
begin
  HTTPClient := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    HTTPClient.IOHandler := SSLHandler;
    Url := ENDPOINT_LISTAR_ITENS_DO_PEDIDO;
    try
      JsonResponse := HTTPClient.Get(Url);
      JsonArray := TJSONObject.ParseJSONValue
        (TEncoding.UTF8.GetBytes(JsonResponse), 0) as TJSONArray;

      if JsonArray = nil then
        raise Exception.Create('Resposta inv�lida do servidor.');

      ConfigurarMemTableItens;
      FDMemTableItens.EmptyDataSet;

      for I := 0 to JsonArray.Count - 1 do
      begin
        JsonObject := JsonArray.Items[I] as TJSONObject;
        FDMemTableItens.Append;

        for Campo in FDMemTableItens.Fields do
        begin
          Campo.Value := JsonObject.GetValue<String>(Campo.FieldName);
        end;

        FDMemTableItens.Post;
      end;

      FDMemTableItens.SaveToFile( dmBaseAPI.PastaCache + FDMemTableItens.Name + '.json', sfJSON );
    except
      on E: Exception do
        raise Exception.Create('Indisponibilidade moment�nea na lista de pedidos: ' +
          E.Message);
    end;
  finally
    HTTPClient.Free;
    SSLHandler.Free;
  end;
end;

end.
