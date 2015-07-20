unit AboutUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ShellApi;

type
  TAboutForm = class(TForm)
    OkBtn: TBitBtn;
    AboutPan: TPanel;
    MainIcon: TImage;
    MailToSerg: TLabel;
    Label4: TLabel;
    Bevel1: TBevel;
    Label5: TLabel;
    PhysMem: TLabel;
    Label6: TLabel;
    FreeRes: TLabel;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure MailToSergMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MailToSergClick(Sender: TObject);
    procedure SendMail(sObjectPath : PChar);
    procedure ElseMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.DFM}

procedure TAboutForm.FormShow(Sender: TObject);
var
  MS: TMemoryStatus;
begin
  GlobalMemoryStatus(MS);
  PhysMem.Caption := FormatFloat('#,###" KB"', MS.dwTotalPhys / 1024);
  FreeRes.Caption := Format('%d %%', [MS.dwMemoryLoad]);
end;

procedure TAboutForm.MailToSergMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  MailToSerg.Font.Color := clLime;
end;

procedure TAboutForm.SendMail(sObjectPath : PChar);
begin
  ShellExecute(0, Nil, sObjectPath, Nil, Nil, SW_NORMAL);
end;

procedure TAboutForm.MailToSergClick(Sender: TObject);
var
  TempString : array[0..79] of char;
begin
  StrPCopy(TempString, 'mailto:sergey_chernow@mail.ru');
  SendMail(TempString);
end;

procedure TAboutForm.ElseMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  MailToSerg.Font.Color := clBlack;
end;

end.
