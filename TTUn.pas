// Работа с таблицей истинности
//

unit TTUn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, Buttons, IniFiles, Menus, ExtCtrls, SNFUn,
  LogMemo, LogEdit;

type
  TTTForm = class(TForm)
    TTGPM: TPopupMenu;
    InitInputsItem: TMenuItem;
    WorkPan: TPanel;
    SDNFBtn: TBitBtn;
    Splitter: TSplitter;
    SetupPMItem: TMenuItem;
    SCNFBtn: TBitBtn;
    MDNFBtn: TBitBtn;
    ClearBtn: TBitBtn;
    LogUrMemo: TLogMemo;
    FormPan: TPanel;
    LogUrTTEdit: TLogEdit;
    MainPan: TPanel;
    TTG: TStringGrid;
    EvaluateFormulaBtn: TBitBtn;
    LogUrTTResEdit: TLogEdit;
    CreateSchemeTTBtn: TBitBtn;
    DivItem: TMenuItem;
    MDNFItem: TMenuItem;
    CreateSchemeItem: TMenuItem;
    procedure TTGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure TTGKeyPress(Sender: TObject; var Key: Char);
    procedure InitInputsItemClick(Sender: TObject);
    procedure MainPanResize(Sender: TObject);
    procedure WorkPanResize(Sender: TObject);
    procedure SetupItemClick(Sender: TObject);
    procedure SetupPMItemClick(Sender: TObject);
    procedure SDNFBtnClick(Sender: TObject);
    procedure SCNFBtnClick(Sender: TObject);
    procedure MDNFBtnClick(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TranslateFormulaSBClick(Sender: TObject);
    procedure CreateSchemeTTBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  public
    RowCount, ColCount     : Integer;

    IOArr : TIOArr;

    procedure InitGrid;
    procedure FillInputs;
    procedure FreeLOList;
    function GetCell(C, R : Integer) : Boolean;
    procedure InitIOArr;
  end;

var
  TTForm: TTTForm;

function BoolToChar(Value : Boolean) : Char;

implementation

uses SetupUn, FuncUn, LogElement, MainUn, LogUn;

{$R *.dfm}

// Перевод булевого значения в символ
function BoolToChar(Value : Boolean) : Char;
begin
  If Value then Result := '1' else
    Result := '0';
end;

// Получение ячейки таблицы
function TTTForm.GetCell(C, R : Integer) : Boolean;
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

procedure TTTForm.SetupItemClick(Sender: TObject);
begin
  SetupForm.ShowModal;
end;

// Процедура прорисовки ячеек таблицы
procedure TTTForm.TTGDrawCell(Sender: TObject; ACol,
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

// Обработка нажатий клавиш на таблице
procedure TTTForm.TTGKeyPress(Sender: TObject; var Key: Char);
var
  Text : String;
begin
  If Key='1' then Text := '1' else Text := '0';
  TTG.Cells[TTG.Col, TTG.Row] := Text;
end;

// Подготовка таблицы истинности
procedure TTTForm.InitGrid;
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

  For i := 0 to 5 do
  begin
    LogIns[i].Visible := (i+1 <= InputCount);
    If LogIns[i].Visible then LogIns[i].NumbId := i+1 else LogIns[i].NumbId := 0;
  end;
end;

// Заполнение входных переменных всеми возможными значениями
// A   B   C
// 0   0   0
// 0   0   1
// .........
// 1   1   0
// 1   1   1
procedure TTTForm.FillInputs;
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

procedure TTTForm.InitInputsItemClick(Sender: TObject);
begin
  FillInputs;
end;

procedure TTTForm.MainPanResize(Sender: TObject);
begin
  TTG.DefaultColWidth := (TTG.Width-30) div TTG.ColCount;
end;

procedure TTTForm.WorkPanResize(Sender: TObject);
begin
  LogUrMemo.Width  := WorkPan.Width  - LogUrMemo.Left - 20;
  LogUrMemo.Height := WorkPan.Height - LogUrMemo.Top  - 45;

  LogUrTTResEdit.Width  := WorkPan.Width  - 190;
  LogUrTTResEdit.Top    := WorkPan.Height - 40+2;

  CreateSchemeTTBtn.Top := WorkPan.Height - 40;
  CreateSchemeTTBtn.Left := WorkPan.Width  - 50;
end;

procedure TTTForm.SetupPMItemClick(Sender: TObject);
begin
  SetupForm.ShowModal;
end;

// Заполнение массива IOArr данными из таблицы для работы
// функций **НФ
procedure TTTForm.InitIOArr;
var
  C, R : Integer;
begin
  For R := 0 to RowCount-1 do
  For C := 0 to ColCount-1 do
    IOArr[C, R] := GetCell(C, R);
end;

procedure TTTForm.SDNFBtnClick(Sender: TObject);
var
  SDNF : String;
begin
  InitIOArr;
  SDNF := GetSDNF(IOArr);
  LogUrMemo.Lines.Add('СДНФ : '+SDNF);
  LogUrTTResEdit.Text := SDNF;
end;

procedure TTTForm.SCNFBtnClick(Sender: TObject);
var
  SCNF : String;
begin
  InitIOArr;
  SCNF := GetSCNF(IOArr);
  LogUrMemo.Lines.Add('СКНФ : '+SCNF);
  LogUrTTResEdit.Text := SCNF;
end;

procedure TTTForm.MDNFBtnClick(Sender: TObject);
var
  MDNF : String;
begin
  InitIOArr;
  MDNF := GetMDNF(IOArr);
  LogUrMemo.Lines.Add('МДНФ : ' + MDNF);
  LogUrTTResEdit.Text := MDNF;
end;

procedure TTTForm.ClearBtnClick(Sender: TObject);
begin
  LogUrMemo.Lines.Clear;
end;

procedure TTTForm.FormDestroy(Sender: TObject);
begin
  FreeLOList;

  LOList.Free;
end;

procedure TTTForm.FreeLOList;
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

// Анализ текстовой логической функции
// для построения таблицы истинности
procedure TTTForm.TranslateFormulaSBClick(Sender: TObject);
var
  Inputs : TInputsArr;
  r, c : Integer;
begin
  If (Copy(Trim(LogUrTTEdit.Text), 1, 1)<>'X') then
    LogUrTTEdit.Text := 'X='+LogUrTTEdit.Text;

  FreeLOList;
  if (DivFunc(LogUrTTEdit.Text)) then
  for r := 0 to RowCount-1 do
  begin
    For c := 0 to InputCount-1 do
      Inputs[c+1] := GetCell(c, r);
    TTG.Cells[InputCount, r+1] := BoolToChar(EvaluateFunc(Inputs))
  end;
end;

procedure TTTForm.CreateSchemeTTBtnClick(Sender: TObject);
begin
  If (Copy(Trim(LogUrTTResEdit.Text), 1, 1)<>'X') then
    LogUrTTResEdit.Text := 'X=' + LogUrTTResEdit.Text;
  With LogForm do
  begin
    LogUrEdit.Text := LogUrTTResEdit.Text;
    LogForm.CreateSchemeBtnClick(Self);
  end;
  LogForm.Show;
end;

procedure TTTForm.FormCreate(Sender: TObject);
begin
  LogUrTTEdit.SetFocusTo := EvaluateFormulaBtn;
  LogUrTTResEdit.SetFocusTo := CreateSchemeTTBtn;
end;

end.
