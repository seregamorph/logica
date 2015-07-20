// ������  "������"
// ���������������� - ������ ������
// ������� ���� �������
// ������������ ������ :
// 1) MainUn - ������� ���� (��� ��������� ���������� ����)
// 2) LogUn - ���� ��������� (��� ���������� �����)
// 3) TTUn - ���� ������� ����������
// 4) SetupUn - ���� �������� ������� ����������
// 5) SNFUn - ���� � ����������� ������� ��������� ����, ����,
//   ����
//                                             5.02.2002

program Logica;

uses
  Forms,
  MainUn in 'MainUn.pas' {MainForm},
  LogUn in 'LogUn.pas' {LogForm},
  TTUn in 'TTUn.pas' {TTForm},
  SetupUn in 'SetupUn.pas' {SetupForm},
  SNFUn in 'SNFUn.pas',
  AboutUnit in 'AboutUnit.pas' {AboutForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '�������� ���������� ����';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TLogForm, LogForm);
  Application.CreateForm(TTTForm, TTForm);
  Application.CreateForm(TSetupForm, SetupForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.
