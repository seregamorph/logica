unit FuncUn;

interface

uses
  Windows, Messages, SysUtils, Classes, LogEntry;

type
  PLogOper = ^TLogOper;
  TLogOper = record
    ParLOper : PLogOper;
    i1, i2 : PLogOper;
    lo : TLogElementOp;
    c1, c2 : String[1];
  end;
  TInputsArr = array[1..6] of Boolean;
                                          
var
  LOList : TList;

function GetPos(Str : String; Ch : String) : Integer;  
function DivFunc(WorkStr : String) : Boolean;
function GetLogUr : String;
function EvaluateFunc(Inputs : TInputsArr) : Boolean;

implementation

uses TTUn, MainUn;

function GetPos(Str : String; Ch : String) : Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 1 to Length(Str) do
    if Str[i]=Ch then
  begin
    Result := i;
    Exit;
  end;
end;

function CopyB(Str : String; divi : Integer) : String;
// ���������� ����� �� ������ � �� divi
var
  i, uv : Integer;
  Ok : Boolean;
begin
  Result := ''; Ok := True; uv := 0;
  if (divi<1) or (divi>Length(Str)) then Exit;
  i := divi;
  while (i>0) and Ok do
  begin
    if Str[i]='(' then Inc(uv);
    if Str[i]=')' then Dec(uv);
    if uv>0 then Ok := False else
      Result := Str[i] + Result;
    Dec(i);
  end;
end;

function CopyE(Str : String; divi : Integer) : String;
// ���������� ����� �� divi � �� �����
var
  i, uv : Integer;
  Ok : Boolean;
begin
  Result := ''; Ok := True; uv := 0;
  if (divi<1) or (divi>Length(Str)) then Exit;
  i := divi;
  while (i<=Length(Str)) and Ok do
  begin
    if Str[i]='(' then Inc(uv);
    if Str[i]=')' then Dec(uv);
    if uv<0 then Ok := False else
      Result := Result + Str[i];
    Inc(i);
  end;
end;

// "�������" ���������� ������� �� ��������� �����
//             X = �A+B*C // + -> � -> �
//                   |
//                   +
//                 /   \
//               (�A) (B*C)
//                |     |
//                �     *
//                |    / \
//                A   B   C
//
// ���������� "��������� ������"
// ������� ������������� "� �����", �. �. ������� ������������ ��������, �������
// ����� ����������� � ����� �����, ������� ����������� �� ��������� �����. ����
// ��������� ���� - ����������, ���������� �� � C1 (C2), ����� ������������
// ����������� ������ ������� �� ��������� �� ����������
// ����� ������� ���������� ������, ����� �������� - ��� ���������� ��������,
// ��� ����������
// ���������� ������� � LogIns

function DivFunc(WorkStr : String) : Boolean;
  function GetVal(C : Char) : Integer;
  begin
    case C of
      '=' : Result := 5;
      '+' : Result := 4;
      '>' : Result := 3;
      '�' : Result := 2;
      '�' : Result := 1;
      else Result := 0;
    end;
  end;
var
  i, rp : Integer;

  function Recurse(Str : String; ParNode : PLogOper; uv : Integer; var
    err : Boolean) : PLogOper;
  var
    i, suv, suvmin, uvo, uvc, maxval, maxvaln, val, divi : Integer;
    LOper : PLogOper;
    i1Str, i2Str : String[250];
    rerr : Boolean;
  begin
    err := False;
    LOper := nil;
    suv := uv; suvmin := 0; uvc := 0; uvo := 0;
    maxval := 0; maxvaln := 0;
    for i := 1 to Length(Str) do
    begin
      if Str[i]='(' then Inc(suv); // ������� ������ ����������� ������
      if Str[i]=')' then Dec(suv); //
      Case Str[i] of
        '�', '�', '+', '>', '=' :
          begin
            if (suvmin=0) or (suv < suvmin) then
            begin
              suvmin := suv; // ��� ������� ������ ����������� ����
              uvc := 1;      // �������� ���������� ����������
              uvo := i;      // �. �. ������� ����� ����������� ���������

              maxval := GetVal(Str[i]);
              maxvaln := i;
            end else if suv=suvmin then
            begin
              Inc(uvc);

              // + -> � -> �
              // 3    2    1

              Val := GetVal(Str[i]);

              if val>maxval then
              begin
                maxval := val;
                maxvaln := i;
              end;
            end;
          end;
      end;
    end;

    if maxvaln=0 then maxvaln := uvo; // ����� �������� ���������� ����������
    divi := maxvaln;                  // � ����� �������

    if (uvc<>0) or ((uv=1) and (uvc=0)) then
    begin
      LOper := New(PLogOper);

      with LOper^ do
      begin
        ParLOper := ParNode;

        if divi=0 then lo := loNone else
        case Str[divi] of // ���������� ���������� ��������
          '+' : lo := loOr;
          '�' : lo := loAnd;
          '�' : lo := loNot;
          '>' : lo := loImplic;
          '=' : lo := loEcviv;
          else lo := loNone;
        end;

        if ((lo = loNot) or (lo = loNone)) then
        begin
          i1Str := CopyE(Str, divi+1); // ��������� ��������� �������
          i2Str := '';                 // ����� ����� ��������
        end else
        begin
          i1Str := CopyB(Str, divi-1); // ��������� ��������� ������� �� �
          i2Str := CopyE(Str, divi+1); // ����� ����� ��������
        end;

        {if lo = loImplic then
        begin
          // A>B -> (�A)+B
          Result := Recurse( '(�'+i1Str+')+'+i2Str, ParNode, uv, err);
          Exit;
        end else
        if lo = loEcviv then
        begin
          // A=B -> (�A��B) + (A�B)
          Result := Recurse( '(�'+i1Str+'��'+i2Str+')+('+i1Str+'�'+i2Str+')',
            ParNode, uv, err);
          Exit;
        end else}
        begin
          rerr := False;
          if Length(i1Str)>1 then
          begin
            i1 := Recurse(i1Str, LOper, uv+1, rerr); // ����������� ������ ������...
            if rerr then Err := True;
          end else
          begin
            i1 := nil; // .. ��� ��� ����������
            if ('A'<=i1Str) and (i1Str<=Chr(Ord('A')+InputCount-1)) then
              c1 := i1Str else Err := True;
          end;
          if (not rerr) and (lo <> loNot) and (lo <> loNone) then
          begin
            if Length(i2Str)>1 then
            begin
              i2 := Recurse(i2Str, LOper, uv+1, rerr); // ����������� ������ ������...
              if rerr then Err := True;
            end else
            begin
              i2 := nil; // .. ��� ��� ����������
              if ('A'<=i2Str) and (i2Str<=Chr(Ord('A')+InputCount-1)) then
                c2 := i2Str else Err := True;
            end;
          end;
        end;
        LOList.Add(LOper);
      end;
    end;
    Result := LOper;
  end;
begin
  Result := False;
  i := 1; rp := 0;
  while (i<=Length(WorkStr)) do // �������� ������ ��������
  begin
    if (WorkStr[i]='=') then if rp=0 then rp := i;
    if (WorkStr[i]=' ') then Delete(WorkStr, i, 1) else Inc(i);
  end;

  WorkStr := Copy(WorkStr, rp+1, Length(WorkStr)-rp+1);

  Recurse(WorkStr, nil, 1, Result);
  Result := not Result;

  if (not Result) then MessageBox(TTForm.Handle, PChar('������ ������� ������� !'#13+
    'X='+WorkStr), '������� ����������', mb_Ok or MB_ICONERROR);
end;

// ����������� ������ �������� ������� � ����������� �� ������� ������
// �� "������", ������������� DivFunc
//
function EvaluateFunc(Inputs : TInputsArr) : Boolean;
var
  Err : Boolean;

  function GetInput(Str : String) : Boolean;
  begin
    if ('A'<=Str) and (Str<'F') then Result :=
      Inputs[ Ord(Str[1])-Ord('A')+1 ] else
    begin
      Result := False;
      Err := True;
    end;
  end;
  function Recurse(Node : PLogOper) : Boolean;
  var
    O1, O2 : Boolean;
  begin
    if Node^.i1 = nil then O1 := GetInput(Node^.C1) else
      O1 := Recurse(Node^.i1);

    if ((Node^.lo = loNot) or (Node^.lo = loNone)) then O2 := False else
      if Node^.i2 = nil then O2 := GetInput(Node^.C2) else
        O2 := Recurse(Node^.i2);

    case Node^.lo of
      loAnd     : Result := O1 and O2;    // �
      loOr      : Result := O1 or  O2;    // +
      loNot     : Result := not O1;       // �
      loImplic  : Result := not O1 or O2; // ->
      loEcviv   : Result := O1=O2;        // <=>
      else Result := O1;
    end;
  end;
begin
  Err := False;
  Result := False;
  if LOList.Count > 0 then
  begin
    Result := Recurse(LOList.Last);
  end;
  if Err then MessageBox(TTForm.Handle, '������ ������� ������� !',
    '������� ����������', mb_Ok or MB_ICONERROR);
end;

// ����������� ����������� ����������� ��������
// �� "������", ������������� DivFunc
function GetLogUr : String;
  function Recurse(Node : PLogOper) : String;
  begin
    Result := '';
    if Node^.i1 = nil then
      Result := '('+Node^.c1 else Result := '('+Recurse(Node^.i1);
    if Result <> '' then
    Case Node^.lo of
      loAnd : Result := Result + '�';
      loOr  : Result := Result + '+';
      else Result := Result + '�';
    end;
    if Node^.lo<>loNot then
    begin
      if Node^.i2 = nil then
        Result := Result+Node^.c2+')' else Result := Result+Recurse(Node^.i2)+')';
    end else
    begin
      if Node^.i1 = nil then
        Result := Result+Node^.c1+')' else Result := Result+Recurse(Node^.i1)+')';
    end;
  end;
begin
  if LOList.Count > 0 then
    Result := 'X='+Recurse(LOList.Last);
end;

end.



