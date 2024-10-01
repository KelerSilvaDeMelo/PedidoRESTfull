unit UnitFormIncluirPedido;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UnitDMPedidoAPI, Data.DB, Vcl.DBCtrls,
  Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.StorageBin, Vcl.WinXPickers, Vcl.Mask, Vcl.ExtCtrls;

type
  TFormIncluirPedido = class(TForm)
    Label1: TLabel;
    DBLookupComboBox1: TDBLookupComboBox;
    dsClientes: TDataSource;
    mtPedidoCapa: TFDMemTable;
    mtPedidoItens: TFDMemTable;
    dsCapa: TDataSource;
    dsItens: TDataSource;
    DatePicker1: TDatePicker;
    Label2: TLabel;
    Label3: TLabel;
    DBGrid1: TDBGrid;
    mtPedidoItensid_pedido_item: TFDAutoIncField;
    mtPedidoItensnumero_pedido_item: TIntegerField;
    mtPedidoItenscodigo_produto_pedido_item: TIntegerField;
    mtPedidoItensquantidade_pedido_item: TBCDField;
    mtPedidoItensvalor_unitario_pedido_item: TBCDField;
    mtPedidoItensvalor_total_pedido_item: TBCDField;
    mtPedidoCapanumero_pedido: TFDAutoIncField;
    mtPedidoCapacodigo_cliente: TIntegerField;
    mtPedidoCapadata_emissao_pedido: TDateField;
    mtPedidoCapavalor_total_pedido: TBCDField;
    Label4: TLabel;
    DBEdit1: TDBEdit;
    Button1: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mtPedidoItensNewRecord(DataSet: TDataSet);
    procedure mtPedidoCapaNewRecord(DataSet: TDataSet);
    procedure mtPedidoItensquantidade_pedido_itemChange(Sender: TField);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure NovoPedido;
  end;

var
  FormIncluirPedido: TFormIncluirPedido;

implementation

{$R *.dfm}

{--------------------------------[ CONSTRUÇÃO ]--------------------------------}
procedure TFormIncluirPedido.FormCreate(Sender: TObject);
begin
  if not Assigned(dmPedidoAPI) then
  begin
    dmPedidoAPI := TdmPedidoAPI.Create(nil);
  end;

  dmPedidoAPI.ListarClientes;
  dmPedidoAPI.ListarProdutos;
  dmPedidoAPI.ListarPedidos;
  dmPedidoAPI.ListarItensDoPedido;
end;

procedure TFormIncluirPedido.FormDestroy(Sender: TObject);
begin
  dmPedidoAPI.Free;
end;

procedure TFormIncluirPedido.mtPedidoCapaNewRecord(DataSet: TDataSet);
begin
  Self.mtPedidoCapadata_emissao_pedido.AsDateTime := Date;
  Self.mtPedidoCapadata_emissao_pedido.AsCurrency := 0.00
end;

procedure TFormIncluirPedido.mtPedidoItensNewRecord(DataSet: TDataSet);
begin
  // Self.mtPedidoItensid_pedido_item.Value
  Self.mtPedidoItensquantidade_pedido_item.Value := 0;
  Self.mtPedidoItensvalor_unitario_pedido_item.Value := 0;
  Self.mtPedidoItensvalor_total_pedido_item.Value := 0;
end;


procedure TFormIncluirPedido.mtPedidoItensquantidade_pedido_itemChange(
  Sender: TField);
var
  Marcador: TBookmark;
  Valor: Currency;
begin

  Valor := 0.00;
  Self.mtPedidoItensvalor_total_pedido_item.Value := Self.mtPedidoItensvalor_unitario_pedido_item.Value * Self.mtPedidoItensquantidade_pedido_item.Value;

  Marcador := Self.mtPedidoItens.Bookmark;

  Self.mtPedidoItens.DisableControls;
  Self.mtPedidoItens.First;
  while not Self.mtPedidoItens.Eof do
  begin
    Valor := Valor + Self.mtPedidoItensvalor_total_pedido_item.AsCurrency;
    Self.mtPedidoItens.Next;
  end;

  Self.mtPedidoItens.GotoBookmark(Marcador);
  Self.mtPedidoItens.Edit;

  Self.mtPedidoCapa.Edit;
  Self.mtPedidoCapavalor_total_pedido.AsCurrency := Valor;

  Self.mtPedidoItens.EnableControls;
end;


{----------------------------------[ PUBICO ]----------------------------------}
procedure TFormIncluirPedido.NovoPedido;
begin
  Self.mtPedidoCapa.Close;
  Self.mtPedidoCapa.CreateDataSet;
  Self.mtPedidoCapa.Append;

  Self.DatePicker1.Date := Date;

  Self.mtPedidoItens.Close;
  Self.mtPedidoItens.CreateDataSet;

end;

end.
