unit UnitFormIncluirPedido;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  UnitDMPedidoClient, Data.DB, Vcl.DBCtrls, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.StorageBin,
  Vcl.WinXPickers, Vcl.Mask, Vcl.ExtCtrls, System.Actions, Vcl.ActnList;

type
  TFormIncluirPedido = class(TForm)
    dsClientes: TDataSource;
    dsPedidoCapa: TDataSource;
    dsPedidoItens: TDataSource;
    gridItens: TDBGrid;
    lbTotal: TLabel;
    edtTotal: TDBEdit;
    Button1: TButton;
    lbCliente: TLabel;
    lcbCliente: TDBLookupComboBox;
    lbDataEmissao: TLabel;
    dpData: TDatePicker;
    lbProduto: TLabel;
    edProduto: TDBEdit;
    lcbProduto: TDBLookupComboBox;
    lbQuantidade: TLabel;
    edtQuantidade: TDBEdit;
    lbValor: TLabel;
    edtValor: TDBEdit;
    Button2: TButton;
    ActionList1: TActionList;
    dsProdutos: TDataSource;
    dsPedidoItem: TDataSource;
    ActionIncluirItem: TAction;
    ActionConfirmarPedido: TAction;
    lbRegistros: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure ActionIncluirItemExecute(Sender: TObject);
    procedure gridItensColExit(Sender: TObject);
    procedure gridItensKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure gridItensCellClick(Column: TColumn);
    procedure gridItensKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ActionConfirmarPedidoExecute(Sender: TObject);
    procedure edProdutoExit(Sender: TObject);

  private
    { Private symbols }
    FPedidoClient: TdmPedidoClient;
    FPreparado: Boolean;

  private
    { Private declarations }
    procedure ContaRegistros;
    procedure ApagaItemPosicionado;
    function ValidaIncluirItem: Boolean;
    function IncluiItem: Boolean;

  public
    { Public declarations }
    function Preparado(var MensagemDeErro: String): Boolean;

  end;

implementation

{$R *.dfm}

uses ClientConstsPedido;

{ --------------------------------[ CONSTRU��O ]-------------------------------- }
procedure TFormIncluirPedido.FormCreate(Sender: TObject);
begin
  Self.FPreparado := False;
  Self.FPedidoClient := TdmPedidoClient.Create(nil);
end;

procedure TFormIncluirPedido.FormDestroy(Sender: TObject);
begin
  Self.FPedidoClient.Free;
end;

{ ---------------------------------[ INTERNO ]---------------------------------- }
procedure TFormIncluirPedido.gridItensCellClick(Column: TColumn);
begin
  Self.ContaRegistros;
  Self.FPedidoClient.RecalculaTotais;
end;

procedure TFormIncluirPedido.gridItensColExit(Sender: TObject);
begin
  Self.ContaRegistros;
  Self.FPedidoClient.RecalculaTotais;
end;

procedure TFormIncluirPedido.gridItensKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (ssCtrl in Shift) then
  begin
    // Anula a combina��o CTRL+DELETE
    Key := 0;
    Exit;
  end;
end;

procedure TFormIncluirPedido.gridItensKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_DELETE:
      Self.ApagaItemPosicionado;
    VK_DOWN, VK_UP:
      begin
        Self.ContaRegistros;
        Self.FPedidoClient.RecalculaTotais;
      end
  end;
end;

procedure TFormIncluirPedido.edProdutoExit(Sender: TObject);
begin
end;


{ ----------------------------------[ A��O ]---------------------------------- }
procedure TFormIncluirPedido.ActionConfirmarPedidoExecute(Sender: TObject);
var
  DataDaEmissao: TDate;
  Mensagem, MensagemDeErro, SequenciaDoPedido: String;
begin
  DataDaEmissao := Self.dpData.Date;
  Mensagem := FN_GRAVA_PEDIDO;
  MensagemDeErro := MSG_ERRO_GRAVAR_PEDIDO;
  if Self.FPedidoClient.EnviaNovoPedido(DataDaEmissao, MensagemDeErro) then
  begin
    SequenciaDoPedido := Self.FPedidoClient.pcSequencia.AsString;
    Mensagem := Mensagem + #13#10 + 'Sequ�ncia do pedido: ' + SequenciaDoPedido;
    MessageDlg(Mensagem, TMsgDlgType.mtInformation, [mbOK], 0);
    Self.Close;
  end
  else
  begin
    MessageDlg(MensagemDeErro, TMsgDlgType.mtInformation, [mbOK], 0);
  end;
end;

procedure TFormIncluirPedido.ActionIncluirItemExecute(Sender: TObject);
begin
  if Self.ValidaIncluirItem then
    Self.IncluiItem;
end;

{ ---------------------------------[ PRIVATE ]-------------------------------- }
procedure TFormIncluirPedido.ContaRegistros;
var
  Contagem: Integer;
  Registros: String;
begin
  Contagem := Self.gridItens.DataSource.DataSet.RecordCount;
  Registros := Contagem.ToString;
  Self.lbRegistros.Caption := Registros + ' Registro(s)';

  Self.gridItens.Enabled := (Contagem > 0);
end;

procedure TFormIncluirPedido.ApagaItemPosicionado;
var
  Mensagem: String;
begin
  if gridItens.DataSource.DataSet.IsEmpty then
  begin
    Mensagem := FN_LISTA_VAZIA;
    MessageDlg(Mensagem, TMsgDlgType.mtInformation, [mbOK], 0)
  end
  else
  begin
    Mensagem := FN_APAGAR_REGISTRO;
    if MessageDlg(Mensagem, TMsgDlgType.mtConfirmation, mbOKCancel, 0) = mrOk then
    begin
      Self.FPedidoClient.ApagaItemPosicionado;
      Self.ContaRegistros;
    end;
  end;
end;

function TFormIncluirPedido.ValidaIncluirItem: Boolean;
var
  Controle: TLabel;
begin
  Controle := nil;
  Result := True;

  // Cliente
  if Self.lcbCliente.Field.IsNull then
    Controle := Self.lbCliente
  else
  // Regra Data de Emiss�o
  if Self.dpData.Date < Date then
    Controle := Self.lbDataEmissao
  else
  // Preenchimento do campo C�digo do Produto
  if Self.edProduto.Field.IsNull then
    Controle := Self.lbProduto
  else
  // Produto n�o existe
  if not Self.FPedidoClient.ProdutoExiste then
    Controle := Self.lbProduto
  else
  // Preenchimento do campo Quantidade
  if Self.edtQuantidade.Field.IsNull then
    Controle := Self.lbQuantidade
  else
  // Quantidade positiva
  if Self.edtQuantidade.Field.AsInteger <= 0 then
    Controle := Self.lbQuantidade
  else
  // Preenchimento do campo Valor
  if Self.edtValor.Field.IsNull then
    Controle := Self.lbValor
  else
  // Valor positivo
  if Self.edtValor.Field.AsCurrency <= 0 then
    Controle := Self.lbValor;

  // Informe
  if Assigned(Controle) then
  begin
    Result := False;
    if Assigned(Controle.FocusControl) then
      if Controle.FocusControl.CanFocus then
        Controle.FocusControl.SetFocus;
    MessageDlg(Controle.Hint, TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
  end;
end;

function TFormIncluirPedido.IncluiItem: Boolean;
var
  Descricao: String;
begin
  Descricao := Self.lcbProduto.Text;
  Result := Self.FPedidoClient.IncluirItem(Descricao);
  Self.ContaRegistros;
  Self.edProduto.SetFocus;
end;

{ ---------------------------------[ PUBICO ]--------------------------------- }
function TFormIncluirPedido.Preparado(var MensagemDeErro: String): Boolean;
begin
  Self.dpData.Date := Date;
  Self.FPreparado := Self.FPedidoClient.NovoPedido(MensagemDeErro);
  Result := Self.FPreparado;
end;


end.
