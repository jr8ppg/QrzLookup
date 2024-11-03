object formDxccSelectDialog: TformDxccSelectDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'DXCC'#36984#25246
  ClientHeight = 335
  ClientWidth = 496
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 301
    Width = 496
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      496
      34)
    object buttonOK: TButton
      Left = 172
      Top = 4
      Width = 73
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object buttonCancel: TButton
      Left = 251
      Top = 4
      Width = 73
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = #12461#12515#12531#12475#12523
      ModalResult = 2
      TabOrder = 1
    end
  end
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 496
    Height = 301
    Align = alClient
    Columns = <
      item
        Caption = 'DXCC#'
      end
      item
        Caption = 'Country'
        Width = 150
      end
      item
        Alignment = taCenter
        Caption = 'Continent'
        Width = 70
      end
      item
        Alignment = taCenter
        Caption = 'CQ Zone'
        Width = 80
      end
      item
        Alignment = taCenter
        Caption = 'ITU Zone'
        Width = 80
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = ListView1DblClick
    OnSelectItem = ListView1SelectItem
  end
end
