unit LogIn;

// Описание элемента - логического входа
//

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Graphics, LogEntry, Forms;

type
  TLogIn = class(TLogEntry)
  private
  protected
  public
    InId : Char;
    InValue : Boolean;
    procedure Paint; override;
    procedure Check;
    function Evaluate : Boolean; override;
    function GetLogUr : String; override;
    constructor Create(AOwner : TComponent); override;
  published
  end;

procedure Register;

implementation

uses LogFuncElem;

procedure Register;
begin
  RegisterComponents('Logica', [TLogIn]);
end;

{ TLogIn }

procedure TLogIn.Check;
begin
  Height := (Owner as TWinControl).Height-Top-100;
end;

constructor TLogIn.Create(AOwner: TComponent);
begin
  inherited;

  Left := 10;
  Top := 10;
  Height := 100;
  Width := 2;

  InId := 'A';
  InValue := False;
end;

function TLogIn.Evaluate: Boolean;
begin
  Result := InValue;
end;

function TLogIn.GetLogUr: String;
begin
  Result := InId;
end;

procedure TLogIn.Paint;
begin
  inherited;

  Canvas.Brush.Color := clBlack;
  (Parent as TForm).Canvas.Font.Size := 10;
  (Parent as TForm).Canvas.Font.Style := [fsBold];
  (Parent as TForm).Canvas.TextOut(Left-3, Top, InId);
  Canvas.FillRect(Bounds(0, 30, Width, Height-30));
end;

end.
