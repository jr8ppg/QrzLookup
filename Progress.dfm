object formProgress: TformProgress
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Progress'
  ClientHeight = 98
  ClientWidth = 336
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object labelProgress: TLabel
    Left = 8
    Top = 26
    Width = 320
    Height = 12
    AutoSize = False
    Caption = 'd:\data\allja.zlo'
  end
  object labelTitle: TLabel
    Left = 8
    Top = 8
    Width = 320
    Height = 12
    AutoSize = False
    Caption = 'xxx'#12434#12375#12390#12356#12414#12377
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 44
    Width = 320
    Height = 17
    TabOrder = 0
  end
  object buttonAbort: TButton
    Left = 128
    Top = 67
    Width = 89
    Height = 25
    Caption = #20013#27490
    TabOrder = 1
    OnClick = buttonAbortClick
  end
end
