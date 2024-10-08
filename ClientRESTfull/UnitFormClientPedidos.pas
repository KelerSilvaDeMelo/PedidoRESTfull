unit UnitFormClientPedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.WinXCtrls, System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList;

type
  TFormClientPedidos = class(TForm)
    Button1: TButton;
    ActionList1: TActionList;
    ActionListarPedidos: TAction;
    ActionIncluirPedido: TAction;
    Button2: TButton;
    ImageList1: TImageList;
    ActivityIndicator1: TActivityIndicator;
    TimerActivity: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure ActionIncluirPedidoExecute(Sender: TObject);
    procedure ActionListarPedidosExecute(Sender: TObject);
    procedure TimerActivityTimer(Sender: TObject);

  private
    { Private declarations }

  public
    { Public declarations }

  end;

var
  FormClientPedidos: TFormClientPedidos;

implementation

{$R *.dfm}

uses UnitDMBaseAPI, UnitFormIncluirPedido, UnitFormListarPedidos,
  ClientConstsPedido, System.UITypes;

{--------------------------------[ CONSTRU��O ]--------------------------------}
procedure TFormClientPedidos.FormCreate(Sender: TObject);
begin
  if not Assigned(dmGlobalAPI) then
  begin
    dmGlobalAPI := TdmBaseAPI.Create(nil);
  end;
end;

procedure TFormClientPedidos.FormDestroy(Sender: TObject);
begin
  dmGlobalAPI.Free;
end;

{---------------------------------[ INTERNO ]----------------------------------}
procedure TFormClientPedidos.TimerActivityTimer(Sender: TObject);
var
  MensagemErro: String;
begin
  Self.TimerActivity.Enabled := False;
  MensagemErro := MSG_ERRO_SERVIDOR_INDISPONIVEL;
  if dmGlobalAPI.TestarConexao(MensagemErro) then
  begin
    Self.Button1.Visible := True;
    Self.Button2.Visible := True;
  end
  else
  begin
    ShowMessage(MensagemErro);
    Self.Close;
  end;
  Self.ActivityIndicator1.Animate := False;
  Self.ActivityIndicator1.Visible := False;
end;

{----------------------------------[ A��O ]------------------------------------}
procedure TFormClientPedidos.ActionIncluirPedidoExecute(Sender: TObject);
var
  CriaPedido: TFormIncluirPedido;
  MensagemDeErro: String;
begin
  CriaPedido := TFormIncluirPedido.Create(nil);
  try
    MensagemDeErro := MSG_ERRO_SERVIDOR_INDISPONIVEL;
    if CriaPedido.Preparado(MensagemDeErro) then
    begin
      CriaPedido.ShowModal;
    end
    else
    begin
      MessageDlg(MensagemDeErro, TMsgDlgType.mtError, [mbOK], 0)
    end;
  finally
    CriaPedido.Free;
  end;
end;

procedure TFormClientPedidos.ActionListarPedidosExecute(Sender: TObject);
var
  ListarPedido: TFormListarPedidos;
  MensagemDeErro: String;
begin
  ListarPedido := TFormListarPedidos.Create(nil);
  try
    MensagemDeErro := MSG_ERRO_SERVIDOR_INDISPONIVEL;
    if ListarPedido.Preparado(MensagemDeErro) then
    begin
      ListarPedido.ShowModal;
    end
    else
    begin
      MessageDlg(MensagemDeErro, TMsgDlgType.mtError, [mbOK], 0)
    end;
  finally
    ListarPedido.Free;
  end;
end;


end.
