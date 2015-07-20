object SetupForm: TSetupForm
  Left = 347
  Top = 360
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
  ClientHeight = 193
  ClientWidth = 445
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object OkBtn: TBitBtn
    Left = 272
    Top = 160
    Width = 75
    Height = 25
    Caption = '&OK'
    TabOrder = 0
    OnClick = OkBtnClick
    Kind = bkOK
  end
  object CancelBtn: TBitBtn
    Left = 360
    Top = 160
    Width = 75
    Height = 25
    Caption = '&'#1054#1090#1084#1077#1085#1072
    TabOrder = 1
    Kind = bkCancel
  end
  object Panel1: TPanel
    Left = 10
    Top = 8
    Width = 425
    Height = 145
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    object InCountLab: TLabel
      Left = 16
      Top = 16
      Width = 153
      Height = 16
      Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1074#1093#1086#1076#1086#1074' :'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object OutputCountLab: TLabel
      Left = 16
      Top = 48
      Width = 163
      Height = 16
      Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1074#1099#1093#1086#1076#1086#1074' :'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
    object InputCountSE: TSpinEdit
      Left = 184
      Top = 14
      Width = 137
      Height = 22
      EditorEnabled = False
      MaxValue = 6
      MinValue = 1
      TabOrder = 0
      Value = 3
    end
    object OutputCountSE: TSpinEdit
      Left = 184
      Top = 46
      Width = 137
      Height = 22
      EditorEnabled = False
      Enabled = False
      MaxValue = 3
      MinValue = 1
      TabOrder = 1
      Value = 1
      Visible = False
    end
    object AutoLastOpenCB: TCheckBox
      Left = 16
      Top = 80
      Width = 305
      Height = 17
      Caption = #1040#1074#1090#1086#1079#1072#1075#1088#1091#1079#1082#1072' '#1087#1088#1077#1076#1099#1076#1091#1097#1077#1081' '#1090#1072#1073#1083#1080#1094#1099
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
    end
  end
end
