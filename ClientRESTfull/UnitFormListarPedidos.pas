unit UnitFormListarPedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, UnitDMPedidoAPI, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.Mask,
  Vcl.ExtCtrls, Vcl.DBCtrls;

type
  TFormListarPedidos = class(TForm)
    Label1: TLabel;
    DataSourcePedidos: TDataSource;
    gridListaPedidos: TDBGrid;
    lbRegistros: TLabel;
    lbTotal: TLabel;
    edtTotal: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private symbols }
    FPedidoAPI: TdmPedidoAPI;
  private
    { Private declarations }
    procedure ContaRegistros;
    procedure SomaTotalDosPedidos;
  public
    { Public declarations }
    function Preparado(var MensagemDeErro: String): Boolean;
  end;

var
  FormListarPedidos: TFormListarPedidos;

implementation

{$R *.dfm}

{--------------------------------[ CONSTRUÇÃO ]--------------------------------}
procedure TFormListarPedidos.FormCreate(Sender: TObject);
begin
  Self.FPedidoAPI := TdmPedidoAPI.Create(nil);
end;

procedure TFormListarPedidos.FormDestroy(Sender: TObject);
begin
  Self.FPedidoAPI.Free;
end;


{---------------------------------[ PUBLICO ]----------------------------------}
procedure TFormListarPedidos.ContaRegistros;
var
  Contagem: Integer;
  Registros: String;
begin
  Contagem := Self.gridListaPedidos.DataSource.DataSet.RecordCount;
  Registros := Contagem.ToString;
  Self.lbRegistros.Caption := Registros + ' Registro(s)';

  Self.gridListaPedidos.Enabled := (Contagem > 0);
end;


{---------------------------------[ PUBLICO ]----------------------------------}
function TFormListarPedidos.Preparado(var MensagemDeErro: String): Boolean;
begin
  Result := Self.FPedidoAPI.ListarPedidos(MensagemDeErro);
  if Result then
  begin
    Self.ContaRegistros;
    Self.SomaTotalDosPedidos;
    Self.gridListaPedidos.DataSource.DataSet.First;
  end;
end;

procedure TFormListarPedidos.SomaTotalDosPedidos;
var
  Marcador: TBookmark;
  Somatorio, vlPedido: Currency;
begin
  Marcador := Self.FPedidoAPI.memPedidos.Bookmark;
  Somatorio := 0.00;

  Self.FPedidoAPI.memPedidos.DisableControls;
  Self.FPedidoAPI.memPedidos.First;

  while not Self.FPedidoAPI.memPedidos.Eof do
  begin
    vlPedido := Self.FPedidoAPI.memPedidosvalor_total_pedido.AsCurrency;
    Somatorio := Somatorio + vlPedido;
    Self.FPedidoAPI.memPedidos.Next;
  end;

  Self.FPedidoAPI.memPedidos.Bookmark;
  Self.FPedidoAPI.memPedidos.EnableControls;

  Self.edtTotal.Text := FormatCurr('R$ #,##0.00', Somatorio);
end;


end.
