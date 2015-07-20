unit TTUn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, Buttons, IniFiles, Menus, ExtCtrls, SNFUn,
  LogMemo, LogEdit;

type
  TMainForm = class(TForm)
    TTGPM: TPopupMenu;
    InitInputsItem: TMenuItem;
    WorkPan: TPanel;
    SDNFBtn: TBitBtn;
    Splitter: TSplitter;
    MainMenu: TMainMenu;
    FileItem: TMenuItem;
    HelpItem: TMenuItem;
    ExitItem: TMenuItem;
    Divider2: TMenuItem;
    OpenItem: TMenuItem;
    SaveItem: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    Divider1: TMenuItem;
    SetupItem: TMenuItem;
    AboutItem: TMenuItem;
    SetupPMItem: TMenuItem;
    SCNFBtn: TBitBtn;
    MDNFBtn: TBitBtn;
    SMDNFBtn: TBitBtn;
    ClearBtn: TBitBtn;
    LogUr: TLogMemo;
    Panel1: TPanel;
    LogUrToTable: TLogEdit;
    MainPan: TPanel;
    TTG: TStringGrid;
    EvaluateFormulaBtn: TBitBtn;
    procedure TTGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure TTGKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure InitInputsItemClick(Sender: TObject);
    procedure MainPanResize(Sender: TObject);
    procedure WorkPanResize(Sender: TObject);
    procedure ExitItemClick(Sender: TObject);
    procedure SaveItemClick(Sender: TObject);
    procedure OpenItemClick(Sender: TObject);
    procedure SetupItemClick(Sender: TObject);
    procedure AboutItemClick(Sender: TObject);
    procedure SetupPMItemClick(Sender: TObject);
    procedure SDNFBtnClick(Sender: TObject);
    procedure SCNFBtnClick(Sender: TObject);
    procedure MDNFBtnClick(Sender: TObject);
    procedure SMDNFBtnClick(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TranslateFormulaSBClick(Sender: TObject);
  private
  public
    InputCount,
    OutputCount  : Integer;
    RowCount,
    ColCount     : Integer;
    AutoLastOpen : Boolean;
    FName        : String;

    IOArr : TIOArr;

    procedure InitGrid;
    procedure FillInputs;
    procedure FreeLOList;
    function GetCell(C, R : Integer) : Boolean;
    function OpenFile(FileName : String) : Boolean;
    function SaveFile(Erase : Boolean; FileName: String): Boolean;
    procedure InitIOArr;
  end;

var
  MainForm: TMainForm;

function BoolToChar(Value : Boolean) : Char;

implementation

uses SetupUn, AboutUnit, FuncUn;

{$R *.dfm}

function BoolToChar(Value : Boolean) : Char;
begin
  If Value then Result := '1' else
    Result := '0';
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  Ini : TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName)+'TT.ini');
  InputCount   := Ini.ReadInteger('Main', 'InputCount', 3);
  OutputCount  := Ini.ReadInteger('Main', 'OutputCount', 1);
  AutoLastOpen := Ini.ReadBool('Main', 'AutoLastOpen', False);
  FName        := Ini.ReadString('Main', 'FName', '');
  OpenDialog.InitialDir := Ini.ReadString('Main', 'OpenPath', 'C:\');
  SaveDialog.InitialDir := Ini.ReadString('Main', 'SavePath', 'C:\');

  Left   := Ini.ReadInteger('Window', 'Left', 150);
  Top    := Ini.ReadInteger('Window', 'Top', 100);
  Width  := Ini.ReadInteger('Window', 'Width', 500);
  Height := Ini.ReadInteger('Window', 'Height', 400);
  WindowState  := TWindowState(Ini.ReadInteger('Window', 'WindowState', 0));
  WorkPan.Height := Ini.ReadInteger('Window', 'Splitter', 145);
  Ini.Free;
//  MessageBox(Handle, PChar(IntToStr(SizeOf(TBiNabor))), '', mb_Ok);

  LOList := TList.Create;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  If not AutoLastOpen then InitGrid else
  If not OpenFile(ExtractFilePath(Application.ExeName)+'TT.ini') then InitGrid;
  FillInputs;

  TTG.SetFocus;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Ini : TIniFile;
  r, c : Integer;
  Str : String;
begin
  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName)+'TT.ini');
  Ini.WriteInteger('Main', 'InputCount', InputCount);
  Ini.WriteInteger('Main', 'OutputCount', OutputCount);
  Ini.WriteBool('Main', 'AutoLastOpen', AutoLastOpen);
//  Ini.WriteString('Main', 'FName', FName);

  If ExtractFileName(OpenDialog.FileName) <> '' then
    Ini.WriteString('Main', 'OpenPath', ExtractFileDir(OpenDialog.FileName));
  If ExtractFileName(SaveDialog.FileName) <> '' then
    Ini.WriteString('Main', 'SavePath', ExtractFileDir(SaveDialog.FileName));

  Ini.WriteInteger('Window', 'Left', Left);
  Ini.WriteInteger('Window', 'Top', Top);
  Ini.WriteInteger('Window', 'Width', Width);
  Ini.WriteInteger('Window', 'Height', Height);
  Ini.WriteInteger('Window', 'WindowState', Integer(WindowState));
  Ini.WriteInteger('Window', 'Splitter', WorkPan.Height);
  If AutoLastOpen then
  begin
    Ini.EraseSection('Lines');
    For r := 0 to RowCount-1 do
    begin
      Str := '';
      For c := 0 to ColCount-1 do
      begin
        Str := Str+' '+BoolToChar(GetCell(c, r));
      end;
      Str := Trim(Str);

      Ini.WriteString('Lines', 'Line'+IntToStr(r+1), Str);
    end;
  end;

  Ini.Free;
end;

function TMainForm.GetCell(C, R : Integer) : Boolean;
begin
  Inc(R);
  With TTG do
  begin
    If Cells[C, R] = '1' then Result := True else
    begin
      Result := False;
      If Cells[C, R]='' then Cells[C, R] := '0';
    end;
  end;
end;

procedure TMainForm.SetupItemClick(Sender: TObject);
begin
  SetupForm.ShowModal;
end;

procedure TMainForm.TTGDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  Text : String;
  X, Y : Integer;
begin
  With TTG.Canvas do
  begin
    Text := TTG.Cells[ACol, ARow];
    X := ((Rect.Left+Rect.Right) div 2) - (TextWidth(Text) div 2);
    Y := ((Rect.Top+Rect.Bottom) div 2) - (TextHeight(Text) div 2);

    FillRect(Rect);
    If ARow > 0 then
      If Text='1' then
        Font.Color := clRed else
        Font.Color := clBlue;
    TextOut(X, Y, Text);
    Font.Color := clBlack;
  end;
end;

procedure TMainForm.TTGKeyPress(Sender: TObject; var Key: Char);
var
  Text : String;
begin
  If Key='1' then Text := '1' else Text := '0';
  TTG.Cells[TTG.Col, TTG.Row] := Text;
end;

procedure TMainForm.InitGrid;
var
  i : Integer;
begin
  TTG.ColCount := InputCount + OutputCount;
  ColCount := TTG.ColCount;
  For i := 0 to InputCount-1 do
    TTG.Cells[i, 0] := Chr(Ord('A')+i);
  For i := 0 to OutputCount-1 do
    TTG.Cells[InputCount+i, 0] := Chr(Ord('X')+i);
  TTG.RowCount := (1 shl InputCount)+1; // 2^InputCount+1
  RowCount := TTG.RowCount-1;

  TTG.DefaultColWidth := (TTG.Width-30) div TTG.ColCount;
end;

procedure TMainForm.FillInputs;
var
  r, c, rn, divider : Integer;
begin
  With TTG do
  For r := 1 to (1 shl InputCount) do
  begin
    rn := r-1;
    For c := 0 to InputCount-1 do
    begin
      divider := (1 shl (InputCount-c-1));
      Cells[c, r] := IntToStr(rn div divider);
      rn := rn mod (divider);
    end;
    If Cells[InputCount, R]='' then Cells[InputCount, R] := '0';
  end;
end;

procedure TMainForm.InitInputsItemClick(Sender: TObject);
begin
  FillInputs;
end;

procedure TMainForm.MainPanResize(Sender: TObject);
begin
  TTG.DefaultColWidth := (TTG.Width-30) div TTG.ColCount;
end;

procedure TMainForm.WorkPanResize(Sender: TObject);
begin
  LogUr.Width  := WorkPan.Width  - LogUr.Left - 20;
  LogUr.Height := WorkPan.Height - LogUr.Top  - 20;
end;

procedure TMainForm.ExitItemClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.SaveItemClick(Sender: TObject);
begin
  If SaveDialog.Execute then
  begin
    SaveDialog.InitialDir := '';

    FName := SaveDialog.FileName;
    SaveFile(True, FName);
  end;
end;

function TMainForm.OpenFile(FileName: String): Boolean;
var
  Open : TIniFile;
  r, c : Integer;
  Str : String;
begin
  If (FileName='') or (not FileExists(FileName)) then
  begin
    Result := False;
    Exit;
  end else Result := True;

  Open := TIniFile.Create(FileName);
  InputCount  := Open.ReadInteger('Main', 'InputCount', 3);
  OutputCount := Open.ReadInteger('Main', 'OutputCount', 1);
  InitGrid;
  For r := 1 to RowCount do
  begin
    Str := Open.ReadString('Lines', 'Line'+IntToStr(r), '');
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
  Open.Free;
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

procedure TMainForm.AboutItemClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMainForm.SetupPMItemClick(Sender: TObject);
begin
  SetupForm.ShowModal;
end;

procedure TMainForm.InitIOArr;
var
  C, R : Integer;
begin
  For R := 0 to RowCount-1 do
  For C := 0 to ColCount-1 do
    IOArr[C, R] := GetCell(C, R);
end;

procedure TMainForm.SDNFBtnClick(Sender: TObject);
begin
  InitIOArr;
  LogUr.Lines.Add(GetSDNF(IOArr));
end;

procedure TMainForm.SCNFBtnClick(Sender: TObject);
begin
  InitIOArr;
  LogUr.Lines.Add(GetSCNF(IOArr));
end;

procedure TMainForm.MDNFBtnClick(Sender: TObject);
begin
  InitIOArr;
  LogUr.Lines.Add(GetMDNF(IOArr));
end;

procedure TMainForm.SMDNFBtnClick(Sender: TObject);
begin
  InitIOArr;
  LogUr.Lines.Add(GetMDNF(IOArr));
end;

procedure TMainForm.ClearBtnClick(Sender: TObject);
begin
  LogUr.Lines.Clear;
end;

function TMainForm.SaveFile(Erase : Boolean; FileName: String): Boolean;
var
  Save : TIniFile;
  r, c : Integer;
  Str  : String;
begin
  Result := False;
  If FName = '' then
  begin
    Result := True;

    Save := TIniFile.Create(FName);
    If Erase then Save.EraseSection('Main');
    Save.WriteInteger('Main', 'RowCount', RowCount-1);
    Save.WriteInteger('Main', 'InputCount', InputCount);
    Save.WriteInteger('Main', 'OutputCount', OutputCount);

    If Erase then Save.EraseSection('Lines');
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

    Save.Free;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeLOList;

  LOList.Free;
end;

procedure TMainForm.FreeLOList;
var
  PLOper : PLogOper;
begin
  While LOList.Count>0 do
  begin
    PLOper := LOList.Items[0];
    Dispose(PLOper);
    LOlist.Delete(0);
  end;

end;

procedure TMainForm.TranslateFormulaSBClick(Sender: TObject);
var
  Inputs : TInputsArr;
  r, c : Integer;
begin
  FreeLOList;
  CheckFunc(LogUrToTable.Text);
  
  For r := 0 to RowCount-1 do
  begin
    For c := 0 to InputCount-1 do
      Inputs[c+1] := GetCell(c, r);
    TTG.Cells[InputCount, r+1] := BoolToChar(EvaluateFunc(Inputs))
  end;
end;

end.
