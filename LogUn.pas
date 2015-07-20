unit LogUn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, LogElement, ExtCtrls, DragShape, StdCtrls, LogEdit, Buttons,
  LogFuncElem, LogIn, LogEntry, Menus;

type
  TLogForm = class(TForm)
    LogUrPan: TPanel;
    LogUrEdit: TLogEdit;
    CreateSchemeBtn: TBitBtn;
    EvaluateToTTBtn: TBitBtn;
    PrintImage: TImage;
    LogFuncElem: TLogFuncElem;
    LogElemPM: TPopupMenu;
    DelLEItem: TMenuItem;
    TTPM: TPopupMenu;
    ClearItem: TMenuItem;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure CreateSchemeBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EvaluateToTTBtnClick(Sender: TObject);
    procedure DelLEItemClick(Sender: TObject);
    procedure ClearItemClick(Sender: TObject);
  private
  public
    DoPrint : Boolean;
    function  CreateScheme : Boolean;
    procedure FreeDoc;
    procedure DrawConnectors(var Msg : TMessage); message LM_DRAWCONNECTORS;
    procedure WPC(var Msg : TMessage); message WM_WINDOWPOSCHANGED;
  end;

var
  LogForm: TLogForm;

implementation

uses TTUn, FuncUn, MainUn;

{$R *.dfm}

procedure TLogForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LE : TLogElement;
begin
  with MainForm do
  if (not MouseSB.Down) then
  begin
    LE := TLogElement.Create(Self);
    LE.Parent := Self;

    if LogAndSB.Down then LE.LogElementOp := loAnd else
    if LogOrSB.Down  then LE.LogElementOp := loOr else
    if LogNotSB.Down then LE.LogElementOp := loNot;

    LE.Left := X-(LE.Width div 2);
    LE.Top  := Y-(LE.Height div 2);

    MouseSB.Down := True;
  end;
end;

procedure TLogForm.FormResize(Sender: TObject);
var
  i : Integer;
begin
  LogUrEdit.Width := LogUrPan.Width-160;
  CreateSchemeBtn.Left := LogUrPan.Width-CreateSchemeBtn.Width-10;
  EvaluateToTTBtn.Left := CreateSchemeBtn.Left-70;

  for i := 0 to 5 do
    LogIns[i].Check;

  PostMessage(Handle, LM_DRAWCONNECTORS, 0, 0);
end;

function TLogForm.CreateScheme : Boolean;
// Процедура создания логической схемы на основе логической функции
// Работает рекурсивно, используя динамическую информацию,
// "подготовленную" DivFunc (FuncUn.pas)
var
  Err : Boolean;

  function GetInput(Str : String) : TLogEntry;
  begin
    if (('A'<=Str) and (Str<'F')) then Result :=
      LogIns[ Ord(Str[1])-Ord('A') ] else
    begin
      Result := nil;
      Err := True;
    end;
  end;

  function Recurse(Node : PLogOper; uv : Integer; ETop : Integer) : TLogEntry;
  // Выбирается информация из дерева и создается логический элемент
  var
    I1, I2 : TLogEntry;
  begin
    if (Node^.lo = loNone) then
    begin
      Result := GetInput(Node^.c1);
    end else
    begin
      if (Node^.i1 = nil) then I1 := GetInput(Node^.C1) else
        I1 := Recurse(Node^.i1, uv+1, ETop-60);

      if (Node^.lo = loNot) then I2 := nil else
        if (Node^.i2 = nil) then I2 := GetInput(Node^.C2) else
          I2 := Recurse(Node^.i2, uv+1, ETop+60);

      Result := TLogElement.Create(Self);
      Result.Parent := Self;
      Result.Left := LogFuncElem.Left-80*uv;
      Result.Top  := ETop;
      (Result as TLogElement).LogElementOp := Node^.lo;

      if (I1 <> nil) then
      begin
        (Result as TLogElement).ConnectIO := ioInput1;
        (Result as TLogElement).ConnectToIO := ioOutput;
        (Result as TLogElement).Connect(I1);
      end;
      if (I2 <> nil) then
      begin
        (Result as TLogElement).ConnectIO := ioInput2;
        (Result as TLogElement).ConnectToIO := ioOutput;
        (Result as TLogElement).Connect(I2);
      end;
    end;
  end;
begin
  Err := False;
  if (LOList.Count > 0) then
  begin
    LogFuncElem.ConnectIO := ioInput1;
    LogFuncElem.ConnectToIO := ioOutput;
    LogFuncElem.Connect(Recurse(LOList.Last, 1,
      LogFuncElem.Top+(LogFuncElem.Height div 2)-(50 div 2)));
  end;
  Result := not Err;
  if (Err) then MessageBox(Handle, 'Ошибка анализа формулы !',
    'Таблица истинности', mb_Ok or MB_ICONERROR);
end;

procedure TLogForm.CreateSchemeBtnClick(Sender: TObject);
begin
  FreeDoc;                        // 1) Очистка документа

  if (Copy(Trim(LogUrEdit.Text), 1, 1)<>'X') then
    LogUrEdit.Text := 'X=' + LogUrEdit.Text;

  if (DivFunc(LogUrEdit.Text)) then // 2) Анализ функции
    CreateScheme;                 // 3) Если в порядке, то создать схему

  PostMessage(Handle, LM_DRAWCONNECTORS, 0, 0); // Перерисовка
end;

procedure TLogForm.DrawConnectors(var Msg: TMessage);
var
  i : Integer;
  LC : TLogConnect;
begin
  // Процедура прорисовки соединительных элементов
  if DoPrint then // Для подготовки к печати - на TImage
  begin
    PrintImage.Canvas.Brush.Color := clWhite;
    PrintImage.Canvas.FillRect(Bounds(0, 0, PrintImage.Width, PrintImage.Height));
  end else Refresh;
  for i := 0 to ConnectorList.Count-1 do
  begin
    LC := ConnectorList.Items[i];
    if (LC<>nil) then
    begin
      if (not DoPrint) then LC.Paint(Self) else LC.Paint(PrintImage);
    end;
  end;
end;

procedure TLogForm.FormActivate(Sender: TObject);
begin
  PostMessage(Handle, LM_DRAWCONNECTORS, 0, 0);
end;

procedure TLogForm.FormCreate(Sender: TObject);
var
  i : Integer;
begin
  // Создание и "настройка" логических входов
  for i := 0 to 5 do
  begin
    LogIns[i] := TLogIn.Create(Self);
    LogIns[i].Parent := Self;
    LogIns[i].Left := 10+i*20;
    LogIns[i].Top := 15;//55;
    LogIns[i].InId := Chr(Ord('A')+i);
  end;
  DoPrint := False;

  LEPM := LogElemPM;
end;

procedure TLogForm.EvaluateToTTBtnClick(Sender: TObject);
var
  C, R : Integer;
begin
  LogUrEdit.Text := LogFuncElem.GetLogUr;
  // По схеме постоить логическое уравнение и составить таблицу истинности
  with (TTForm) do
  begin
    R := 0;
    while (R <= RowCount) do
    begin
      C := 0;
      while (C <= InputCount-1) do
      begin
        LogIns[C].InValue := GetCell(C, R);
        Inc(C);
      end;
      TTG.Cells[InputCount, R+1] := BoolToChar(LogFuncElem.Evaluate);
      Inc(R);
    end;
    LogUrTTEdit.Text := LogUrEdit.Text;
  end;
end;

procedure TLogForm.FreeDoc;
var // Удаление всех логических элементов и связывающих их соединений
  i : Integer;
begin
  i := 0;
  if LogFuncElem.Input1C <> nil then LogFuncElem.Input1C.Free;
  while i <= ComponentCount-1 do
  begin
    if ((Components[i] is TLogElement) and
      (not (Components[i] is TLogFuncElem))) then
        Components[i].Free else Inc(i);
  end;
  PostMessage(Handle, LM_DRAWCONNECTORS, 0, 0);

  while (ConnectorList.Count > 0) do
  begin
    if (ConnectorList.Items[0]<>nil) then
      ConnectorList.Free;
    ConnectorList.Delete(0);  
  end;
end;

procedure TLogForm.DelLEItemClick(Sender: TObject);
begin
  if (PopupElem <> nil) then PopupElem.Free;
  PostMessage(Handle, LM_DRAWCONNECTORS, 0, 0);
end;

procedure TLogForm.ClearItemClick(Sender: TObject);
begin
  if (MessageBox(Handle, 'Вы действительно хотите удалить все'#13+
    'логические элементы ?', 'Логика', mb_iconquestion or mb_YesNo) = idYes) then
    FreeDoc;
end;

procedure TLogForm.WPC(var Msg: TMessage);
begin
  inherited;
  PostMessage(Handle, LM_DRAWCONNECTORS, 0, 0);
end;

end.
