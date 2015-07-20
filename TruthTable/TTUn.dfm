object MainForm: TMainForm
  Left = 45
  Top = 26
  Width = 737
  Height = 561
  Caption = #1058#1072#1073#1083#1080#1094#1072' '#1080#1089#1090#1080#1085#1085#1086#1089#1090#1080
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
  Menu = MainMenu
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 0
    Top = 363
    Width = 729
    Height = 7
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
  end
  object WorkPan: TPanel
    Left = 0
    Top = 370
    Width = 729
    Height = 145
    Align = alBottom
    TabOrder = 0
    OnResize = WorkPanResize
    object SDNFBtn: TBitBtn
      Left = 15
      Top = 11
      Width = 105
      Height = 20
      Caption = #1057#1044#1053#1060
      TabOrder = 0
      OnClick = SDNFBtnClick
    end
    object SCNFBtn: TBitBtn
      Left = 15
      Top = 37
      Width = 105
      Height = 20
      Caption = #1057#1050#1053#1060
      TabOrder = 1
      OnClick = SCNFBtnClick
    end
    object MDNFBtn: TBitBtn
      Left = 15
      Top = 63
      Width = 105
      Height = 20
      Caption = #1052#1044#1053#1060
      TabOrder = 2
      OnClick = MDNFBtnClick
    end
    object SMDNFBtn: TBitBtn
      Left = 15
      Top = 89
      Width = 105
      Height = 20
      Caption = #1057#1086#1082#1088'. '#1052#1044#1053#1060
      Enabled = False
      TabOrder = 3
      OnClick = SMDNFBtnClick
    end
    object ClearBtn: TBitBtn
      Left = 15
      Top = 116
      Width = 105
      Height = 20
      Cancel = True
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      TabOrder = 4
      OnClick = ClearBtnClick
    end
    object LogUr: TLogMemo
      Left = 128
      Top = 11
      Width = 441
      Height = 123
      TabOrder = 5
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 729
    Height = 49
    Align = alTop
    TabOrder = 1
    OnResize = WorkPanResize
    object LogUrToTable: TLogEdit
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
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = TranslateFormulaSBClick
    end
  end
  object MainPan: TPanel
    Left = 0
    Top = 49
    Width = 729
    Height = 314
    Align = alClient
    TabOrder = 2
    OnResize = MainPanResize
    object TTG: TStringGrid
      Left = 1
      Top = 1
      Width = 727
      Height = 312
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
    Left = 376
    Top = 176
    object SetupPMItem: TMenuItem
      Caption = #1054#1087#1094'&'#1080#1080
      ShortCut = 118
      OnClick = SetupPMItemClick
    end
    object InitInputsItem: TMenuItem
      Caption = '&'#1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1074#1093#1086#1076#1099
      ShortCut = 116
      OnClick = InitInputsItemClick
    end
  end
  object MainMenu: TMainMenu
    Left = 344
    Top = 176
    object FileItem: TMenuItem
      Caption = '&'#1060#1072#1081#1083
      object OpenItem: TMenuItem
        Caption = '&'#1054#1090#1082#1088#1099#1090#1100'...'
        ShortCut = 114
        OnClick = OpenItemClick
      end
      object SaveItem: TMenuItem
        Caption = '&'#1057#1086#1093#1088#1072#1085#1080#1090#1100'...'
        ShortCut = 113
        OnClick = SaveItemClick
      end
      object Divider1: TMenuItem
        Caption = '-'
      end
      object SetupItem: TMenuItem
        Caption = #1054#1087#1094'&'#1080#1080'...'
        ShortCut = 118
        OnClick = SetupItemClick
      end
      object Divider2: TMenuItem
        Caption = '-'
      end
      object ExitItem: TMenuItem
        Caption = '&'#1042#1099#1093#1086#1076
        ShortCut = 121
        OnClick = ExitItemClick
      end
    end
    object HelpItem: TMenuItem
      Caption = '&'#1055#1086#1084#1086#1097#1100
      object AboutItem: TMenuItem
        Caption = '&'#1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
        ShortCut = 112
        OnClick = AboutItemClick
      end
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'rls'
    Filter = #1060#1072#1081#1083' '#1090#1072#1073#1083#1080#1094#1099' '#1080#1089#1090#1080#1085#1085#1086#1089#1090#1080' (*.rls)|*.rls|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 280
    Top = 176
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'rls'
    Filter = #1060#1072#1081#1083' '#1090#1072#1073#1083#1080#1094#1099' '#1080#1089#1090#1080#1085#1085#1086#1089#1090#1080' (*.rls)|*.rls|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 312
    Top = 176
  end
end
