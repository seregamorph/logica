unit LogMemo;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, StdCtrls;

type
  TLogMemo = class(TMemo)
  private
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
  protected
  public
  published
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Logica', [TLogMemo]);
end;

procedure TLogMemo.WMChar(var Message : TWMChar);
var
  Cut : Boolean;
begin
  // ¬•
  Cut := False;
  Case Chr(Message.CharCode) of
    '-' : Message.CharCode := Ord('¬');
    '*' : Message.CharCode := Ord('•');
    'A'..'G', 'X'..'Z', ' ', '=', #8, '+', '(', ')' : begin end;
    'a'..'g', 'x'..'z' : Dec(Message.CharCode, 32);
    else Cut := True;
  end;
  If not Cut then inherited;
end;

end.
