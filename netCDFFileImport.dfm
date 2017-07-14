object NetCDFForm: TNetCDFForm
  Left = 0
  Top = 0
  Caption = 'netCDF file import'
  ClientHeight = 620
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object StatusLabel: TLabel
    Left = 0
    Top = 607
    Width = 418
    Height = 13
    Align = alBottom
    Caption = 'Status:'
    ExplicitWidth = 35
  end
  object Label2: TLabel
    Left = 317
    Top = 69
    Width = 83
    Height = 13
    Caption = 'Sub for NaN/INF:'
  end
  object Panel2: TPanel
    Left = 0
    Top = 63
    Width = 312
    Height = 528
    Align = alLeft
    Caption = 'Panel2'
    TabOrder = 0
    ExplicitTop = 33
    ExplicitHeight = 558
    object Splitter1: TSplitter
      Left = 137
      Top = 1
      Width = 8
      Height = 526
      ExplicitLeft = 143
      ExplicitTop = -4
      ExplicitHeight = 556
    end
    object VarCheckListBox1: TCheckListBox
      Left = 1
      Top = 1
      Width = 136
      Height = 526
      OnClickCheck = VarCheckListBox1ClickCheck
      Align = alLeft
      ItemHeight = 13
      TabOrder = 0
      ExplicitHeight = 556
    end
    object DimensionCheckListBox1: TCheckListBox
      Left = 145
      Top = 1
      Width = 166
      Height = 526
      Align = alClient
      ItemHeight = 13
      TabOrder = 1
      ExplicitHeight = 556
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 418
    Height = 63
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 9
      Top = 44
      Width = 154
      Height = 13
      Caption = 'Select netCDF variables to load:'
    end
    object FileLabel: TLabel
      Left = 9
      Top = 25
      Width = 49
      Height = 13
      Caption = 'Filename: '
    end
    object DirLabel: TLabel
      Left = 9
      Top = 6
      Width = 20
      Height = 13
      Caption = 'Dir: '
    end
  end
  object Button1: TButton
    Left = 314
    Top = 32
    Width = 96
    Height = 25
    Caption = 'load netCDF data'
    TabOrder = 2
    OnClick = Button1Click
  end
  object ProgressBar1netCDF: TProgressBar
    Left = 0
    Top = 591
    Width = 418
    Height = 16
    Align = alBottom
    TabOrder = 3
    ExplicitWidth = 411
  end
  object NaNsubEdit1: TEdit
    Left = 317
    Top = 88
    Width = 94
    Height = 21
    TabOrder = 4
    Text = '-1.0'
  end
end
