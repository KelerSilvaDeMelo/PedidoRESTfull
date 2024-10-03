object FormIncluirPedido: TFormIncluirPedido
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Incluir Pedido'
  ClientHeight = 441
  ClientWidth = 344
  Color = clBtnFace
  Constraints.MinHeight = 480
  Constraints.MinWidth = 360
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    344
    441)
  TextHeight = 15
  object lbTotal: TLabel
    Left = 184
    Top = 371
    Width = 25
    Height = 15
    Anchors = [akRight, akBottom]
    Caption = 'Total'
    FocusControl = edtTotal
    ExplicitLeft = 144
  end
  object lbCliente: TLabel
    Left = 8
    Top = 20
    Width = 106
    Height = 15
    Hint = 'Preenchimento obrigat'#243'rio para o campo cliente.'
    Caption = 'Informe o cliente (*)'
    FocusControl = lcbCliente
  end
  object lbDataEmissao: TLabel
    Left = 8
    Top = 76
    Width = 93
    Height = 15
    Hint = 'Data retroativa n'#227'o permitida.'
    Caption = 'Informe a data (*)'
    FocusControl = dpData
  end
  object lbProduto: TLabel
    Left = 8
    Top = 140
    Width = 59
    Height = 15
    Hint = 'Produto n'#227'o localizado.'
    Caption = 'Produto (*)'
    FocusControl = edProduto
  end
  object lbQuantidade: TLabel
    Left = 8
    Top = 196
    Width = 78
    Height = 15
    Hint = 'Quantidade deve ser maior que zero'
    Caption = 'Quantidade (*)'
    FocusControl = edtQuantidade
  end
  object lbValor: TLabel
    Left = 109
    Top = 196
    Width = 60
    Height = 15
    Hint = 'Valor deve ser maior que zero'
    Caption = 'Valor Un (*)'
    FocusControl = edtValor
  end
  object lbRegistros: TLabel
    Left = 8
    Top = 371
    Width = 65
    Height = 15
    Caption = '0 Registro(s)'
  end
  object gridItens: TDBGrid
    Left = 8
    Top = 243
    Width = 328
    Height = 122
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = dsPedidoItens
    Enabled = False
    TabOrder = 7
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnCellClick = gridItensCellClick
    OnColExit = gridItensColExit
    OnKeyDown = gridItensKeyDown
    OnKeyUp = gridItensKeyUp
    Columns = <
      item
        Expanded = False
        FieldName = 'sequencia_item'
        ReadOnly = True
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'sequencia_pedido'
        ReadOnly = True
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'codigo_produto'
        ReadOnly = True
        Title.Caption = 'COD'
        Width = 28
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'descricao_produto'
        ReadOnly = True
        Title.Caption = 'PRODUTO'
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'quantidade_produto'
        Title.Caption = 'QNT'
        Width = 28
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'valor_unitario_produto'
        Title.Alignment = taRightJustify
        Title.Caption = 'VL.UN'
        Width = 65
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'valor_total_produto'
        ReadOnly = True
        Title.Alignment = taRightJustify
        Title.Caption = 'VL.TOT'
        Width = 69
        Visible = True
      end>
  end
  object edtTotal: TDBEdit
    Left = 216
    Top = 368
    Width = 121
    Height = 23
    Anchors = [akRight, akBottom]
    DataField = 'valor_total_pedido'
    DataSource = dsPedidoCapa
    ReadOnly = True
    TabOrder = 8
  end
  object Button1: TButton
    Left = 8
    Top = 400
    Width = 328
    Height = 33
    Action = ActionConfirmarPedido
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 9
  end
  object lcbCliente: TDBLookupComboBox
    Left = 8
    Top = 37
    Width = 328
    Height = 23
    Hint = 'Preenchimento obrigat'#243'rio'
    DataField = 'codigo_cliente'
    DataSource = dsPedidoCapa
    KeyField = 'codigo_cliente'
    ListField = 'nome_cliente'
    ListSource = dsClientes
    TabOrder = 0
  end
  object dpData: TDatePicker
    Left = 8
    Top = 93
    Hint = 'Preenchimento obrigat'#243'rio'
    Date = 45566.000000000000000000
    DateFormat = 'dd/mm/yyyy'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    TabOrder = 1
  end
  object edProduto: TDBEdit
    Left = 8
    Top = 157
    Width = 82
    Height = 23
    Hint = 'Preenchimento obrigat'#243'rio'
    DataField = 'codigo_produto'
    DataSource = dsPedidoItem
    TabOrder = 2
    OnExit = edProdutoExit
  end
  object lcbProduto: TDBLookupComboBox
    Left = 109
    Top = 157
    Width = 227
    Height = 23
    DataField = 'codigo_produto'
    DataSource = dsPedidoItem
    KeyField = 'codigo_produto'
    ListField = 'descricao_produto'
    ListSource = dsProdutos
    TabOrder = 3
    TabStop = False
  end
  object edtQuantidade: TDBEdit
    Left = 8
    Top = 213
    Width = 82
    Height = 23
    Hint = 'Preenchimento obrigat'#243'rio'
    DataField = 'quantidade_produto'
    DataSource = dsPedidoItem
    TabOrder = 4
  end
  object edtValor: TDBEdit
    Left = 109
    Top = 213
    Width = 92
    Height = 23
    Hint = 'Preenchimento obrigat'#243'rio'
    DataField = 'valor_unitario_produto'
    DataSource = dsPedidoItem
    TabOrder = 5
  end
  object Button2: TButton
    Left = 246
    Top = 212
    Width = 90
    Height = 25
    Action = ActionIncluirItem
    TabOrder = 6
  end
  object dsClientes: TDataSource
    DataSet = dmPedidoAPI.memClientes
    Left = 280
    Top = 48
  end
  object dsPedidoCapa: TDataSource
    DataSet = dmPedidoClient.memPedidoCapa
    Left = 200
    Top = 48
  end
  object dsPedidoItens: TDataSource
    DataSet = dmPedidoClient.memItensDoPedido
    Left = 200
    Top = 312
  end
  object ActionList1: TActionList
    Left = 280
    Top = 104
    object ActionIncluirItem: TAction
      Caption = 'Incluir Item'
      OnExecute = ActionIncluirItemExecute
    end
    object ActionConfirmarPedido: TAction
      Caption = 'Confirmar Pedido'
      OnExecute = ActionConfirmarPedidoExecute
    end
  end
  object dsProdutos: TDataSource
    DataSet = dmPedidoAPI.memProdutos
    Left = 280
    Top = 312
  end
  object dsPedidoItem: TDataSource
    DataSet = dmPedidoClient.memPedidoItem
    Left = 200
    Top = 104
  end
end
