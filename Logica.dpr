// Проект  "Логика"
// Программирование - Чернов Сергей
// Главный файл проекта
// Подключаемые модули :
// 1) MainUn - главное окно (для редактора логических схем)
// 2) LogUn - окно документа (для логической схемы)
// 3) TTUn - Окно таблицы истинности
// 4) SetupUn - Окно настроек таблицы истинности
// 5) SNFUn - Юнит с реализацией функций постоения МДНФ, СДНФ,
//   СКНФ
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
  Application.Title := 'Редактор логических схем';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TLogForm, LogForm);
  Application.CreateForm(TTTForm, TTForm);
  Application.CreateForm(TSetupForm, SetupForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.
