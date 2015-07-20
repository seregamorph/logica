unit LogFuncElem;

// Элемент - "логическая функция"

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, DragShape, LogElement, LogEntry;

type
  TLogFuncElem = class(TLogElement)
  private
  protected
  public
    function Evaluate : Boolean; override;
    function GetLogUr : String; override;
    constructor Create(AOwner : TComponent); override;
    procedure Paint; override;
  published
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Logica', [TLogFuncElem]);
end;

{ TLogFuncElem }

constructor TLogFuncElem.Create(AOwner: TComponent);
begin
  inherited;

  Height := 30;
  Width  := 30;

  DragRect := Bounds(0, 0, Width, Height);
  OffRect  := Bounds((Width div 2)-5, (Height div 2)-5, 10, 10);

  LogElementOp := loNot;
end;

function TLogFuncElem.Evaluate: Boolean;
begin
  Result := False;
  If Input1C <> nil then // Определение операнда
  begin
    If Input1C.LE1<>Self then Result := Input1C.LE1.Evaluate else
      Result := Input1C.LE2.Evaluate;
  end;
end;

function TLogFuncElem.GetLogUr: String;
begin
  // Рекурсивное составление логического уравнения
  Result := 'X=';
  If Input1C<>nil then
  If Input1C.LE1<>nil then
  If Input1C.LE1=Self then Result := Result+Input1C.LE2.GetLogUr else
    Result := Result+Input1C.LE1.GetLogUr;
end;

procedure TLogFuncElem.Paint;
begin
  Canvas.Ellipse(0, 0, Width, Height);
end;

end.
