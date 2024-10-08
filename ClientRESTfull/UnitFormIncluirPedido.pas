unit UnitFormIncluirPedido;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  UnitDMPedidoClient, Data.DB, Vcl.DBCtrls, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.StorageBin,
  Vcl.WinXPickers, Vcl.Mask, Vcl.ExtCtrls, System.Actions, Vcl.ActnList,
  Vcl.Buttons;

type
  TFormIncluirPedido = class(TForm)
    dsClientes: TDataSource;
    dsPedidoCapa: TDataSource;
    dsPedidoItens: TDataSource;
    gridItens: TDBGrid;
    lbTotal: TLabel;
    edtTotal: TDBEdit;
    ButtonConfirma: TButton;
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
    alPedido: TActionList;
    dsProdutos: TDataSource;
    dsPedidoItem: TDataSource;
    ActionIncluirItem: TAction;
    ActionGravaPedido: TAction;
    lbRegistros: TLabel;
    ButtonCancela: TButton;
    ActionExcluiPedido: TAction;
    ActionBuscarPedido: TAction;
    Button1: TButton;
    Shape1: TShape;
    memEstadoUI: TFDMemTable;
    DBText1: TDBText;
    dsEstadoUI: TDataSource;
    memEstadoUIMomento: TStringField;
    Button3: TButton;
    ActionNovoPedido: TAction;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure ClienteOnChange(Sender: TField);
    procedure gridItensColExit(Sender: TObject);
    procedure gridItensKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure gridItensCellClick(Column: TColumn);
    procedure gridItensKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

    procedure ActionNovoPedidoExecute(Sender: TObject);
    procedure ActionIncluirItemExecute(Sender: TObject);
    procedure ActionGravaPedidoExecute(Sender: TObject);
    procedure ActionExcluiPedidoExecute(Sender: TObject);
    procedure ActionBuscarPedidoExecute(Sender: TObject);

  private
    { Private symbols }
    FPedidoClient: TdmPedidoClient;
    FPedidoID: Integer;
    FPreparado: Boolean;
    FContagemDeRegistros: Integer;


  private
    { Private declarations }
    function MaquinaDeEstado(Operacao: String; var MensagemDeErro: String): Boolean; // State machine client ui

    procedure ContaRegistros;
    procedure ApagaItemPosicionado;
    function ValidaIncluirItem: Boolean;
    function IncluiItem: Boolean;
    function ValidaGravarPedido: Boolean;

  public
    { Public declarations }
    function Preparado(var MensagemDeErro: String): Boolean;

  end;

implementation

{$R *.dfm}

uses ClientConstsPedido, System.UITypes;

{ -------------------------------[ CONSTRU��O ]------------------------------- }
procedure TFormIncluirPedido.FormCreate(Sender: TObject);
begin
  Self.FPreparado := False;
  Self.FPedidoClient := TdmPedidoClient.Create(nil);
  Self.memEstadoUI.Append;
  Self.FPedidoClient.CapaPedidoCliente.OnChange := Self.ClienteOnChange;
end;

procedure TFormIncluirPedido.FormDestroy(Sender: TObject);
begin
  Self.FPedidoClient.CapaPedidoCliente.OnChange := nil;
  Self.FPedidoClient.Free;
end;


{ --------------------------------[ INTERNO ]--------------------------------- }
procedure TFormIncluirPedido.ClienteOnChange(Sender: TField);
begin
  Self.ActionBuscarPedido.Visible := (Sender.Value <= 0);
end;

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


{ ----------------------------------[ A��O ]---------------------------------- }
procedure TFormIncluirPedido.ActionNovoPedidoExecute(Sender: TObject);
var
  MensagemDeErro: String;
begin
  MensagemDeErro := MSG_ERRO_INCLUIR_PEDIDO;
  Self.MaquinaDeEstado('Novo Pedido', MensagemDeErro);
end;

procedure TFormIncluirPedido.ActionIncluirItemExecute(Sender: TObject);
begin
  if Self.ValidaIncluirItem then
    Self.IncluiItem;
end;

procedure TFormIncluirPedido.ActionGravaPedidoExecute(Sender: TObject);
var
  DataDaEmissao: TDate;
  Mensagem, MensagemDeErro, SequenciaDoPedido: String;
begin
  if Self.ValidaGravarPedido then
  begin
    DataDaEmissao := Self.dpData.Date;
    Mensagem := 'Comando: ' + FN_PEDIDO_GRAVADO;
    MensagemDeErro := MSG_ERRO_GRAVAR_PEDIDO;
    if not Self.FPedidoClient.EnviaNovoPedido(DataDaEmissao, MensagemDeErro) then
    begin
      MessageDlg(MensagemDeErro, TMsgDlgType.mtInformation, [mbOK], 0);
      Exit;
    end;

    SequenciaDoPedido := Self.FPedidoClient.pcSequencia.AsString;
    Self.FPedidoID := SequenciaDoPedido.ToInteger;
    Mensagem := Mensagem + #13#10
              + FN_PEDIDO_GRAVADO + #1310
              + 'Sequ�ncia do pedido: ' + SequenciaDoPedido + #13#10
              + #13#10
              + 'Comando: ' + FN_BUSCA_PEDIDO;
    MensagemDeErro := MSG_ERRO_BUSCAR_PEDIDO;
    if Self.MaquinaDeEstado('Consulta Pedido: ' + SequenciaDoPedido, MensagemDeErro) then
    begin
      Mensagem := FN_PEDIDO_GRAVADO + #13#10
              + 'Sequ�ncia do pedido: ' + SequenciaDoPedido;
      MessageDlg(Mensagem, TMsgDlgType.mtInformation, [mbOK], 0);
    end
    else
    begin
      MessageDlg(MensagemDeErro, TMsgDlgType.mtError, [mbOK], 0);
    end;
  end;
end;

procedure TFormIncluirPedido.ActionBuscarPedidoExecute(Sender: TObject);
var
  Titulo, Mensagem, MensagemDeErro, Resposta: String;
  CodigoDoPedido: Integer;
begin
  Titulo := FN_BUSCA_PEDIDO;
  MensagemDeErro := FN_PROCESSO_CANCELADO;
  CodigoDoPedido := 0;

  Resposta := InputBox(Titulo, Mensagem, '0');
  if not TryStrToInt(Resposta, CodigoDoPedido) then
  begin
    MessageDlg(MensagemDeErro, TMsgDlgType.mtInformation, [mbOK], 0);
    Exit;
  end;

  if CodigoDoPedido = 0 then
  begin
    MessageDlg(MensagemDeErro, TMsgDlgType.mtInformation, [mbOK], 0);
    Exit;
  end;

  Self.FPedidoID := CodigoDoPedido;
  MensagemDeErro := FN_PEDIDO_NAO_LOCALIZADO;
  if not Self.MaquinaDeEstado('Consulta Pedido', MensagemDeErro) then
  begin
    MessageDlg(MensagemDeErro, TMsgDlgType.mtInformation, [mbOK], 0);
    Exit;
  end;
end;

procedure TFormIncluirPedido.ActionExcluiPedidoExecute(Sender: TObject);
var
  DadosPedido, Mensagem, MensagemDeErro: String;
begin
  DadosPedido := #13#10 + #13#10
               + 'Sequ�ncia: ' + Self.FPedidoID.ToString + #13#10
               + 'Cliente: ' + lcbCliente.Text + #13#10
               + 'Valor: ' + edtTotal.Text;
  Mensagem := FN_EXCLUIR_PEDIDO + DadosPedido;
  MensagemDeErro := MSG_ERRO_EXCLUI_PEDIDO;

  if MessageDlg(Mensagem, TMsgDlgType.mtConfirmation, mbYesNo, 0) = mrNo then
    Exit;

  if Self.FPedidoClient.ExcluiPedido(Self.FPedidoID, MensagemDeErro) then
  begin
    MessageDlg(FN_PEDIDO_EXCLUIDO, TMsgDlgType.mtInformation, [mbOK], 0);
    Self.ActionNovoPedido.Execute;
  end
  else
  begin
    MessageDlg(MensagemDeErro, TMsgDlgType.mtWarning, [mbOK], 0);
  end;
end;



{ ---------------------------------[ PRIVATE ]-------------------------------- }
procedure TFormIncluirPedido.ContaRegistros;
var
  Registros: String;
begin
  Self.FContagemDeRegistros := Self.gridItens.DataSource.DataSet.RecordCount;
  Registros := Self.FContagemDeRegistros.ToString;
  Self.lbRegistros.Caption := Registros + ' Registro(s)';

  Self.gridItens.Enabled := ((Self.FContagemDeRegistros > 0) and (Pos('Novo', Self.memEstadoUIMomento.AsString)>0));
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
    Mensagem := FN_EXCLUIR_REGISTRO;
    if MessageDlg(Mensagem, TMsgDlgType.mtConfirmation, mbOKCancel, 0) = mrOk then
    begin
      Self.FPedidoClient.ExcluiItemPosicionado;
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
  Descricao, MensagemDeErro: String;
begin
  Descricao := Self.lcbProduto.Text;
  MensagemDeErro := MSG_ERRO_INCLUIR_ITEM_PEDIDO;
  Result := Self.FPedidoClient.IncluirItem(Descricao, MensagemDeErro);
  if Result then
  begin
    Self.ContaRegistros;
    Self.ActionBuscarPedido.Visible := (Self.FContagemDeRegistros = 0);
    Self.edProduto.SetFocus;
  end
  else
  begin
    MessageDlg(MensagemDeErro, TMsgDlgType.mtError, [mbOK], 0);
  end;
end;

function TFormIncluirPedido.ValidaGravarPedido: Boolean;
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
  // Presen�a de itens no pedido
  if Self.gridItens.DataSource.DataSet.RecordCount < 1 then
    Controle := Self.lbRegistros
  else
  // Valor positivo
  if Self.edtTotal.Field.AsCurrency <= 0.00 then
    Controle := Self.lbRegistros;

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

function TFormIncluirPedido.MaquinaDeEstado(Operacao: String; var MensagemDeErro: String): Boolean;
var
  Definido: String;
begin
  Result := False;
  Self.FPreparado := False;

  Definido := 'Novo Pedido';
  if Pos(Definido, Operacao) > 0 then
  begin
    Self.FPreparado := Self.FPedidoClient.NovoPedido(MensagemDeErro);
    if Self.FPreparado then
    begin
      Result := True;
      Self.memEstadoUIMomento.AsString := Definido;
      Self.dpData.Date := Date;
      Self.dpData.Enabled := True;
      Self.gridItens.ReadOnly := False;
      Self.ActionNovoPedido.Visible := False;
      Self.ActionIncluirItem.Visible := True;
      Self.ActionGravaPedido.Visible := True;
      Self.ActionBuscarPedido.Visible := True;
      Self.ActionExcluiPedido.Visible := False;
      Self.dsPedidoCapa.AutoEdit := True;
      Self.dsPedidoItem.AutoEdit := True;
      Self.dsPedidoItens.AutoEdit := True;
    end;
    Exit;
  end;

  Definido := 'Consulta Pedido';
  if Pos(Definido, Operacao) > 0 then
  begin
    Self.FPreparado := Self.FPedidoClient.BuscaPedido(Self.FPedidoID, MensagemDeErro);
    if Self.FPreparado then
    begin
      Result := True;
      Self.memEstadoUIMomento.AsString := Definido + ': ' + Self.FPedidoID.ToString;
      Self.ContaRegistros;
      Self.dpData.Date := dsPedidoCapa.DataSet.FieldByName('data_emissao_pedido').AsDateTime;
      Self.dpData.Enabled := False;
      Self.ActionNovoPedido.Visible := True;
      Self.ActionIncluirItem.Visible := False;
      Self.ActionGravaPedido.Visible := False;
      Self.ActionBuscarPedido.Visible := True;
      Self.ActionExcluiPedido.Visible := True;
      Self.dsPedidoCapa.AutoEdit := False;
      Self.dsPedidoItem.AutoEdit := False;
      if Self.dsPedidoItem.DataSet.State in [dsInsert, dsEdit] then
        Self.dsPedidoItem.DataSet.Post;
      Self.dsPedidoItens.AutoEdit := False;
    end;
    Exit;
  end;
end;


{ ---------------------------------[ PUBICO ]--------------------------------- }
function TFormIncluirPedido.Preparado(var MensagemDeErro: String): Boolean;
begin
  Self.MaquinaDeEstado('Novo Pedido', MensagemDeErro);
  Result := Self.FPreparado;
end;


end.
