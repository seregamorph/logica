object LogForm: TLogForm
  Left = 171
  Top = 92
  Width = 597
  Height = 465
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1083#1086#1075#1080#1095#1077#1089#1082#1080#1093' '#1089#1093#1077#1084
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = TTPM
  Visible = True
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnMouseDown = FormMouseDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PrintImage: TImage
    Left = 0
    Top = 0
    Width = 589
    Height = 397
    Align = alClient
    PopupMenu = TTPM
    Visible = False
  end
  object LogFuncElem: TLogFuncElem
    Left = 480
    Top = 160
    Width = 30
    Height = 30
    Hint = #1051#1086#1075#1080#1095#1077#1089#1082#1072#1103' '#1092#1091#1085#1082#1094#1080#1103
    LogElementOp = loNot
  end
  object LogUrPan: TPanel
    Left = 0
    Top = 397
    Width = 589
    Height = 41
    Align = alBottom
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object LogUrEdit: TLogEdit
      Left = 9
      Top = 9
      Width = 432
      Height = 21
      TabOrder = 0
    end
    object CreateSchemeBtn: TBitBtn
      Left = 518
      Top = 8
      Width = 60
      Height = 25
      Hint = #1057#1086#1089#1090#1072#1074#1080#1090#1100' '#1083#1086#1075#1080#1095#1077#1089#1082#1091#1102' '#1089#1093#1077#1084#1091' '#1087#1086' '#1092#1086#1088#1084#1091#1083#1077
      Caption = '>'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = CreateSchemeBtnClick
    end
    object EvaluateToTTBtn: TBitBtn
      Left = 451
      Top = 8
      Width = 60
      Height = 25
      Hint = #1057#1086#1089#1090#1072#1074#1080#1090#1100' '#1090#1072#1073#1083#1080#1094#1091' '#1080#1089#1090#1080#1085#1085#1086#1089#1090#1080' '#1076#1083#1103' '#1087#1086#1089#1090#1088#1086#1077#1085#1085#1086#1081' '#1089#1093#1077#1084#1099
      Caption = '<'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = EvaluateToTTBtnClick
    end
  end
  object LogElemPM: TPopupMenu
    Left = 48
    Top = 40
    object DelLEItem: TMenuItem
      Caption = '&'#1059#1076#1072#1083#1080#1090#1100
      OnClick = DelLEItemClick
    end
  end
  object TTPM: TPopupMenu
    Left = 88
    Top = 40
    object ClearItem: TMenuItem
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      OnClick = ClearItemClick
    end
  end
end
