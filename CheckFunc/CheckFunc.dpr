program CheckFunc;

uses
  Forms,
  CheckUn in 'CheckUn.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
