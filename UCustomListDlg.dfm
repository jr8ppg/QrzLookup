object formCustomListDialog: TformCustomListDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #12459#12473#12479#12512#12522#12473#12488
  ClientHeight = 336
  ClientWidth = 746
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 12
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 746
    Height = 336
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 742
    ExplicitHeight = 335
    DesignSize = (
      746
      336)
    object ListView1: TListView
      Left = 8
      Top = 8
      Width = 602
      Height = 317
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = #12467#12540#12523#12469#12452#12531
          Width = 120
        end
        item
          Caption = 'Country'
          Width = 80
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
        end
        item
          Alignment = taCenter
          Caption = 'State'
          Width = 80
        end
        item
          Caption = #12467#12513#12531#12488
          Width = 200
        end>
      GridLines = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnColumnClick = ListView1ColumnClick
      OnCompare = ListView1Compare
      OnDblClick = ListView1DblClick
      OnSelectItem = ListView1SelectItem
      ExplicitWidth = 598
      ExplicitHeight = 316
    end
    object buttonAdd: TButton
      Left = 618
      Top = 8
      Width = 119
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #36861#21152
      TabOrder = 1
      OnClick = buttonAddClick
      ExplicitLeft = 614
    end
    object buttonEdit: TButton
      Left = 618
      Top = 39
      Width = 119
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #32232#38598
      TabOrder = 2
      OnClick = buttonEditClick
      ExplicitLeft = 614
    end
    object buttonDelete: TButton
      Left = 618
      Top = 168
      Width = 119
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #21066#38500
      TabOrder = 3
      OnClick = buttonDeleteClick
      ExplicitLeft = 614
    end
    object buttonOK: TButton
      Left = 618
      Top = 269
      Width = 119
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      Default = True
      TabOrder = 4
      OnClick = buttonOKClick
      ExplicitLeft = 614
      ExplicitTop = 268
    end
    object buttonCancel: TButton
      Left = 618
      Top = 300
      Width = 119
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = #12461#12515#12531#12475#12523
      ModalResult = 2
      TabOrder = 5
      ExplicitLeft = 614
      ExplicitTop = 299
    end
  end
end
