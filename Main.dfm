object formMain: TformMain
  Left = 0
  Top = 0
  Caption = 'QRZ.COM Lookup Tool'
  ClientHeight = 162
  ClientWidth = 724
  Color = clBtnFace
  Constraints.MinHeight = 150
  Constraints.MinWidth = 740
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 724
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 100
      Top = 13
      Width = 48
      Height = 15
      Caption = 'Callsign'
    end
    object Label2: TLabel
      Left = 580
      Top = 13
      Width = 46
      Height = 15
      Caption = 'interval'
    end
    object Label3: TLabel
      Left = 699
      Top = 13
      Width = 18
      Height = 15
      Caption = 'ms'
    end
    object editCallsign: TEdit
      Left = 154
      Top = 10
      Width = 105
      Height = 23
      CharCase = ecUpperCase
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = #65325#65331' '#12468#12471#12483#12463
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnChange = editCallsignChange
      OnEnter = editCallsignEnter
      OnExit = editCallsignExit
    end
    object buttonQuery: TButton
      Left = 261
      Top = 10
      Width = 62
      Height = 23
      Caption = 'Lookup'
      TabOrder = 2
      OnClick = buttonQueryClick
    end
    object ToggleSwitch1: TToggleSwitch
      Left = 10
      Top = 11
      Width = 83
      Height = 20
      StateCaptions.CaptionOn = 'ON'
      StateCaptions.CaptionOff = 'OFF'
      TabOrder = 0
      OnClick = ToggleSwitch1Click
    end
    object editInterval: TEdit
      Left = 632
      Top = 10
      Width = 45
      Height = 23
      TabOrder = 3
      Text = '500'
    end
    object updownInterval: TUpDown
      Left = 677
      Top = 10
      Width = 16
      Height = 23
      Associate = editInterval
      Min = 100
      Max = 3000
      Increment = 20
      Position = 500
      TabOrder = 4
      OnClick = updownIntervalClick
    end
    object Panel2: TPanel
      Left = 334
      Top = 10
      Width = 238
      Height = 25
      BevelOuter = bvLowered
      TabOrder = 5
      object radioLoggerLink0: TRadioButton
        Left = 8
        Top = 7
        Width = 42
        Height = 13
        Caption = 'None'
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        TabStop = True
      end
      object radioLoggerLink1: TRadioButton
        Left = 56
        Top = 8
        Width = 69
        Height = 13
        Caption = 'Win-Test'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object radioLoggerLink2: TRadioButton
        Left = 127
        Top = 8
        Width = 44
        Height = 13
        Caption = 'zLog'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnClick = radioLoggerLink2Click
      end
      object radioLoggerLink3: TRadioButton
        Left = 175
        Top = 8
        Width = 58
        Height = 13
        Caption = 'N1MM+'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        OnClick = radioLoggerLink3Click
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 143
    Width = 724
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Width = 80
      end
      item
        Alignment = taCenter
        Width = 80
      end
      item
        Alignment = taCenter
        Width = 120
      end
      item
        Alignment = taCenter
        Width = 100
      end>
  end
  object StringGrid1: TStringGrid
    Left = 0
    Top = 41
    Width = 724
    Height = 102
    Align = alClient
    FixedCols = 0
    RowCount = 2
    TabOrder = 2
    OnDrawCell = StringGrid1DrawCell
    OnTopLeftChanged = StringGrid1TopLeftChanged
  end
  object timerWtCheck: TTimer
    Interval = 500
    OnTimer = timerWtCheckTimer
    Left = 448
    Top = 104
  end
  object NetHTTPClient1: TNetHTTPClient
    UserAgent = 'Embarcadero URI Client/1.0'
    OnRequestError = NetHTTPRequest1RequestError
    OnRequestException = NetHTTPRequest1RequestException
    Left = 352
    Top = 60
  end
  object NetHTTPRequest1: TNetHTTPRequest
    Client = NetHTTPClient1
    OnRequestError = NetHTTPRequest1RequestError
    OnRequestException = NetHTTPRequest1RequestException
    Left = 400
    Top = 60
  end
  object MainMenu1: TMainMenu
    Left = 528
    Top = 80
    object menuFile: TMenuItem
      Caption = #12501#12449#12452#12523'(&F)'
      OnClick = menuFileClick
      object menuRbnTool: TMenuItem
        Caption = 'RBN'#12487#12540#12479#12398#37325#35079#21066#38500'(&R)'
        OnClick = menuRbnToolClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object menuExit: TMenuItem
        Caption = #32066#20102'(&X)'
        OnClick = menuExitClick
      end
    end
  end
end
