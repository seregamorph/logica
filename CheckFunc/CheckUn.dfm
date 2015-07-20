object MainForm: TMainForm
  Left = 202
  Top = 134
  Width = 544
  Height = 281
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object LogUrIn: TLogEdit
    Left = 16
    Top = 16
    Width = 195
    Height = 21
    TabOrder = 0
    Text = 'X = A'#8226'(B+C)'#8226#172'A'
  end
  object LogUrOut: TLogEdit
    Left = 256
    Top = 16
    Width = 195
    Height = 21
    TabOrder = 1
  end
  object CheckBtn: TBitBtn
    Left = 16
    Top = 48
    Width = 33
    Height = 25
    Caption = '>>'
    TabOrder = 2
    OnClick = CheckBtnClick
  end
  object Memo: TMemo
    Left = 56
    Top = 48
    Width = 257
    Height = 161
    TabOrder = 3
  end
  object CreateBtn: TBitBtn
    Left = 320
    Top = 48
    Width = 33
    Height = 25
    Caption = '^'
    TabOrder = 4
    OnClick = CreateBtnClick
  end
end
