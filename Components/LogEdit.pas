// ќписание редактора дл€ записи логической функции (дочерний от TEdit)
// јвтоматически замен€ет символы
// "*", "&" на "Х" - знак дизъюнкции
// "|" на "+"  - знак конъюнкции
// "-" на "ђ" - логическое отрицание
// “акже имеет ограничение на вводимые символы -
// можно вводить лишь :
// 1) ќбозначени€ логической функции - X, Y, Z
// 2) «наки логических функций, скобки
// 3) ќбозначени€ переменных - A, B, C, D, E, F

unit LogEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, StdCtrls, Forms, Buttons;

type
  TLogEdit = class(TEdit)
  private
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
  protected
  public
    SetFocusTo : TBitBtn;
    constructor Create(AOwner : TComponent); override;
  published
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Logica', [TLogEdit]);
end;

{ TLogEdit }

constructor TLogEdit.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TLogEdit.WMChar(var Message : TWMChar);
var
  Cut : Boolean;
begin
  // ђХ
  Cut := False;
  Case Chr(Message.CharCode) of
    '-' : Message.CharCode := Ord('ђ');
    '*', '&' : Message.CharCode := Ord('Х');
    '|' : Message.CharCode := Ord('+');
    '[' : Message.CharCode := Ord('(');
    ']' : Message.CharCode := Ord(')');
    'A'..'G', 'X'..'Z', ' ', '=', #8, '+', '(', ')', '>' : begin end;
    'a'..'g', 'x'..'z' : Dec(Message.CharCode, 32);
    #13 :
      begin
//        SetFocusTo.SetFocus;
        If SetFocusTo <> nil then SetFocusTo.Click;
        Cut := True;
      end;
    else Cut := True;
  end;
  If not Cut then inherited;
end;

end.
