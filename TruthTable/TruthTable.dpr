program TruthTable;

uses
  Forms,
  TTUn in 'TTUn.pas' {MainForm},
  SetupUn in 'SetupUn.pas' {SetupForm},
  SNFUn in 'SNFUn.pas',
  AboutUnit in 'AboutUnit.pas' {AboutForm},
  FuncUn in 'FuncUn.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Таблица истинности';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSetupForm, SetupForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.
