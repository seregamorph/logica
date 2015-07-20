// Описание компонентов - логического элемента
// и соединительного элемента
// Главный компонент в программе

unit LogElement;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, ExtCtrls, DragShape,
    Graphics, Forms, LogIn, LogEntry, Menus;

const
  LM_DRAWCONNECTORS = WM_USER + 1; // Сообщение перерисовки соединений

type
  TLogConnect = class;

// Описание компонета - логического элемента

  TLogElement = class(TDragShape)
  private
    IOHL, ConnectToIOHL : Boolean;

    CX, CY, OX, OY : Integer;

    ConnectRect, ConnectToRect : TRect;

    Connecting : Boolean;
    ConnectToLE : TLogElement;
    FLogElementOp : TLogElementOp;
    Created : Boolean;

    procedure LogMouseMove(var Msg : TWMMouseMove); message WM_MOUSEMOVE;
    procedure LogMouseDown(var Msg : TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure LogRightMouseDown(var Msg : TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure LogMouseUp(var Msg : TWMLButtonUp); message WM_LBUTTONUP;
  protected
  public
    Input1C, Input2C,
    OutputC                : TLogConnect;
    ConnectIO, ConnectToIO : TIO;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure Connect(ConnectTo : TLogEntry);
    procedure Paint; override;
    function Evaluate : Boolean; override;
    function GetLogUr : String; override;
    procedure SetLogOp(Value : TLogElementOp);
  published
    property LogElementOp : TLogElementOp read FLogElementOp write SetLogOp;
  end;

// Описание соединений логических элементов

  TLogConnect = class
  private
    procedure Check;
  protected
  public
    LE1, LE2 : TLogEntry;
    LE1IO, LE2IO : TIO;
    Slash : Boolean;
    Left, Top, Width, Height : Integer;
    Color : TColor;
    procedure Paint(PaintTo : TComponent);
    constructor Create;
    destructor Destroy; override;
  published
  end;

var
  ConnectorList : TList; // Список соединений
  LogIns : array[0..5] of TLogIn;
  LEPM : TPopupMenu;
  PopupElem : TLogElement;

procedure Register;

implementation

uses LogFuncElem;

procedure Register;
begin
  RegisterComponents('Logica', [TLogElement]);
end;

{ TLogElement }

procedure TLogElement.Connect(ConnectTo: TLogEntry);
// "Присоединение" элемента к другому элементу
// по известным параметрам
var
  Connector : TLogConnect;
begin
  Connector := TLogConnect.Create;
  Connector.LE1 := Self;
  Connector.LE2 := ConnectTo;
  Connector.LE1IO := ConnectIO;
  Connector.LE2IO := ConnectToIO;
  Case ConnectIO of
    ioInput1 : Input1C := Connector;
    ioInput2 : Input2C := Connector;
    ioOutput : OutputC := Connector;
  end;

  If (ConnectTo is TLogElement) then
  Case ConnectToIO of
    ioInput1 :
      begin
        if (ConnectTo as TLogElement).Input1C<>nil then (ConnectTo as TLogElement).Input1C.Free;
        (ConnectTo as TLogElement).Input1C := Connector;
      end;
    ioInput2 :
      begin
        if (ConnectTo as TLogElement).Input2C<>nil then (ConnectTo as TLogElement).Input2C.Free;
        (ConnectTo as TLogElement).Input2C := Connector;
      end;
    ioOutput :
      begin
        if (ConnectTo as TLogElement).OutputC<>nil then (ConnectTo as TLogElement).OutputC.Free;
        (ConnectTo as TLogElement).OutputC := Connector;
      end;
  end;

  Connector.Check;

  If (ConnectTo is TLogIn) then
  begin
    If ConnectIO = ioOutput then Connector.Color := clRed;
  end else
  If not ( ((ConnectIO=ioOutput) and (ConnectToIO<>ioOutput)) or
           ((ConnectIO<>ioOutput) and (ConnectToIO=ioOutput)) ) then
    Connector.Color := clRed;

  PostMessage((Parent as TForm).Handle, LM_DRAWCONNECTORS, 0, 0);
end;

constructor TLogElement.Create(AOwner: TComponent);
begin
  inherited;

  Width := 70;
  Height := 50;

  LogElementOp := loNone;
  Created := False;

  Input1C := nil;
  Input2C := nil;
  OutputC := nil;

  NumbId := 0;

  DragRect := Bounds(20, 0, Width-40, Height);

  PopupMenu := LEPM;

  ShowHint := True;
end;

destructor TLogElement.Destroy;
begin
  // Перед удалением логического элемента необходимо освободить
  // логические коннекторы

  If Input1C <> nil then Input1C.Free;
  If Input2C <> nil then Input2C.Free;
  If OutputC <> nil then OutputC.Free;

  inherited;
end;

function TLogElement.Evaluate: Boolean;
// Процедура рекурсивного расчета значения функции
var
  In1B, In2B : Boolean;
  Err : Boolean;
begin
  Result := False; Err := False; // Подсчет функции
  In1B := False; In2B := False;
  If Input1C <> nil then // Определение операндов
  begin
    If Input1C.LE1<>Self then In1B := Input1C.LE1.Evaluate else
      In1B := Input1C.LE2.Evaluate;
  end else Err := True;
  If (LogElementOp<>loNot) then
  If Input2C <> nil then // Определение операндов
  begin
    If Input2C.LE1<>Self then In2B := Input2C.LE1.Evaluate else
      In2B := Input2C.LE2.Evaluate;
  end else Err := True;

  If Err then MessageBox((Parent as TForm).Handle,
    'Невозможно анализировать функцию !', 'Ошибка !', mb_Ok) else

  Case LogElementOp of
    loAnd : Result := In1B and In2B;
    loOr  : Result := In1B or In2B;
    loNot : Result := not In1B;
    else Result := False;
  end;
end;

function InClem(Width, Height, X, Y : Integer; var Rect : TRect; var IO : TIO) : Boolean;
// Определение, находится ли указатель мыши (X, Y) в одной из областей
// для соединения с другими логическими элементами
var
  Rect1, Rect2, Rect3 : TRect;
begin
  Result := True;
  Rect1 := Bounds(10, 10, 10, 10);
  Rect2 := Bounds(10, Height-20, 10, 10);
  Rect3 := Bounds(Width-20, (Height div 2)-5, 10, 10);

  If PointInRect(Rect1, X, Y) then begin Rect := Rect1; IO := ioInput1; end else
  If PointInRect(Rect2, X, Y) then begin Rect := Rect2; IO := ioInput2; end else
  If PointInRect(Rect3, X, Y) then begin Rect := Rect3; IO := ioOutput; end else
    Result := False;
end;

function TLogElement.GetLogUr: String;
// Рекурсивная процедура составления логического уравнения
var
  Err : Boolean;
begin
  Result := ''; Err := False;
  If Input1C = nil then Err := True else
  If LogElementOp=loNot then Result := '(' else
    If Input1C.LE1=Self then Result := '('+Input1C.LE2.GetLogUr else
      Result := '('+Input1C.LE1.GetLogUr;

  If Result <> '' then
  Case LogElementOp of
    loAnd : Result := Result + '•';
    loOr  : Result := Result + '+';
    loNot : Result := Result + '¬';
  end;
  If LogElementOp<>loNot then
  begin
    If Input2C = nil then Err := True else
      If Input2C.LE1=Self then Result := Result+Input2C.LE2.GetLogUr+')' else
        Result := Result+Input2C.LE1.GetLogUr+')';
  end else
  begin
    If Input1C = nil then Err := True else
    If Input1C.LE1=Self then Result := Result+Input1C.LE2.GetLogUr+')' else
      Result := Result+Input1C.LE1.GetLogUr+')';
  end;
  If Err then MessageBox((Parent as TForm).Handle, 'Ошибка анализа схемы !',
    'Таблица истинности', mb_Ok or MB_ICONERROR);
end;

procedure TLogElement.LogMouseDown(var Msg: TWMLButtonDown);
var
  OutSide : Boolean;
begin
  inherited;

  OutSide := not InClem(Width, Height, Msg.XPos, Msg.YPos, ConnectRect, ConnectIO);

  If not OutSide then
  begin
    // Начало процесса соединения элементов
    CX := (ConnectRect.Left+ConnectRect.Right) div 2;
    CY := (ConnectRect.Top+ConnectRect.Bottom) div 2;
    OX := CX;
    OY := CY;
    Connecting := True;
    Case ConnectIO of
      ioInput1 : If Input1C<>nil then Input1C.Free;
      ioInput2 : If Input2C<>nil then Input2C.Free;
      ioOutput : If OutputC<>nil then OutputC.Free;
    end;
    PostMessage((Parent as TForm).Handle, LM_DRAWCONNECTORS, 0, 0);
  end;
end;

procedure TLogElement.LogMouseMove(var Msg: TWMMouseMove);
var
  i : Integer;
begin
  inherited;

  If (not Connecting) then // Эффект "резинки" - перерисовка линий
  begin
    If (InClem(Width, Height, Msg.XPos, Msg.YPos, ConnectRect, ConnectIO)) then
    begin
      If not IOHL then
      begin
        IOHL := True;
        Canvas.Brush.Color := clBlack;
        Canvas.Rectangle(ConnectRect);
        Canvas.Brush.Color := clWhite;

        Cursor := crHandPoint;
      end;
    end else
    begin
      If IOHL then
      begin
        IOHL := False;
        Canvas.Brush.Color := clWhite;
        Canvas.Rectangle(ConnectRect);

        Cursor := crDefault;

        PostMessage((Parent as TForm).Handle, LM_DRAWCONNECTORS, 0, 0);
      end;
    end;
  end else  
  begin
    // Перерисовка во время соединения логических элементов

    (Parent as TForm).Canvas.Pen.Color := clBlack;

    (Parent as TForm).Canvas.MoveTo(CX+Left, CY+Top);
    (Parent as TForm).Canvas.Pen.Mode := pmNotXor;
    (Parent as TForm).Canvas.LineTo(OX+Left, OY+Top);

    (Parent as TForm).Canvas.MoveTo(CX+Left, CY+Top);
    (Parent as TForm).Canvas.LineTo(Msg.XPos+Left, Msg.YPos+Top);
    OX := Msg.XPos; OY := Msg.YPos;

    // Поиск элемента для соединения
    For i := 0 to (Parent as TForm).ComponentCount-1 do
    begin
      If ((Parent as TForm).Components[i] is TLogElement) then
        ConnectToLE := ((Parent as TForm).Components[i] as TLogElement);

      If (ConnectToLE <> Self) and (ConnectToLE <> nil) then
      If InClem(ConnectToLE.Width, ConnectToLE.Height, (Msg.XPos-(ConnectToLE.Left-Left)),
        (Msg.YPos-(ConnectToLE.Top-Top)), ConnectToRect, ConnectToIO) then
      begin
        If not ConnectToIOHL then
        begin
          ConnectToIOHL := True;
          ConnectToLE.Canvas.Brush.Color := clBlack;
          ConnectToLE.Canvas.Rectangle(ConnectToRect);
          ConnectToLE.Canvas.Brush.Color := clWhite;

          Cursor := crHandPoint;
        end;
      end else
      If ConnectToIOHL then
      begin
        ConnectToIOHL := False;
        ConnectToLE.Canvas.Rectangle(ConnectToRect);
        Cursor := crDefault;
      end;
    end;
  end;
end;

procedure TLogElement.LogMouseUp(var Msg: TWMLButtonUp);
var
  DoConnect : Boolean;
  ConnectToIn : TLogIn;
  i : Integer;
begin
  inherited;

  If Created then
  begin
    Created := False;
    If Top < 85 then Free;
  end;

  If Connecting then
  begin
    // Присоединение элемента
    DoConnect := False; ConnectToIn := nil;
    begin
      Connecting := False;

      For i := 0 to (Parent as TForm).ComponentCount-1 do
      begin
        If ((Parent as TForm).Components[i] is TLogElement) then
          ConnectToLE := ((Parent as TForm).Components[i] as TLogElement);

        If ConnectToLE <> Self then
        If InClem(ConnectToLE.Width, ConnectToLE.Height, (Msg.XPos-(ConnectToLE.Left-Left)),
          (Msg.YPos-(ConnectToLE.Top-Top)), ConnectToRect, ConnectToIO) then
        begin
          DoConnect := True;
          break;
        end;
      end;
    end;

    (Parent as TForm).Canvas.MoveTo(CX+Left, CY+Top);
    (Parent as TForm).Canvas.Pen.Mode := pmNotXor;
    (Parent as TForm).Canvas.LineTo(OX+Left, OY+Top);

    If not DoConnect then
    begin
      ConnectToLE := nil;
      i := 0;
      While i <= 5 do
      begin
        If LogIns[i] <> nil then
          If (LogIns[i].Left-10<=Msg.XPos+Left) and (Msg.XPos+Left<=LogIns[i].Left+LogIns[i].Width+10) and
            (LogIns[i].Visible) then
        begin
          ConnectToIn := LogIns[i];
          DoConnect := True;
          break;
        end;
        Inc(i);
      end;
    end;

    If DoConnect then
    begin
      OX := (ConnectRect.Left+ConnectRect.Right) div 2;
      OY := (ConnectRect.Top+ConnectRect.Bottom) div 2;

      Canvas.Brush.Color := clWhite;
      Canvas.Rectangle(ConnectRect);
      If ConnectToLE <> nil then
      begin
        ConnectToLE.Canvas.Rectangle(ConnectToRect);

        Connect(ConnectToLE);
      end else
      If ConnectToIn <> nil then
      begin
        ConnectToIO := ioOutput;
        Connect(ConnectToIn);
      end;
    end;
  end else
  begin
    If Input1C <> nil then Input1C.Check;
    If Input2C <> nil then Input2C.Check;
    If OutputC <> nil then OutputC.Check;

    PostMessage((Parent as TForm).Handle, LM_DRAWCONNECTORS, 0, 0);
  end;
end;

procedure TLogElement.LogRightMouseDown(var Msg: TWMRButtonDown);
begin
  inherited;

  PopupElem := Self;
end;

procedure TLogElement.Paint;
begin
  inherited;

  With Canvas do
  begin
    Brush.Color := clWhite;
    Rectangle(19, 0, Width-19, Height); // Главный прямоугольник

    Rectangle(10, 10, 20, 20); // Input1
    If FLogElementOp<>loNot then Rectangle(10, Height-20, 20, Height-10); //Input2
    Rectangle(Width-20, (Height div 2)-5, Width-10, (Height div 2)+5); // Output

    Font.Size := 10;
    Font.Style := [fsBold];

    Case FLogElementOp of
      loAnd : TextOut(Width div 2, Height div 6, '&');
      loOr  : TextOut(Width div 2, Height div 6, '1');
    end;
//    TextOut(25, 5, IntToStr(NumbId));
  end;
end;

procedure TLogElement.SetLogOp(Value: TLogElementOp);
begin
  FLogElementOp := Value;
  Case FLogElementOp of
    loOr, loAnd : Height := 50;
    loNot : Height := 30;
    else begin end;
  end;
  Repaint;
end;

{ TLogConnect }

procedure TLogConnect.Check;
begin
  // Проверка и перерисовка логического элемента
  If (LE1 <> nil) and (LE2 <> nil) then
  If (LE1 is TLogElement) and (LE2 is TLogElement) then
  begin
    If ((LE1.GetCoordsIO(LE1IO).Y+LE1.Top > LE2.GetCoordsIO(LE2IO).Y+LE2.Top) and
      (LE1.GetCoordsIO(LE1IO).X+LE1.Left < LE2.GetCoordsIO(LE2IO).X+LE2.Left)) or
      ((LE1.GetCoordsIO(LE1IO).Y+LE1.Top < LE2.GetCoordsIO(LE2IO).Y+LE2.Top) and
      (LE1.GetCoordsIO(LE1IO).X+LE1.Left > LE2.GetCoordsIO(LE2IO).X+LE2.Left)) then
        Slash := True else Slash := False;

    If LE1.GetCoordsIO(LE1IO).X+LE1.Left < LE2.GetCoordsIO(LE2IO).X+LE2.Left then
      Left := LE1.GetCoordsIO(LE1IO).X+LE1.Left else
      Left := LE2.GetCoordsIO(LE2IO).X+LE2.Left;

    Width := abs(LE2.GetCoordsIO(LE2IO).X+LE2.Left-LE1.GetCoordsIO(LE1IO).X-LE1.Left);

    If LE1.GetCoordsIO(LE1IO).Y+LE1.Top < LE2.GetCoordsIO(LE2IO).Y+LE2.Top then
      Top := LE1.GetCoordsIO(LE1IO).Y+LE1.Top else
      Top := LE2.GetCoordsIO(LE2IO).Y+LE2.Top;

    Height := abs(LE1.GetCoordsIO(LE1IO).Y+LE1.Top-LE2.GetCoordsIO(LE2IO).Y-LE2.Top);
  end else
  begin
    begin
      If LE1.GetCoordsIO(LE1IO).X+LE1.Left < LE2.Left then
        Left := LE1.GetCoordsIO(LE1IO).X+LE1.Left else Left := LE2.Left;

      Width := abs(LE1.GetCoordsIO(LE1IO).X+LE1.Left-LE2.Left);

      Top := LE1.GetCoordsIO(LE1IO).Y+LE1.Top;
    end;
    Height := 2;
  end;
end;

constructor TLogConnect.Create;
begin
  inherited;

  Color := clBlack;
  ConnectorList.Add(Self);
end;

destructor TLogConnect.Destroy;
var
  ListIndex : Integer;
begin
  // Проверка остальных соединений перед удалением
  If LE1 <> nil then
  If (LE1 is TLogElement) then
  Case LE1IO of
    ioInput1 : (LE1 as TLogElement).Input1C := nil;
    ioInput2 : (LE1 as TLogElement).Input2C := nil;
    ioOutput : (LE1 as TLogElement).OutputC := nil;
  end;
  If LE2 <> nil then
  If (LE2 is TLogElement) then
  Case LE2IO of
    ioInput1 : (LE2 as TLogElement).Input1C := nil;
    ioInput2 : (LE2 as TLogElement).Input2C := nil;
    ioOutput : (LE2 as TLogElement).OutputC := nil;
  end;

  ListIndex := ConnectorList.IndexOf(Self);
  If ListIndex<>-1 then
    ConnectorList.Delete(ListIndex);

  inherited;
end;

procedure TLogConnect.Paint(PaintTo : TComponent);
var
  Can : TCanvas;
begin
  // Прорисовка соединения на указанном компоненте

  inherited;

  Can := nil;
  If PaintTo is TForm then Can := (PaintTo as TForm).Canvas else
    If PaintTo is TImage then Can := (PaintTo as TImage).Canvas;

  With Can do
  begin
    Pen.Color := Color;

    Pen.Mode := pmCopy;//pmNotXor;
    Pen.Width := 2;
    If Height > 2 then
    begin
      If Slash then
      begin
        MoveTo(Left+0, Top+Height);
        LineTo(Left+Width, Top+0);
      end else
      begin
        MoveTo(Left+0, Top+0);
        LineTo(Left+Width, Top+Height);
      end;
    end else
    begin
      MoveTo(Left+0, Top+0);
      LineTo(Left+Width, Top+0);
    end;

    If (LE2 is TLogIn) then
    begin
      Pen.Mode := pmCopy;
      Brush.Color := clBlack;
      Ellipse(Left-3, Top-4, Left+5, Top+4);
      Brush.Color := clBtnFace;
    end;
  end;
end;

initialization
  ConnectorList := TList.Create;
finalization
  ConnectorList.Free;  

end.
