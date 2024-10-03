program ClientPedido;

uses
  Vcl.Forms,
  UnitFormClientPedidos in 'UnitFormClientPedidos.pas' {FormClientPedidos},
  Vcl.Themes,
  Vcl.Styles,
  ClientConstsPedido in 'ClientConstsPedido.pas',
  UnitDMBaseAPI in 'UnitDMBaseAPI.pas' {dmBaseAPI: TDataModule},
  UnitDMPedidoAPI in 'UnitDMPedidoAPI.pas' {dmPedidoAPI: TDataModule},
  UnitFormIncluirPedido in 'UnitFormIncluirPedido.pas' {FormIncluirPedido},
  UnitFormListarPedidos in 'UnitFormListarPedidos.pas' {FormListarPedidos};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Pedidos Client';
  TStyleManager.TrySetStyle('Windows11 Impressive Light');
  Application.CreateForm(TFormClientPedidos, FormClientPedidos);
  Application.CreateForm(TFormListarPedidos, FormListarPedidos);
  Application.Run;
end.
