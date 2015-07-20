// Базовый компонент для логических элементов,
// логических "входов" и функционального элемента
// Определяет основные типы данных и функции
// 1) Evaluate - рекурсивный расчет функции
// 2) GetLogUr - рекурсивное получение логического уравнения
// 3) GetCoordsIO - получение координат входа/выхода по
// его идентификатору

unit LogEntry;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls;

type
  TLogElementOp = (loNone, loOr, loAnd, loNot, loImplic, loEcviv);
const
  LogElementOpArr : array[0..3] of TLogElementOp = (loNone, loOr, loAnd, loNot);
type
  TIO = (ioInput1, ioInput2, ioOutput);
  TCoords = record
    X, Y : Integer;
  end;

  TLogEntry = class(TGraphicControl)
  private
  protected
  public
    NumbId                 : Integer;
    function Evaluate : Boolean; virtual;
    function GetLogUr : String; virtual;
    function GetCoordsIO(IO: TIO): TCoords;
  published
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Logica', [TLogEntry]);
end;

{ TLogEntry }

function TLogEntry.Evaluate: Boolean;
begin
  Result := False;
end;

function TLogEntry.GetCoordsIO(IO: TIO): TCoords;
var
  X, Y : Integer;
begin
  Case IO of
    ioInput1 :
      begin
        X := 15;
        Y := 15;
      end;
    ioInput2 :
      begin
        X := 15;
        Y := (Height-20)+5;
      end;
    else
      begin
        X := (Width-20)+5;
        Y := ((Height div 2)-5)+5;
      end;
  end;
  Result.X := X;
  Result.Y := Y;
end;

function TLogEntry.GetLogUr: String;
begin
  Result := '';
end;

end.
