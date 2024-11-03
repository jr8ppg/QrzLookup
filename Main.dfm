object formMain: TformMain
  Left = 0
  Top = 0
  Caption = 'QRZ.COM Lookup Tool'
  ClientHeight = 184
  ClientWidth = 688
  Color = clBtnFace
  Constraints.MinHeight = 150
  Constraints.MinWidth = 350
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  Menu = MainMenu1
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 15
  object StringGrid1: TStringGrid
    Left = 0
    Top = 30
    Width = 688
    Height = 135
    Align = alClient
    FixedCols = 0
    RowCount = 2
    TabOrder = 1
    OnDrawCell = StringGrid1DrawCell
    OnMouseWheelDown = StringGrid1MouseWheelDown
    OnMouseWheelUp = StringGrid1MouseWheelUp
    OnTopLeftChanged = StringGrid1TopLeftChanged
    ExplicitTop = 41
    ExplicitWidth = 684
    ExplicitHeight = 123
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 165
    Width = 688
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
    ExplicitTop = 164
    ExplicitWidth = 684
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 688
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object Label1: TLabel
      Left = 95
      Top = 7
      Width = 48
      Height = 15
      Caption = 'Callsign'
    end
    object editCallsign: TEdit
      Left = 149
      Top = 4
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
      Left = 256
      Top = 4
      Width = 62
      Height = 23
      Caption = 'Lookup'
      TabOrder = 2
      OnClick = buttonQueryClick
    end
    object ToggleSwitch1: TToggleSwitch
      Left = 5
      Top = 5
      Width = 83
      Height = 20
      StateCaptions.CaptionOn = 'ON'
      StateCaptions.CaptionOff = 'OFF'
      TabOrder = 0
      OnClick = ToggleSwitch1Click
    end
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
    AutoHotkeys = maManual
    AutoLineReduction = maManual
    Left = 528
    Top = 80
    object menuFile: TMenuItem
      Caption = #27231#33021'(&F)'
      OnClick = menuFileClick
      object menuOptions: TMenuItem
        Caption = #12458#12503#12471#12519#12531'(&O)'
        OnClick = menuOptionsClick
      end
      object menuCustomList: TMenuItem
        Caption = #12459#12473#12479#12512#12522#12473#12488'(&C)'
        OnClick = menuCustomListClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
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
