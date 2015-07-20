// Юнит LogUn
// Реализация функций управления редактором логической схемы
// Программирование - Чернов Сергей
//


unit MainUn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, LogElement, StdCtrls, Buttons, Menus, IniFiles,
  DragShape, LogEdit, LogFuncElem, ToolWin, ComCtrls;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    FileItem: TMenuItem;
    HelpItem: TMenuItem;
    ExitItem: TMenuItem;
    DivItem3: TMenuItem;
    SaveItem: TMenuItem;
    SaveDialog: TSaveDialog;
    OpenItem: TMenuItem;
    OpenDialog: TOpenDialog;
    LogElemPan: TPanel;
    MouseSB: TSpeedButton;
    LogAndSB: TSpeedButton;
    LogOrSB: TSpeedButton;
    LogNotSB: TSpeedButton;
    AbotItem: TMenuItem;
    DivItem1: TMenuItem;
    SetupItem: TMenuItem;
    WindowItem: TMenuItem;
    TTShowItem: TMenuItem;
    LogShowItem: TMenuItem;
    DivItem2: TMenuItem;
    PrintItem: TMenuItem;
    PrintLogSchemeItem: TMenuItem;
    procedure ExitItemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure AbotItemClick(Sender: TObject);
    procedure SetupItemClick(Sender: TObject);
    procedure OpenItemClick(Sender: TObject);
    procedure SaveItemClick(Sender: TObject);
    procedure TTShowItemClick(Sender: TObject);
    procedure LogShowItemClick(Sender: TObject);
    procedure PrintLogSchemeItemClick(Sender: TObject);
  private
  public
    function SaveFile(FileName: String) : Boolean;
    function OpenFile(FileName: String) : Boolean;
  end;

var
  FName        : String;
  AutoLastOpen : Boolean;
  InputCount : Integer;
  MainForm: TMainForm;
const
  OutputCount = 1;

implementation

uses TTUn, FuncUn, AboutUnit, SetupUn, LogUn, LogEntry;

{$R *.dfm}

procedure TMainForm.ExitItemClick(Sender: TObject);
begin
  Close;
end;

function TMainForm.SaveFile(FileName: String): Boolean;
// Сохранение файла
var
  Save : TIniFile;
  r, c : Integer;
  Str  : String;
  i, LECount : Integer;
  LE : TLogElement;
  LC : TLogConnect;
begin
  Result := False;
  If FileName <> '' then
  begin
    Result := True;

    Save := TIniFile.Create(FileName);

    // Таблица истинности
    With TTForm do
    begin
      Save.WriteString('Main', 'LogEdit', LogUrTTEdit.Text);
      Save.WriteString('Main', 'LogEditRes', LogUrTTResEdit.Text);

      Save.WriteInteger('Main', 'RowCount', RowCount-1);
      Save.WriteInteger('Main', 'InputCount', InputCount);
      Save.WriteInteger('Main', 'OutputCount', OutputCount);

      Save.EraseSection('Lines');
      For r := 0 to RowCount-1 do
      begin
        Str := '';
        For c := 0 to ColCount-1 do
        begin
          Str := Str+' '+BoolToChar(GetCell(c, r));
        end;
        Str := Trim(Str);

        Save.WriteString('Lines', 'Line'+IntToStr(r+1), Str);
      end;
    end;

    // Документ - логическая схема
    With LogForm do
    begin
      Save.WriteString('Main', 'LogUrRes', LogUrEdit.Text);

      LECount := 1;

      Save.WriteInteger('LFE', 'Left', LogFuncElem.Left);
      Save.WriteInteger('LFE', 'Top', LogFuncElem.Top);
      Save.WriteInteger('LFE', 'NumbId', LECount+InputCount);

      For i := 0 to ComponentCount-1 do // Сохранение логических элементов
      If (Components[i] is TLogElement) then
      If not (Components[i] is TLogFuncElem) then
      begin
        LE := Components[i] as TLogElement;
        Inc(LECount);
        LE.NumbId := LECount+InputCount;

        Save.WriteInteger('LE'+IntToStr(LECount), 'Left', LE.Left);
        Save.WriteInteger('LE'+IntToStr(LECount), 'Top', LE.Top);
        Save.WriteInteger('LE'+IntToStr(LECount), 'NumbId', LE.NumbId);
        Save.WriteInteger('LE'+IntToStr(LECount), 'LogElementOp',
          Integer(LE.LogElementOp));
      end;

      Save.WriteInteger('Main', 'LECount', LECount);

      For i := 0 to ConnectorList.Count-1 do
      begin
        If ConnectorList.Items[i] <> nil then
        begin
          LC := ConnectorList.Items[i];
          If LC.LE1 <> nil then
          begin
            Save.WriteInteger('Connector'+IntToStr(i), 'NumbId1', LC.LE1.NumbId);
            Save.WriteInteger('Connector'+IntToStr(i), 'IO1', Integer(LC.LE1IO));
          end;
          If LC.LE2 <> nil then
          begin
            Save.WriteInteger('Connector'+IntToStr(i), 'NumbId2', LC.LE2.NumbId);
            Save.WriteInteger('Connector'+IntToStr(i), 'IO2', Integer(LC.LE2IO));
          end;
        end;
      end;
    end;
    Save.WriteInteger('Main', 'CCount', ConnectorList.Count);

    Save.Free;
  end;
end;

function TMainForm.OpenFile(FileName: String): Boolean;
// Загрузка документа
var
  Save : TIniFile;
  i, LECount, CCount, NumbId1, NumbId2, LEO : Integer;
  IO1, IO2 : TIO;
  LE, LE1 : TLogElement;
  LE2 : TLogEntry;
  r, c : Integer;
  Str : String;
  LENumbIdList : TList;
begin
  If (FileName='') or (not FileExists(FileName)) then
  begin
    Result := False;
    Exit;
  end else Result := True;

  LogForm.FreeDoc;

  LENumbIdList := TList.Create;

  Save := TIniFile.Create(FileName);

  // Документ - логическая схема

  For i := 0 to InputCount-1 do
    LENumbIdList.Add(LogIns[i]);
  LENumbIdList.Add(LogForm.LogFuncElem);

  LECount := Save.ReadInteger('Main', 'LECount', 0);
  CCount  := Save.ReadInteger('Main', 'CCount', 0);
  With LogForm do
  begin
    LogUrEdit.Text := Save.ReadString('Main', 'LogUrRes', 'X=A+B');

    For i := 2 to LECount do
    begin
      LE := TLogElement.Create(LogForm);
      LE.Parent := LogForm;
      LE.Left := Save.ReadInteger('LE'+IntToStr(i), 'Left', 50);
      LE.Top :=  Save.ReadInteger('LE'+IntToStr(i), 'Top', 50);
      LEO := Save.ReadInteger('LE'+IntToStr(i), 'LogElementOp', 1);
      LE.LogElementOp := LogElementOpArr[LEO];
      LE.NumbId := i;
      LENumbIdList.Add(LE);
    end;
    LogFuncElem.Left := Save.ReadInteger('LFE', 'Left', 450);
    LogFuncElem.Top  := Save.ReadInteger('LFE', 'Top',  200);
    LogFuncElem.NumbId := Save.ReadInteger('LFE', 'NumbId', 4);

    For i := 0 to CCount-1 do
    begin
      NumbId1 := Save.ReadInteger('Connector'+IntToStr(i), 'NumbId1', 0);
      NumbId2 := Save.ReadInteger('Connector'+IntToStr(i), 'NumbId2', 0);
      IO1     := TIO(Save.ReadInteger('Connector'+IntToStr(i), 'IO1', 0));
      IO2     := TIO(Save.ReadInteger('Connector'+IntToStr(i), 'IO2', 0));
      If (NumbId1<>0) and (NumbId2<>0) then
      begin
        LE1 := nil; LE2 := nil;

        If NumbId1 <= LENumbIdList.Count then
          LE1 := LENumbIdList.Items[NumbId1-1];
        If NumbId2 <= LENumbIdList.Count then
          LE2 := LENumbIdList.Items[NumbId2-1];

        If (LE1<>nil) and (LE2<>nil) then
        begin
          LE1.ConnectIO   := IO1;
          LE1.ConnectToIO := IO2;
          LE1.Connect(LE2);
        end;
      end;
    end;
  end;

  // Таблица истинности
  With TTForm do
  begin
    InputCount  := Save.ReadInteger('Main', 'InputCount', 3);
//    OutputCount := Save.ReadInteger('Main', 'OutputCount', 1);
    InitGrid;

    LogUrTTEdit.Text := Save.ReadString('Main', 'LogEdit', 'X=A+B');
    LogUrTTResEdit.Text := Save.ReadString('Main', 'LogEditRes', 'X=A+B');

    For r := 1 to RowCount do
    begin
      Str := Save.ReadString('Lines', 'Line'+IntToStr(r), '');
      If Length(Str)<2*ColCount-1 then
      begin
        MessageBox(Handle, PChar('Ошибка загрузки файла'#13+
          FileName), 'Ошибка', mb_Ok or MB_ICONWARNING);
        Result := False;
        break;
      end;
      For c := 0 to ColCount-1 do
        If Str[2*c+1]='1' then TTG.Cells[c, r] := '1' else
        TTG.Cells[c, r] := '0';
    end;
  end;

  Save.Free;

  LENumbIdList.Free;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  SaveDialog.InitialDir := ExtractFilePath(Application.ExeName);
  OpenDialog.InitialDir := ExtractFilePath(Application.ExeName);

  LOList := TList.Create;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Ini : TIniFile;
begin
  // Сохранение параметров настройки

  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName)+'Logica.ini');

  // Окно таблицы истинности
  With TTForm do
  begin
    Ini.WriteInteger('TTForm', 'InputCount', InputCount);
    Ini.WriteInteger('TTForm', 'OutputCount', OutputCount);

    Ini.WriteString('TTForm', 'LogEdit', LogUrTTEdit.Text);
    Ini.WriteString('TTForm', 'LogEditRes', LogUrTTResEdit.Text);

    If ExtractFileName(OpenDialog.FileName) <> '' then
      Ini.WriteString('TTForm', 'OpenPath', ExtractFileDir(OpenDialog.FileName));
    If ExtractFileName(SaveDialog.FileName) <> '' then
      Ini.WriteString('TTForm', 'SavePath', ExtractFileDir(SaveDialog.FileName));

    Ini.WriteInteger('TTForm', 'Left', Left);
    Ini.WriteInteger('TTForm', 'Top', Top);
    Ini.WriteInteger('TTForm', 'Width', Width);
    Ini.WriteInteger('TTForm', 'Height', Height);
    Ini.WriteInteger('TTForm', 'WindowState', Integer(WindowState));
    Ini.WriteInteger('TTForm', 'Splitter', WorkPan.Height);
  end;

  // Окно документа - логической схемы
  With LogForm do
  begin
    Ini.WriteString('LogForm', 'LogEdit', LogUrEdit.Text);

    Ini.WriteInteger('LogForm', 'Left', Left);
    Ini.WriteInteger('LogForm', 'Top', Top);
    Ini.WriteInteger('LogForm', 'Width', Width);
    Ini.WriteInteger('LogForm', 'Height', Height);
    Ini.WriteInteger('LogForm', 'WindowState', Integer(WindowState));

    Ini.WriteInteger('LogForm', 'LFELeft', LogFuncElem.Left);
    Ini.WriteInteger('LogForm', 'LFETop',  LogFuncElem.Top);
  end;

  // Главное окно
  Ini.WriteInteger('MainForm', 'Left', Left);
  Ini.WriteInteger('MainForm', 'Top', Top);
  Ini.WriteInteger('MainForm', 'Width', Width);
  Ini.WriteInteger('MainForm', 'WindowState', Integer(WindowState));

  Ini.WriteBool('MainForm', 'AutoLastOpen', AutoLastOpen);
  If AutoLastOpen then
    SaveFile(ExtractFilePath(Application.ExeName)+'Autosave.ini');

  Ini.Free;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  Ini : TIniFile;
begin
  // Загрузка параметров настройки

  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName)+'Logica.ini');
  With TTForm do
  begin
    InputCount   := Ini.ReadInteger('TTForm', 'InputCount', 3);
//    OutputCount  := Ini.ReadInteger('TTForm', 'OutputCount', 1);

    LogUrTTEdit.Text := Ini.ReadString('TTForm', 'LogEdit', 'X=A+B');
    LogUrTTResEdit.Text := Ini.ReadString('TTForm', 'LogEditRes', 'X=A+B');

    OpenDialog.InitialDir := Ini.ReadString('TTForm', 'OpenPath', 'C:\');
    SaveDialog.InitialDir := Ini.ReadString('TTForm', 'SavePath', 'C:\');

    Left   := Ini.ReadInteger('TTForm', 'Left', -1);
    Top    := Ini.ReadInteger('TTForm', 'Top', 103);
    Width  := Ini.ReadInteger('TTForm', 'Width', 500);
    Height := Ini.ReadInteger('TTForm', 'Height', 640);
    WindowState  := TWindowState(Ini.ReadInteger('TTForm', 'WindowState', 0));
    WorkPan.Height := Ini.ReadInteger('TTForm', 'Splitter', 145);

    TTG.SetFocus;
  end;

  With LogForm do
  begin
    LogUrEdit.Text := Ini.ReadString('LogForm', 'LogEdit', 'X=A+B');

    Left   := Ini.ReadInteger('LogForm', 'Left', 500);
    Top    := Ini.ReadInteger('LogForm', 'Top', 103);
    Width  := Ini.ReadInteger('LogForm', 'Width', 525);
    Height := Ini.ReadInteger('LogForm', 'Height', 640);
    WindowState  := TWindowState(Ini.ReadInteger('LogForm', 'WindowState', 0));

    LogFuncElem.Left := Ini.ReadInteger('LogForm', 'LFELeft', 480);
    LogFuncElem.Top  := Ini.ReadInteger('LogForm', 'LFETop', 160);
  end;

  Left   := Ini.ReadInteger('MainForm', 'Left', -4);
  Top    := Ini.ReadInteger('MainForm', 'Top', -4);
  Width  := Ini.ReadInteger('MainForm', 'Width', 600);
  WindowState  := TWindowState(Ini.ReadInteger('MainForm', 'WindowState', 2));
  AutoLastOpen := Ini.ReadBool('MainForm', 'AutoLastOpen', False);

  With TTForm do
  begin
    If not AutoLastOpen then InitGrid else
      If not OpenFile(ExtractFilePath(Application.ExeName)+'Autosave.ini') then InitGrid;
        FillInputs;
  end;      

  Ini.Free;
end;

procedure TMainForm.AbotItemClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMainForm.SetupItemClick(Sender: TObject);
begin
  SetupForm.ShowModal;
end;

procedure TMainForm.OpenItemClick(Sender: TObject);
begin
  If OpenDialog.Execute then
  begin
    OpenDialog.InitialDir := '';
    FName := OpenDialog.FileName;

    OpenFile(FName);
  end;
end;

procedure TMainForm.SaveItemClick(Sender: TObject);
begin
  If SaveDialog.Execute then
  begin
    SaveDialog.InitialDir := '';

    FName := SaveDialog.FileName;
    SaveFile(FName);
  end;
end;

procedure TMainForm.TTShowItemClick(Sender: TObject);
begin
  TTForm.Show;
end;

procedure TMainForm.LogShowItemClick(Sender: TObject);
begin
  LogForm.Show;
end;

procedure TMainForm.PrintLogSchemeItemClick(Sender: TObject);
begin
  // Процедура печати документа

  LogForm.DoPrint := True;
  LogForm.PrintImage.Visible := True;
  SendMessage(LogForm.Handle, LM_DRAWCONNECTORS, 0, 0); // Подготовка к печати-
  LogForm.Print;                               // рисование на PrintImage
  LogForm.DoPrint := False;
  LogForm.PrintImage.Visible := False;
  LogForm.PrintImage.Canvas.Brush.Color := clWhite;
  LogForm.PrintImage.Canvas.FillRect(Bounds(0, 0, LogForm.PrintImage.Width,
    LogForm.PrintImage.Height));
  PostMessage(LogForm.Handle, LM_DRAWCONNECTORS, 0, 0);
end;

end.
