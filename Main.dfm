object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'QRZ.COM Lookup Tool'
  ClientHeight = 162
  ClientWidth = 671
  Color = clBtnFace
  Constraints.MinHeight = 150
  Constraints.MinWidth = 500
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
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
    Width = 671
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 112
      Top = 13
      Width = 48
      Height = 15
      Caption = 'Callsign'
    end
    object Label2: TLabel
      Left = 492
      Top = 13
      Width = 83
      Height = 15
      Caption = 'Scan interval'
    end
    object Label3: TLabel
      Left = 643
      Top = 13
      Width = 18
      Height = 15
      Caption = 'ms'
    end
    object editCallsign: TEdit
      Left = 166
      Top = 10
      Width = 123
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
      Left = 295
      Top = 10
      Width = 73
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
    object checkUseWt: TCheckBox
      Left = 373
      Top = 13
      Width = 105
      Height = 17
      Caption = 'With WinTest'
      TabOrder = 3
      OnClick = checkUseWtClick
    end
    object editInterval: TEdit
      Left = 576
      Top = 10
      Width = 45
      Height = 23
      TabOrder = 4
      Text = '500'
    end
    object updownInterval: TUpDown
      Left = 621
      Top = 10
      Width = 16
      Height = 23
      Associate = editInterval
      Min = 100
      Max = 3000
      Increment = 20
      Position = 500
      TabOrder = 5
      OnClick = updownIntervalClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 143
    Width = 671
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
    Width = 671
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
end
