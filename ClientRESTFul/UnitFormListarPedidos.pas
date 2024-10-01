unit UnitFormListarPedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, UnitDMPedidoAPI, Data.DB,
  Vcl.Grids, Vcl.DBGrids;

type
  TFormListarPedidos = class(TForm)
    Label1: TLabel;
    DataSourcePedidos: TDataSource;
    DBGrid1: TDBGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormListarPedidos: TFormListarPedidos;

implementation

{$R *.dfm}

procedure TFormListarPedidos.FormCreate(Sender: TObject);
begin
begin
  if not Assigned(dmPedidoAPI) then
  begin
    dmPedidoAPI := TdmPedidoAPI.Create(nil);
  end;

  dmPedidoAPI.ListarPedidos;
end;

end;

end.
