object formRbnFilter: TformRbnFilter
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'RbnFilter'
  ClientHeight = 309
  ClientWidth = 577
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    577
    309)
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 279
    Height = 19
    Caption = 'RBN RAW'#12487#12540#12479#12398#37325#35079#21066#38500#12484#12540#12523
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 47
    Width = 81
    Height = 13
    Caption = #20837#21147#12501#12449#12452#12523#21517
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 8
    Top = 103
    Width = 81
    Height = 13
    Caption = #20986#21147#12501#12449#12452#12523#21517
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    ParentFont = False
  end
  object buttonStart: TButton
    Left = 456
    Top = 176
    Width = 113
    Height = 54
    Anchors = [akTop, akRight]
    Caption = #38283#22987
    TabOrder = 5
    OnClick = buttonStartClick
  end
  object editInputFileName: TEdit
    Left = 8
    Top = 66
    Width = 561
    Height = 20
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = editInputFileNameChange
  end
  object buttonFileRef: TButton
    Left = 488
    Top = 38
    Width = 81
    Height = 26
    Anchors = [akTop, akRight]
    Caption = #21442#29031
    TabOrder = 1
    OnClick = buttonFileRefClick
  end
  object GroupBox1: TGroupBox
    Left = 160
    Top = 158
    Width = 146
    Height = 81
    Caption = 'date'#12398#27604#36611#25991#23383#25968
    TabOrder = 4
    object checkDateCompare13: TRadioButton
      Left = 16
      Top = 24
      Width = 113
      Height = 17
      Caption = '13'#25991#23383'('#26178#12414#12391')'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object checkDateCompare16: TRadioButton
      Left = 16
      Top = 47
      Width = 113
      Height = 17
      Caption = '16'#25991#23383'('#20998#12414#12391')'
      TabOrder = 1
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 158
    Width = 146
    Height = 127
    Caption = 'dx'#12398#27604#36611#26041#27861
    TabOrder = 3
    object radioDxPfx: TRadioButton
      Left = 16
      Top = 24
      Width = 113
      Height = 17
      Caption = #12459#12531#12488#12522#12540'(dx_pfx)'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object radioDxCont: TRadioButton
      Left = 16
      Top = 47
      Width = 113
      Height = 17
      Caption = #22823#38520'(dx_cont)'
      TabOrder = 1
    end
    object radioDeCont: TRadioButton
      Left = 16
      Top = 93
      Width = 113
      Height = 17
      Caption = #22823#38520'(de_cont)'
      TabOrder = 2
    end
    object radioDePfx: TRadioButton
      Left = 16
      Top = 70
      Width = 113
      Height = 17
      Caption = #12459#12531#12488#12522#12540'(de_pfx)'
      TabOrder = 3
    end
  end
  object editOutputFileName: TEdit
    Left = 8
    Top = 122
    Width = 561
    Height = 20
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object buttonClose: TButton
    Left = 456
    Top = 267
    Width = 113
    Height = 33
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = #38281#12376#12427
    ModalResult = 2
    TabOrder = 6
    OnClick = buttonStartClick
  end
  object OpenDialog1: TOpenDialog
    Filter = 'CSV'#12501#12449#12452#12523'|*.csv|'#20840#12390#12398#12501#12449#12452#12523'|*.*'
    Left = 360
    Top = 16
  end
end
