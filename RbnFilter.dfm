object formRbnFilter: TformRbnFilter
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'RbnFilter'
  ClientHeight = 386
  ClientWidth = 680
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    680
    386)
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
    Width = 241
    Height = 13
    Caption = #20837#21147#12501#12449#12452#12523#21517#65288#12459#12531#12510#21306#20999#12426#12391#35079#25968#36984#25246#21487#65289
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
    Left = 559
    Top = 163
    Width = 113
    Height = 54
    Anchors = [akTop, akRight]
    Caption = #38283#22987
    TabOrder = 8
    OnClick = buttonStartClick
  end
  object editInputFileName: TEdit
    Left = 8
    Top = 66
    Width = 664
    Height = 20
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object buttonFileRef: TButton
    Left = 591
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
    Height = 187
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
      OnClick = radioDxDeClick
    end
    object radioDxCont: TRadioButton
      Left = 16
      Top = 47
      Width = 113
      Height = 17
      Caption = #22823#38520'(dx_cont)'
      TabOrder = 1
      OnClick = radioDxDeClick
    end
    object radioDeCont: TRadioButton
      Left = 16
      Top = 117
      Width = 113
      Height = 17
      Caption = #22823#38520'(de_cont)'
      TabOrder = 4
      OnClick = radioDxDeClick
    end
    object radioDePfx: TRadioButton
      Left = 16
      Top = 94
      Width = 113
      Height = 17
      Caption = #12459#12531#12488#12522#12540'(de_pfx)'
      TabOrder = 3
      OnClick = radioDxDeClick
    end
    object radioDeZone: TRadioButton
      Left = 16
      Top = 140
      Width = 113
      Height = 17
      Caption = 'Zone(de_zone)'
      TabOrder = 5
      OnClick = radioDxDeClick
    end
    object radioDxZone: TRadioButton
      Left = 16
      Top = 71
      Width = 113
      Height = 17
      Caption = 'Zone(dx_zone)'
      TabOrder = 2
      OnClick = radioDxDeClick
    end
  end
  object editOutputFileName: TEdit
    Left = 8
    Top = 122
    Width = 664
    Height = 20
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object buttonClose: TButton
    Left = 559
    Top = 342
    Width = 113
    Height = 33
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = #38281#12376#12427
    ModalResult = 2
    TabOrder = 9
    OnClick = buttonCloseClick
  end
  object GroupBox3: TGroupBox
    Left = 312
    Top = 158
    Width = 105
    Height = 81
    Caption = 'de_zone'
    TabOrder = 6
    object radioDeQrzCom: TRadioButton
      Left = 16
      Top = 24
      Width = 65
      Height = 17
      Caption = 'QRZ.COM'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object radioDeCtyDat: TRadioButton
      Left = 16
      Top = 47
      Width = 65
      Height = 17
      Caption = 'CTY.DAT'
      TabOrder = 1
    end
  end
  object GroupBox4: TGroupBox
    Left = 423
    Top = 158
    Width = 105
    Height = 81
    Caption = 'dx_zone'
    TabOrder = 7
    object radioDxQrzCom: TRadioButton
      Left = 16
      Top = 24
      Width = 65
      Height = 17
      Caption = 'QRZ.COM'
      TabOrder = 0
    end
    object radioDxCtyDat: TRadioButton
      Left = 16
      Top = 47
      Width = 65
      Height = 17
      Caption = 'CTY.DAT'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
  end
  object GroupBox5: TGroupBox
    Left = 160
    Top = 245
    Width = 368
    Height = 133
    Caption = #12381#12398#20182
    TabOrder = 5
    object checkDePfxFilter: TCheckBox
      Left = 16
      Top = 24
      Width = 98
      Height = 17
      Caption = 'de_pfx'#25351#23450
      TabOrder = 0
      OnClick = checkDePfxFilterClick
    end
    object editDePfxFilter: TEdit
      Left = 120
      Top = 22
      Width = 121
      Height = 20
      CharCase = ecUpperCase
      Enabled = False
      TabOrder = 1
      Text = 'K,VE'
    end
    object checkDxPfxFilter: TCheckBox
      Left = 16
      Top = 70
      Width = 98
      Height = 17
      Caption = 'dx_pfx'#25351#23450
      TabOrder = 4
      OnClick = checkDxPfxFilterClick
    end
    object editDxPfxFilter: TEdit
      Left = 120
      Top = 68
      Width = 121
      Height = 20
      CharCase = ecUpperCase
      Enabled = False
      TabOrder = 5
      Text = 'JA'
    end
    object checkDxContFilter: TCheckBox
      Left = 16
      Top = 93
      Width = 98
      Height = 17
      Caption = 'dx_cont'#25351#23450
      TabOrder = 6
      OnClick = checkDxContFilterClick
    end
    object editDxContFilter: TEdit
      Left = 120
      Top = 91
      Width = 121
      Height = 20
      CharCase = ecUpperCase
      Enabled = False
      TabOrder = 7
      Text = 'AS,OC'
    end
    object checkDeContFilter: TCheckBox
      Left = 16
      Top = 47
      Width = 98
      Height = 17
      Caption = 'de_cont'#25351#23450
      TabOrder = 2
      OnClick = checkDeContFilterClick
    end
    object editDeContFilter: TEdit
      Left = 120
      Top = 45
      Width = 121
      Height = 20
      CharCase = ecUpperCase
      Enabled = False
      TabOrder = 3
      Text = 'NA'
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'CSV'#12501#12449#12452#12523'|*.csv|'#20840#12390#12398#12501#12449#12452#12523'|*.*'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 360
    Top = 16
  end
end
