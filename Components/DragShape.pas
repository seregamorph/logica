unit DragShape;

// Описание "таскаемого" LogEntry

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, ExtCtrls, Forms, LogEntry;

type
  TDragShape = class(TLogEntry)

  private
    XOffset, YOffset : Integer;
    SRect, FocusRect : TRect;

    procedure LogMouseDown(var Msg : TWMMouse); message WM_LBUTTONDOWN;
    procedure LogMouseMove(var Msg : TWMMouseMove); message WM_MOUSEMOVE;
    procedure LogMouseUp  (var Msg : TWMMouse); message WM_LBUTTONUP;

  protected
  public
    Dragging : Boolean;
    DragRect, OffRect : TRect;
    constructor Create(AOwner : TComponent); override;
  published

  end;

function PointInRect(Rect : TRect; X, Y : Integer) : Boolean;
procedure Register;

implementation

function PointInRect(Rect : TRect; X, Y : Integer) : Boolean;
begin
  Result := (Rect.Left < X) and (X < Rect.Right) and
    (Rect.Top < Y) and (Y < Rect.Bottom);
end;

procedure Register;
begin
  RegisterComponents('Logica', [TDragShape]);
end;

{ TDragShape }

constructor TDragShape.Create(AOwner: TComponent);
begin
  inherited;

  Dragging := False;

  OffRect := Bounds(0, 0, 0, 0);
  DragRect := Bounds(0, 0, 0, 0);
end;

procedure TDragShape.LogMouseDown(var Msg : TWMMouse);
begin
  inherited;

  If ((DragRect.Left=0) and (DragRect.Top=0) and (DragRect.Right=0) and
    (DragRect.Bottom=0)) then DragRect := Bounds(0, 0, Width, Height);

  If (PointInRect(DragRect, Msg.XPos, Msg.YPos) and
    (not (PointInRect(OffRect, Msg.XPos, Msg.YPos)))) then
  begin
    Dragging := True;
    XOffset := Msg.XPos;
    YOffset := Msg.YPos;
    SRect := Bounds(Left, Top, Width, Height);
    FocusRect := Rect(Left, Top, Left + Width, Top + Height);
//    (Owner as TForm).Canvas.DrawFocusRect(FocusRect);
  end;
end;

procedure TDragShape.LogMouseMove(var Msg : TWMMouseMove);
begin
  inherited;

  if Dragging then
  begin
    (Owner as TForm).Canvas.DrawFocusRect(FocusRect);
    with FocusRect do
    begin
      Left := (SRect.Left + Msg.XPos) - XOffset;
      Top := (SRect.Top + Msg.YPos) - YOffset;
      Right := Width + Left;
      Bottom := Height + Top;
    end;
    (Owner as TForm).Canvas.DrawFocusRect(FocusRect);

//    Left := (Left + Msg.XPos) - XOffset;
//    Top := (Top + Msg.YPos) - YOffset;
  end;

{  Msg.XPos := Msg.XPos+Left;
  Msg.YPos := Msg.YPos+Top;
  ParMsg := TMessage(Msg);
  PostMessage(Parent.Handle, WM_MOUSEMOVE, ParMsg.WParam, ParMsg.LParam);}
end;

procedure TDragShape.LogMouseUp(var Msg : TWMMouse);
var
  NL, NT : Integer;
begin
  inherited;

  if Dragging then
  begin
    Dragging := False;

    NL := (Left + Msg.XPos) - XOffset;
    NT := (Top + Msg.YPos) - YOffset;

    If NL < 50 then NL := 50;
    If NT < 50 then NT := 50;
    If NL > (Parent as TWinControl).Width-Width-25 then
      NL := (Parent as TWinControl).Width-Width-25;
    If NT > (Parent as TWinControl).Height-Height-100 then
      NT := (Parent as TWinControl).Height-Height-100;

    {If (NL+Width<0) or (NT+Height<0) or (Left>(Parent as TWinControl).Width) or
      (Top>(Parent as TWinControl).Height) then
    begin
      If MessageBox((Parent as TWinControl).Handle, 'Удалить элемент ?', 'Логика', mb_YesNo or
        MB_ICONQUESTION)=idYes then Self.Destroy else
      begin
        Left := NL;
        Top  := NT;
      end;
    end else}
    begin
      Left := NL;
      Top  := NT;
    end;
  end;
end;

end.
