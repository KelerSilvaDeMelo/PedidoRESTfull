unit UnitDMPedidoClient;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.StorageBin, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, UnitDMPedidoAPI;

type
  TdmPedidoClient = class(TDataModule)
    memPedidoCapa: TFDMemTable;
    pcSequencia: TFDAutoIncField;
    pcCodigoCliente: TIntegerField;
    pcDataEmissao: TDateField;
    pcValorTotalPedido: TBCDField;
    memPedidoItem: TFDMemTable;
    piCodigoProduto: TIntegerField;
    piQuantidadeProduto: TIntegerField;
    piValorUnitarioProduto: TCurrencyField;
    memItensDoPedido: TFDMemTable;
    itensSequencia: TFDAutoIncField;
    itensPedido: TIntegerField;
    ItensCodigoProduto: TIntegerField;
    itensDescricaoProduto: TStringField;
    itensQuantidadeProduto: TBCDField;
    itensValorUnitarioProduto: TBCDField;
    itensValorTotalProduto: TBCDField;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure piCodigoProdutoChange(Sender: TField);
  private
    { Private symbols }
    FPedidoAPI: TdmPedidoAPI;
  private
    { Private declarations }
  public
    { Public declarations }
    function NovoPedido(MensagemDeErro: String): Boolean;
    function ProdutoExiste: Boolean;
    function BuscaValorDoProduto(CodigoDoProduto: Integer): Currency;
    function IncluirItem(Descricao: String): Boolean;
    procedure RecalculaTotais;
    procedure ApagaItemPosicionado;
    function EnviaNovoPedido(DataDaEmissao: TDate; var MensagemDeErro: String): Boolean;
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}


{ TdmPedidoClient }

{--------------------------------[ CONSTRUÇÃO ]--------------------------------}
procedure TdmPedidoClient.DataModuleCreate(Sender: TObject);
begin
  Self.FPedidoAPI := TdmPedidoAPI.Create(nil);
end;

procedure TdmPedidoClient.DataModuleDestroy(Sender: TObject);
begin
  Self.FPedidoAPI.Destroy;
end;


{---------------------------------[ INTERNO ]----------------------------------}
procedure TdmPedidoClient.piCodigoProdutoChange(Sender: TField);
var
  CodigoDoProduto: Integer;
  ValorDoProduto: Currency;
begin
  CodigoDoProduto := Self.piCodigoProduto.AsInteger;
  ValorDoProduto := Self.BuscaValorDoProduto(CodigoDoProduto);
  Self.piValorUnitarioProduto.AsCurrency := ValorDoProduto;
end;


{---------------------------------[ PUBLICO ]----------------------------------}
function TdmPedidoClient.NovoPedido(MensagemDeErro: String): Boolean;
begin
  Result := (Self.FPedidoAPI.ListarClientes(MensagemDeErro) and
    Self.FPedidoAPI.ListarProdutos(MensagemDeErro));

  if Result then
  begin
    Self.memPedidoCapa.Close;
    Self.memPedidoCapa.CreateDataSet;
    Self.memPedidoCapa.Append;

    Self.memPedidoItem.Close;
    Self.memPedidoItem.CreateDataSet;
    Self.memPedidoItem.Append;

    Self.memItensDoPedido.Close;
    Self.memItensDoPedido.CreateDataSet;
  end;
end;

function TdmPedidoClient.ProdutoExiste: Boolean;
var
  CodigoProduto: Integer;
begin
  CodigoProduto := Self.piCodigoProduto.AsInteger;
  Result := Self.FPedidoAPI.ProdutoExiste(CodigoProduto);
end;

function TdmPedidoClient.BuscaValorDoProduto(
  CodigoDoProduto: Integer): Currency;
begin
  Result := Self.FPedidoAPI.BuscaValorDoProduto(CodigoDoProduto);
end;

function TdmPedidoClient.IncluirItem(Descricao: String): Boolean;
begin
  Self.memItensDoPedido.Append;
  Self.ItensCodigoProduto.Value := Self.piCodigoProduto.Value;
  Self.itensDescricaoProduto.Value := Descricao;
  Self.itensQuantidadeProduto.Value := Self.piQuantidadeProduto.Value;
  Self.itensValorUnitarioProduto.Value := Self.piValorUnitarioProduto.Value;
  Self.memItensDoPedido.Post;

  Self.piQuantidadeProduto.Clear;
  Self.piValorUnitarioProduto.Clear;

  Self.RecalculaTotais;
end;

procedure TdmPedidoClient.ApagaItemPosicionado;
begin
  if not Self.memItensDoPedido.IsEmpty then
  begin
    Self.memItensDoPedido.Delete;
    Self.RecalculaTotais;
  end;
end;

procedure TdmPedidoClient.RecalculaTotais;
var
  Marcador: TBookmark;
  TotalDoItem, SomatoriaDoPedido: Currency;
begin
  TotalDoItem := 0.00;
  SomatoriaDoPedido := 0.00;
  Marcador := Self.memItensDoPedido.Bookmark;

  Self.memItensDoPedido.DisableControls;
  Self.memItensDoPedido.First;

  while not Self.memItensDoPedido.Eof do
  begin
    TotalDoItem := Self.itensQuantidadeProduto.Value * Self.itensValorUnitarioProduto.Value;

    if Self.itensValorTotalProduto.AsCurrency <> TotalDoItem then
    begin
      Self.memItensDoPedido.Edit;
      Self.itensValorTotalProduto.AsCurrency := TotalDoItem;
      Self.memItensDoPedido.Post;
    end;

    SomatoriaDoPedido := SomatoriaDoPedido + TotalDoItem;
    Self.memItensDoPedido.Next;
  end;

  Self.memItensDoPedido.GotoBookmark(Marcador);
  Self.memItensDoPedido.Edit;
  Self.memItensDoPedido.EnableControls;

  Self.pcValorTotalPedido.AsCurrency := SomatoriaDoPedido;
end;

function TdmPedidoClient.EnviaNovoPedido(DataDaEmissao: TDate; var MensagemDeErro: String): Boolean;
begin
  Self.pcDataEmissao.AsDateTime := DataDaEmissao;
  Result := Self.FPedidoAPI.EnviaNovoPedido(memPedidoCapa, memItensDoPedido, MensagemDeErro);
end;


end.
