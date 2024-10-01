object FormListarPedidos: TFormListarPedidos
  Left = 0
  Top = 0
  Caption = 'Listar Pedidos'
  ClientHeight = 441
  ClientWidth = 304
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 20
    Width = 91
    Height = 15
    Hint = 'Preenchimento obrigat'#243'rio'
    Caption = 'Lista dos pedidos'
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 41
    Width = 288
    Height = 392
    DataSource = DataSourcePedidos
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'numero_pedido'
        Title.Caption = 'N'#250'mero'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'codigo_cliente'
        Title.Caption = 'Cliente'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'data_emissao_pedido'
        Title.Caption = 'Data'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'valor_total_pedido'
        Title.Caption = 'Valor'
        Visible = True
      end>
  end
  object DataSourcePedidos: TDataSource
    AutoEdit = False
    DataSet = dmPedidoAPI.FDMemTablePedidos
    Left = 216
    Top = 360
  end
end
