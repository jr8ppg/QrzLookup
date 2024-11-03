object formStationDialog: TformStationDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Station'
  ClientHeight = 240
  ClientWidth = 394
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
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 66
    Height = 12
    Caption = #12467#12540#12523#12469#12452#12531
  end
  object Label2: TLabel
    Left = 16
    Top = 42
    Width = 40
    Height = 12
    Caption = 'Country'
  end
  object Label3: TLabel
    Left = 16
    Top = 68
    Width = 49
    Height = 12
    Caption = 'Continent'
  end
  object Label4: TLabel
    Left = 16
    Top = 94
    Width = 45
    Height = 12
    Caption = 'CQ Zone'
  end
  object Label5: TLabel
    Left = 16
    Top = 120
    Width = 47
    Height = 12
    Caption = 'ITU Zone'
  end
  object Label6: TLabel
    Left = 16
    Top = 146
    Width = 27
    Height = 12
    Caption = 'State'
  end
  object Label7: TLabel
    Left = 16
    Top = 172
    Width = 37
    Height = 12
    Caption = #12467#12513#12531#12488
  end
  object Panel1: TPanel
    Left = 0
    Top = 198
    Width = 394
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 7
    ExplicitTop = 197
    ExplicitWidth = 390
    DesignSize = (
      394
      42)
    object buttonOK: TButton
      Left = 232
      Top = 8
      Width = 73
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 228
    end
    object buttonCancel: TButton
      Left = 311
      Top = 8
      Width = 73
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = #12461#12515#12531#12475#12523
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 307
    end
    object buttonDxccSelect: TButton
      Left = 8
      Top = 8
      Width = 121
      Height = 25
      Caption = 'DXCC'#12522#12473#12488#12363#12425#36984#25246
      TabOrder = 2
      OnClick = buttonDxccSelectClick
    end
  end
  object editCallsign: TEdit
    Left = 104
    Top = 13
    Width = 280
    Height = 20
    CharCase = ecUpperCase
    ImeMode = imDisable
    TabOrder = 0
  end
  object editCountry: TEdit
    Left = 104
    Top = 39
    Width = 280
    Height = 20
    CharCase = ecUpperCase
    ImeMode = imDisable
    TabOrder = 1
  end
  object editCQZone: TEdit
    Left = 104
    Top = 91
    Width = 50
    Height = 20
    ImeMode = imDisable
    NumbersOnly = True
    TabOrder = 3
  end
  object editItuZone: TEdit
    Left = 104
    Top = 117
    Width = 50
    Height = 20
    ImeMode = imDisable
    NumbersOnly = True
    TabOrder = 4
  end
  object comboContinent: TComboBox
    Left = 104
    Top = 65
    Width = 50
    Height = 20
    CharCase = ecUpperCase
    ImeMode = imDisable
    TabOrder = 2
    Items.Strings = (
      'NA'
      'SA'
      'OC'
      'AS'
      'EU'
      'AF')
  end
  object comboState: TComboBox
    Left = 104
    Top = 143
    Width = 50
    Height = 20
    CharCase = ecUpperCase
    ImeMode = imDisable
    TabOrder = 5
    Items.Strings = (
      'AL'
      'AZ'
      'AR'
      'CA'
      'CO'
      'CT'
      'DC'
      'DE'
      'FL'
      'GA'
      'ID'
      'IL'
      'IN'
      'IA'
      'KS'
      'KY'
      'LA'
      'ME'
      'MD'
      'MA'
      'MI'
      'MN'
      'MS'
      'MO'
      'MT'
      'NE'
      'NV'
      'NH'
      'NJ'
      'NM'
      'NY'
      'NC'
      'ND'
      'OH'
      'OK'
      'OR'
      'PA'
      'RI'
      'SC'
      'SD'
      'TN'
      'TX'
      'UT'
      'VT'
      'VA'
      'WA'
      'WV'
      'WI'
      'WY'
      'AB'
      'BC'
      'LB'
      'MB'
      'NB'
      'NF'
      'NS'
      'NT'
      'NU'
      'ON'
      'PE'
      'QC'
      'SK'
      'YT')
  end
  object editComment: TEdit
    Left = 104
    Top = 169
    Width = 280
    Height = 20
    TabOrder = 6
  end
end
