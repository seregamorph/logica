unit DragPanel;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, ExtCtrls, Forms;

type
  TDragPanel = class(TPanel)

  private
    Dragging : Boolean;
    XOffset, YOffset : Integer;
    SRect, FocusRect : TRect;

    procedure LogMouseDown(var Msg : TWMMouse); message WM_LBUTTONDOWN;
    procedure LogMouseMove(var Msg : TWMMouseMove); message WM_MOUSEMOVE;
    procedure LogMouseUp  (var Msg : TWMMouse); message WM_LBUTTONUP;

  protected
  public
    constructor Create(AOwner : TComponent); override;
    procedure Paint; override;
  published
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Logica', [TDragPanel]);
end;

{ TDragShape }

constructor TDragPanel.Create(AOwner: TComponent);
begin
  inherited;

  Dragging := False;
end;

procedure TDragPanel.LogMouseDown(var Msg : TWMMouse);
begin
  inherited;

  Dragging := True;
  XOffset := Msg.XPos;
  YOffset := Msg.YPos;
  SRect := Bounds(Left, Top, Width, Height);
  FocusRect := Rect(Left, Top, Left + Width, Top + Height);
//  (Owner as TForm).Canvas.DrawFocusRect(FocusRect);
end;

procedure TDragPanel.LogMouseMove(var Msg : TWMMouseMove);
begin
  inherited;

  if Dragging then
  begin
{    (Owner as TForm).Canvas.DrawFocusRect(FocusRect);
    with FocusRect do
    begin
      Left := (SRect.Left + Msg.XPos) - XOffset;
      Top := (SRect.Top + Msg.YPos) - YOffset;
      Right := Width + Left;
      Bottom := Height + Top;
    end;
    (Owner as TForm).Canvas.DrawFocusRect(FocusRect);}

    Left := (Left + Msg.XPos) - XOffset;
    Top := (Top + Msg.YPos) - YOffset;

  end;
end;

procedure TDragPanel.LogMouseUp(var Msg : TWMMouse);
begin
  inherited;

  if Dragging then
  begin
    Dragging := False;

    Left := (Left + Msg.XPos) - XOffset;
    Top := (Top + Msg.YPos) - YOffset;

    If (Left=SRect.Left) and (Top=SRect.Top) then Paint;
  end;
end;

procedure TDragPanel.Paint;
begin
  inherited;
end;

end.
