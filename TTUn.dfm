object TTForm: TTTForm
  Left = 250
  Top = 141
  Width = 585
  Height = 472
  Caption = #1052#1080#1085#1080#1084#1080#1079#1072#1094#1080#1103' '#1083#1086#1075#1080#1095#1077#1089#1082#1086#1081' '#1092#1091#1085#1082#1094#1080#1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    0000000080000080000000808000800000008000800080800000C0C0C0008080
    80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000000000000000000000000000000000000000000000000099
    9000000CC000000CC000009990000009000000C00C0000C00C00000900000009
    000000C00C0000C00C00000900000099000000C00C0000C00C00009900000009
    0000000CC000000CC00000090000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000000C
    C00000999000000CC000000CC00000C00C000009000000C00C0000C00C0000C0
    0C000009000000C00C0000C00C0000C00C000099000000C00C0000C00C00000C
    C00000090000000CC000000CC000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000000C
    C000000CC000009990000099900000C00C0000C00C00000900000009000000C0
    0C0000C00C00000900000009000000C00C0000C00C000099000000990000000C
    C000000CC0000009000000090000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000FEFE
    FEFFFEFEFEFFC6E6E6C7EEDADAEFEEDADAEFCEDADACFEEE6E6EFFEFEFEFF0000
    0000FEFEFEFFE6C6E6E7DAEEDADBDAEEDADBDACEDADBE6EEE6E7FEFEFEFF0000
    0000FEFEFEFFE6E6C6C7DADAEEEFDADAEEEFDADACECFE6E6EEEFFEFEFEFF0000
    0000FEFEFEFFBA8ECE8F82B6B6B7BA8EBEB7D6B6B6B7EE8ECE8FFEFEFEFF}
  OldCreateOrder = False
  ShowHint = True
  Visible = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 0
    Top = 300
    Width = 577
    Height = 7
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
  end
  object WorkPan: TPanel
    Left = 0
    Top = 307
    Width = 577
    Height = 138
    Align = alBottom
    TabOrder = 0
    OnResize = WorkPanResize
    object SDNFBtn: TBitBtn
      Left = 15
      Top = 11
      Width = 105
      Height = 20
      Hint = #1057#1086#1089#1090#1072#1074#1080#1090#1100' '#1057#1044#1053#1060' '#1087#1086' '#1090#1072#1073#1083#1080#1094#1077' '#1080#1089#1090#1080#1085#1085#1086#1089#1090#1080
      Caption = #1057#1044#1053#1060
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = SDNFBtnClick
    end
    object SCNFBtn: TBitBtn
      Left = 15
      Top = 37
      Width = 105
      Height = 20
      Hint = #1057#1086#1089#1090#1072#1074#1080#1090#1100' '#1057#1050#1053#1060' '#1087#1086' '#1090#1072#1073#1083#1080#1094#1077' '#1080#1089#1090#1080#1085#1085#1086#1089#1090#1080
      Caption = #1057#1050#1053#1060
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = SCNFBtnClick
    end
    object MDNFBtn: TBitBtn
      Left = 15
      Top = 63
      Width = 105
      Height = 20
      Hint = #1057#1086#1089#1090#1072#1074#1080#1090#1100' '#1092#1086#1088#1084#1091#1083#1091' '#1052#1044#1053#1060' '#1087#1086' '#1090#1072#1073#1083#1080#1094#1077' '#1080#1089#1090#1080#1085#1085#1086#1089#1090#1080
      Caption = #1052#1044#1053#1060
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = MDNFBtnClick
    end
    object ClearBtn: TBitBtn
      Left = 15
      Top = 107
      Width = 105
      Height = 20
      Hint = #1054#1095#1080#1089#1090#1080#1090#1100
      Cancel = True
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = ClearBtnClick
    end
    object LogUrMemo: TLogMemo
      Left = 128
      Top = 11
      Width = 441
      Height = 87
      ScrollBars = ssVertical
      TabOrder = 4
    end
    object LogUrTTResEdit: TLogEdit
      Left = 128
      Top = 106
      Width = 404
      Height = 21
      TabOrder = 5
    end
    object CreateSchemeTTBtn: TBitBtn
      Left = 539
      Top = 104
      Width = 30
      Height = 25
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1083#1086#1075#1080#1095#1077#1089#1082#1091#1102' '#1089#1093#1077#1084#1091
      Caption = '>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      OnClick = CreateSchemeTTBtnClick
    end
  end
  object FormPan: TPanel
    Left = 0
    Top = 0
    Width = 577
    Height = 49
    Align = alTop
    TabOrder = 1
    OnResize = WorkPanResize
    object LogUrTTEdit: TLogEdit
      Left = 16
      Top = 11
      Width = 185
      Height = 21
      TabOrder = 0
      Text = 'X = A+B'
    end
    object EvaluateFormulaBtn: TBitBtn
      Left = 209
      Top = 10
      Width = 56
      Height = 25
      Hint = #1057#1086#1089#1090#1072#1074#1080#1090#1100' '#1090#1072#1073#1083#1080#1094#1091' '#1080#1089#1090#1080#1085#1085#1086#1089#1090#1080
      Caption = '>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = TranslateFormulaSBClick
    end
  end
  object MainPan: TPanel
    Left = 0
    Top = 49
    Width = 577
    Height = 251
    Align = alClient
    TabOrder = 2
    OnResize = MainPanResize
    object TTG: TStringGrid
      Left = 1
      Top = 1
      Width = 575
      Height = 249
      Hint = #1058#1072#1073#1083#1080#1094#1072' '#1080#1089#1090#1080#1085#1085#1086#1089#1090#1080' '#1092#1091#1085#1082#1094#1080#1080
      Align = alClient
      ColCount = 6
      DefaultColWidth = 40
      FixedCols = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      PopupMenu = TTGPM
      TabOrder = 0
      OnDrawCell = TTGDrawCell
      OnKeyPress = TTGKeyPress
      ColWidths = (
        40
        40
        40
        40
        40
        41)
    end
  end
  object TTGPM: TPopupMenu
    Left = 56
    Top = 112
    object MDNFItem: TMenuItem
      Caption = #1057#1086#1089#1090#1072#1074#1080#1090#1100' '#1052#1044#1053#1060
      OnClick = MDNFBtnClick
    end
    object CreateSchemeItem: TMenuItem
      Caption = #1057#1086#1089#1090#1072#1074#1080#1090#1100' '#1083#1086#1075#1080#1095#1077#1089#1082#1091#1102' '#1089#1093#1077#1084#1091
      Hint = #1055#1086#1089#1090#1088#1086#1080#1090#1100' '#1083#1086#1075#1080#1095#1077#1089#1082#1091#1102' '#1089#1093#1077#1084#1091' '#1087#1086' '#1092#1091#1085#1082#1094#1080#1080
      OnClick = CreateSchemeTTBtnClick
    end
    object DivItem: TMenuItem
      Caption = '-'
    end
    object SetupPMItem: TMenuItem
      Caption = #1054#1087#1094'&'#1080#1080
      ShortCut = 118
      OnClick = SetupPMItemClick
    end
    object InitInputsItem: TMenuItem
      Caption = '&'#1047#1072#1087#1086#1083#1085#1080#1090#1100' '#1074#1093#1086#1076#1099
      ShortCut = 116
      OnClick = InitInputsItemClick
    end
  end
end
