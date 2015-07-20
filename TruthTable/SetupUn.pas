unit SetupUn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Spin;

type
  TSetupForm = class(TForm)
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Panel1: TPanel;
    InputCountSE: TSpinEdit;
    InCountLab: TLabel;
    OutputCountLab: TLabel;
    OutputCountSE: TSpinEdit;
    AutoLastOpenCB: TCheckBox;
    procedure OkBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SetupForm: TSetupForm;

implementation

uses TTUn;

{$R *.dfm}

procedure TSetupForm.OkBtnClick(Sender: TObject);
var
  ReInit : Boolean;
begin
  With MainForm do
  begin
    ReInit := (InputCount <> InputCountSE.Value) or
      (OutputCount <> OutputCountSE.Value);

    InputCount   := InputCountSE.Value;
    OutputCount  := OutputCountSE.Value;
    AutoLastOpen := AutoLastOpenCB.Checked;

    If ReInit then
    begin
      FName := '';
      InitGrid;
    end;
  end;
end;

procedure TSetupForm.FormShow(Sender: TObject);
begin
  With MainForm do
  begin
    InputCountSE.Value  := InputCount;
    OutputCountSE.Value := OutputCount;

    AutoLastOpenCB.Checked := AutoLastOpen;
  end;
end;

end.
