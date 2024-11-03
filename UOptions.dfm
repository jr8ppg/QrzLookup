object formOptions: TformOptions
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #12458#12503#12471#12519#12531
  ClientHeight = 315
  ClientWidth = 577
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
  object Panel1: TPanel
    Left = 0
    Top = 273
    Width = 577
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    ExplicitTop = 400
    ExplicitWidth = 628
    DesignSize = (
      577
      42)
    object buttonOK: TButton
      Left = 414
      Top = 8
      Width = 73
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 465
    end
    object buttonCancel: TButton
      Left = 493
      Top = 8
      Width = 73
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = #12461#12515#12531#12475#12523
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 544
    end
  end
  object groupSelectSite: TGroupBox
    Left = 8
    Top = 8
    Width = 329
    Height = 97
    Caption = #12450#12463#12475#12473#20808#12469#12452#12488
    TabOrder = 0
    object Label3: TLabel
      Left = 16
      Top = 61
      Width = 77
      Height = 12
      Caption = #12461#12540#12503#12450#12521#12452#12502
    end
    object Label4: TLabel
      Left = 171
      Top = 61
      Width = 147
      Height = 12
      Caption = #20998#27598#65288#12480#12511#12540#29031#20250#12434#34892#12356#12414#12377#65289
    end
    object radioSelectQRZ: TRadioButton
      Left = 16
      Top = 24
      Width = 89
      Height = 17
      Caption = 'QRZ.COM'
      TabOrder = 0
    end
    object radioSelectQRZCQ: TRadioButton
      Left = 111
      Top = 24
      Width = 89
      Height = 17
      Caption = 'QRZCQ.COM'
      TabOrder = 1
    end
    object spinKeepAliveIntervalMin: TSpinEdit
      Left = 111
      Top = 58
      Width = 50
      Height = 21
      MaxValue = 300
      MinValue = 1
      TabOrder = 2
      Value = 20
    end
  end
  object groupLinkLogger: TGroupBox
    Left = 353
    Top = 8
    Width = 217
    Height = 259
    Caption = #36899#25658#12377#12427#12525#12462#12531#12464#12477#12501#12488
    TabOrder = 3
    object Label1: TLabel
      Left = 143
      Top = 208
      Width = 29
      Height = 12
      Caption = #12511#12522#31186
    end
    object Label2: TLabel
      Left = 16
      Top = 208
      Width = 48
      Height = 12
      Caption = #30435#35222#38291#38548
    end
    object Label9: TLabel
      Left = 16
      Top = 235
      Width = 54
      Height = 12
      Caption = 'UDP'#12509#12540#12488
    end
    object radioLinkLogger0: TRadioButton
      Left = 16
      Top = 24
      Width = 89
      Height = 17
      Caption = #12394#12375
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object radioLinkLogger1: TRadioButton
      Left = 16
      Top = 56
      Width = 121
      Height = 17
      Caption = 'Win-Test ('#30435#35222')'
      TabOrder = 1
      TabStop = True
    end
    object radioLinkLogger2: TRadioButton
      Left = 16
      Top = 88
      Width = 121
      Height = 17
      Caption = 'zLog (Query)'
      TabOrder = 2
      TabStop = True
    end
    object radioLinkLogger3: TRadioButton
      Left = 16
      Top = 121
      Width = 105
      Height = 17
      Caption = 'N1MM+ ('#30435#35222')'
      TabOrder = 3
      TabStop = True
    end
    object spinScanInterval: TSpinEdit
      Left = 79
      Top = 205
      Width = 58
      Height = 21
      MaxValue = 3000
      MinValue = 100
      TabOrder = 5
      Value = 500
    end
    object radioLinkLogger4: TRadioButton
      Left = 16
      Top = 152
      Width = 121
      Height = 17
      Caption = 'N1MM+ (UDP'#21463#20449')'
      TabOrder = 4
      TabStop = True
    end
    object editUdpPort: TEdit
      Left = 80
      Top = 232
      Width = 57
      Height = 20
      TabOrder = 6
      Text = '12060'
    end
  end
  object groupQRZInfo: TGroupBox
    Left = 8
    Top = 111
    Width = 329
    Height = 75
    Caption = 'QRZ.COM'#24773#22577
    TabOrder = 1
    object Label5: TLabel
      Left = 16
      Top = 24
      Width = 59
      Height = 12
      Caption = #12518#12540#12470#12540'ID'
    end
    object Label6: TLabel
      Left = 16
      Top = 50
      Width = 54
      Height = 12
      Caption = #12497#12473#12527#12540#12489
    end
    object editQRZUserID: TEdit
      Left = 111
      Top = 21
      Width = 200
      Height = 20
      TabOrder = 0
    end
    object editQRZPassword: TEdit
      Left = 111
      Top = 47
      Width = 200
      Height = 20
      TabOrder = 1
    end
  end
  object groupQRZCQInfo: TGroupBox
    Left = 8
    Top = 192
    Width = 329
    Height = 75
    Caption = 'QRZCQ.COM'#24773#22577
    TabOrder = 2
    object Label7: TLabel
      Left = 16
      Top = 24
      Width = 59
      Height = 12
      Caption = #12518#12540#12470#12540'ID'
    end
    object Label8: TLabel
      Left = 16
      Top = 50
      Width = 54
      Height = 12
      Caption = #12497#12473#12527#12540#12489
    end
    object editQRZCQUserid: TEdit
      Left = 111
      Top = 21
      Width = 200
      Height = 20
      TabOrder = 0
    end
    object editQRZCQPassword: TEdit
      Left = 111
      Top = 47
      Width = 200
      Height = 20
      TabOrder = 1
    end
  end
end
