unit SNFUn;

interface

uses Windows, SysUtils;
                       
const
  MaxInputCount  = 6;
  MaxOutputCount = 1;
  MaxColCount    = MaxInputCount+MaxOutputCount;
  MaxRowCount    = 64;

type
  TIOArr = array [0..MaxColCount-1, 0..MaxRowCount] of Boolean;

  TNaborElement = (neFalse, neTrue, neNone); // 0, 1, -
  TNabor = record
    Element : array[0..MaxInputCount-1] of TNaborElement; // �����
    Cut : Boolean;
  end;
  TJarus = record
    NaborCount : Integer; // ����� �������
    Nabor : array[1..100*MaxInputCount] of  TNabor;
  end;
  TBiNabor = array[0..MaxInputCount] of TJarus; // �������� ����� ������
                                    // ������ ������� - ����� ������

function GetSDNF(IOArr : TIOArr) : String;
function GetSCNF(IOArr : TIOArr) : String;
function GetMDNF(IOArr : TIOArr) : String;

implementation

uses TTUn, MainUn;

// ������� ��������� ���� - ����������� ������������� ���������� �����
// ���������� ������� �� ������ ������ - ����������
// ����� ������� �� ������� ����� :
// 1) ���������� ������, �� ������� ������� �������, � ���� ��������
//  ������������ -> � BiNabor
// 2) ���������� �������� ����������� �� ������ � �������� ������� ������� �
//  �������� ������, ������� ������������ ��������� �� ��� ���, ���� ���
//  ��������; �������� ������ �����, ������������� � �������. �����������
//  ������ �� ������ ��� ���������, �������� � ������� ����������� � ��������
//  ������ ������� : 001    001-     -01-
//                   000    101-     -11-
// 3) ���������� ������������� �������
// 4) ����������� ������� � ���� ��������� ������
// 5) ����������� ������� � ��������� ����

function GetMDNF(IOArr : TIOArr) : String;
  function GetNE(InputBool : Boolean) : TNaborElement;
  begin
    If InputBool then Result := neTrue else
      Result := neFalse;
  end;
  function GetStrNE(InputNE : TNaborElement) : String;
  begin
    If InputNE=neTrue  then Result := '1' else
    If InputNE=neFalse then Result := '0' else
      Result := '-';
  end;
var
  C, R, TC, ji, dji, t, ni, ni1, ni2, cdn, nei, nedi : Integer;
    // ����� ����� � ������� 1-�� � 2-�� �����
  ne : Integer;  // ����� ������ (��� ������)
  TStr : String;
  Null : Boolean;
  BiNabor, BiNabor2 : TBiNabor;
  Ok, dOk : Boolean;
begin
  Null := True;
  FillChar(BiNabor, SizeOf(BiNabor), 0);
  FillChar(BiNabor2, SizeOf(BiNabor2), 0);

  With TTForm do
  begin
    For R := 0 to RowCount-1 do // ���������� ��������� ������
    begin
      If IOArr[InputCount, R] then // ������� �������
      begin
        Null := False;
        TC := 0; // ��������� �������� �����
        For C := 0 to InputCount-1 do
          If IOArr[C, R] then Inc(TC);

        Inc(BiNabor[TC].NaborCount);
        For C := 0 to InputCount-1 do
          BiNabor[TC].Nabor[BiNabor[TC].NaborCount].Element[C] :=
          GetNE(IOArr[C, R]);
      end;
    end;
    repeat
      Ok := True;
      ji := 0;
//      For ji := 0 to InputCount-1 do // ����� ������ = InputCount+1
      While ji <= InputCount-1 do
      begin
        ni1 := 1;
//        For ni1 := 1 to BiNabor[ji].NaborCount do
        While ni1 <= BiNabor[ji].NaborCount do
        begin
          ni2 := 1;
//          For ni2 := 1 to BiNabor[ji+1].NaborCount do
          While ni2 <= BiNabor[ji+1].NaborCount do
          begin
            cdn := 0; nedi := 0;
            nei := 0;
//            For nei := 0 to InputCount-1 do
            While nei <= InputCount-1 do
            begin
              if BiNabor[ji].Nabor[ni1].Element[nei] <>
                 BiNabor[ji+1].Nabor[ni2].Element[nei] then
              begin
                Inc(cdn);
                nedi := nei;
              end;
              Inc(nei);
            end;
            If cdn=1 then // ���� ���� �������� -> ����������
            If ((BiNabor[ji].Nabor[ni1].Element[nedi]=neFalse) and
                  (BiNabor[ji+1].Nabor[ni2].Element[nedi]=neTrue)) or
                 ((BiNabor[ji].Nabor[ni1].Element[nedi]=neTrue) and
                  (BiNabor[ji+1].Nabor[ni2].Element[nedi]=neFalse)) then
            begin
              Ok := False;
              Inc(BiNabor2[ji].NaborCount);
              For nei := 0 to InputCount-1 do
                BiNabor2[ji].Nabor[BiNabor2[ji].NaborCount].Element[nei] :=
                BiNabor[ji].Nabor[ni1].Element[nei];
              BiNabor2[ji].Nabor[BiNabor2[ji].NaborCount].Element[nedi] := neNone;

              BiNabor[ji].Nabor[ni1].Cut := True;
              BiNabor[ji+1].Nabor[ni2].Cut := True;
            end;
            Inc(ni2);
          end;
          Inc(ni1);
        end;
        Inc(ji);
      end;

      If not Ok then
      begin
        For ji := 0 to InputCount do // ���������� �� ��������� �������
        begin
          For ni := 1 to BiNabor[ji].NaborCount do
          If not BiNabor[ji].Nabor[ni].Cut then
          begin
            Inc(BiNabor2[ji].NaborCount);
            For nei := 0 to InputCount-1 do
              BiNabor2[ji].Nabor[BiNabor2[ji].NaborCount].Element[nei] :=
              BiNabor[ji].Nabor[ni].Element[nei];
          end;
        end;

        For dji := 0 to InputCount do // ���������� ������������� �������
        begin
          ni1 := 1;
//        For ni1 := 1 to BiNabor2[dji].NaborCount-1 do
          While ni1 <= BiNabor2[dji].NaborCount-1 do
          begin
            ni2 := ni1+1;
//          For ni2 := ni1+1 to BiNabor2[dji].NaborCount do
            While ni2 <= BiNabor2[dji].NaborCount do
            begin
              dOk := False;
              For nei := 0 to InputCount-1 do
                If BiNabor2[dji].Nabor[ni1].Element[nei] <>
                  BiNabor2[dji].Nabor[ni2].Element[nei] then dOk := True;
              If not dOk then
              begin
                // ������� �� ni2 �� �����
                For ni := ni2 to BiNabor2[dji].NaborCount-1 do
                For nei := 0 to InputCount-1 do
                  BiNabor2[dji].Nabor[ni].Element[nei] :=
                  BiNabor2[dji].Nabor[ni+1].Element[nei];
                Dec(BiNabor2[dji].NaborCount);

                Dec(ni2);
              end;
              Inc(ni2);
            end;
            Inc(ni1);
          end;
        end;

        TStr := 'X = '; // ����������� �������������� ����������, �������������
                        // � LogUrMemo
        For t := 0 to InputCount do
        begin
          For ni := 1 to BiNabor2[t].NaborCount do
          begin
            For nei := 0 to InputCount-1 do
              TStr := TStr + GetStrNE(BiNabor2[t].Nabor[ni].Element[nei]);
            TStr := TStr + '('+IntToStr(t)+') + ';
          end;
        end;
        TStr := Copy(TStr, 1, Length(TStr)-3);
        LogUrMemo.Lines.Add(TStr);

        FillChar(BiNabor, SizeOf(BiNabor), 0); // ������ ���������� ��
        For ji := 0 to InputCount do           // BiNabor2 � BiNabor
        begin
          For ni := 1 to BiNabor2[ji].NaborCount do
          For nei := 0 to InputCount-1 do
            BiNabor[ji].Nabor[ni].Element[nei] :=
            BiNabor2[ji].Nabor[ni].Element[nei];

          BiNabor[ji].NaborCount := BiNabor2[ji].NaborCount;
        end;
        FillChar(BiNabor2, SizeOf(BiNabor2), 0);
      end;
    until Ok;

    Result := '���� : X = '; // ���� � ���� �������� ������������
    If Null then Result := Result + '0' else
    begin
      For ji := 0 to InputCount do
      begin
        For ni := 1 to BiNabor[ji].NaborCount do
        begin
          For nei := 0 to InputCount-1 do
          begin
            Result := Result + GetStrNE(BiNabor[ji].Nabor[ni].Element[nei]);
          end;
          Result := Result+' + ';
        end;
      end;
      Result := Copy(Result, 1, Length(Result)-3);
    end;
    LogUrMemo.Lines.Add(Result);

    Result := 'X = '; // ���� � ���� ��������� �������
    If Null then Result := Result + '0' else
    begin
      For ji := 0 to InputCount do
      begin
        For ni := 1 to BiNabor[ji].NaborCount do
        begin
          ne := 0;
          For nei := 0 to InputCount-1 do
          begin
            If BiNabor[ji].Nabor[ni].Element[nei]<>neNone then ne := nei;
          end;
          For nei := 0 to InputCount-1 do
          begin
            If BiNabor[ji].Nabor[ni].Element[nei]=neTrue then
            begin
              If nei<>ne then Result := Result + Chr(Ord('A')+nei)+'�' else
                Result := Result + Chr(Ord('A')+nei);
            end else
            If BiNabor[ji].Nabor[ni].Element[nei]=neFalse then
            begin
              If nei<>ne then Result := Result+'�'+Chr(Ord('A')+nei)+'�' else
                Result := Result+'�'+Chr(Ord('A')+nei);
            end
          end;
//          Result := Result + GetStrNE(BiNabor[ji].Nabor[ni].Element[nei]);
          Result := Result+' + ';
        end;
      end;

      Result := Copy(Result, 1, Length(Result)-3);
    end;
  end;
end;

// ������� ����������� ���� - ����������� ������������� ���������� �����
// ���������� �������
// ���������� �� ������� ���������� ���� ������� ����� ������ ����� ����
// ����������� �������� ���� ������� ����������, �� ������� ������� ����������
// ��� ��������
//    A    B    C    F(A, B, C)
//    0    0    1     1    <-
//    0    1    0     0         ���� = �A��B�C + A��B��C
//    0    1    1     0
//    1    0    0     1    <-

function GetSDNF(IOArr : TIOArr) : String;
var
  R, i : Integer;
  X : Boolean;
  Inputs : array[0..5] of Boolean;
  Null : Boolean;
begin
  Result := 'X = ';
  Null := True;

//  R := 0;

  With TTForm do
//  While R <= RowCount-1 do
  For R := 0 to RowCount-1 do
  begin
    For i := 0 to InputCount-1 do
      Inputs[i] := IOArr[i, R];

    X := IOArr[InputCount, R];

    If X then
    begin
      For i := 0 to InputCount-1 do
      begin
        If i<InputCount-1 then
        begin
          If Inputs[i] then
            Result := Result+Chr(Ord('A')+i)+'�' else
            Result := Result+'�'+Chr(Ord('A')+i)+'�';
        end else
        begin
          If Inputs[InputCount-1] then
            Result := Result+Chr(Ord('A')+InputCount-1) else
            Result := Result+'�'+Chr(Ord('A')+InputCount-1);
        end;
      end;

      Result := Result+' + ';

      Null := False;
    end;

//    Inc(R);
  end;

  If Null then Result := Result + '0' else
    Result := Copy(Result, 1, Length(Result)-3);
end;

// ������� ����������� ���� - ����������� ������������� ���������� �����
// ���������� �������
// ���������� �� ������� ���������� ���� ������� ����� ������ ����� ����
// ����������� ��������� ���� ������� ����������, �� ������� ������� ����������
// ��� ������
//    A    B    C    F(A, B, C)
//    0    0    1     1
//    0    1    0     0    <-     ���� = (A+�B+C)�(A+�B+�C)
//    0    1    1     0    <-
//    1    0    0     1

function GetSCNF(IOArr : TIOArr) : String;
var
  R, i : Integer;
  X : Boolean;
  Inputs : array[0..5] of Boolean;
  Null : Boolean;
begin
  Result := 'X = ';
  Null := True;

  R := 0;

  With TTForm do
  While R <= RowCount-1 do
  begin
    For i := 0 to InputCount-1 do
      Inputs[i] := IOArr[i, R];

    X := IOArr[InputCount, R];

    If not X then
    begin
      For i := 0 to InputCount-1 do
      begin
        If i=0 then
        begin
          If not Inputs[0] then
            Result := Result+'('+Chr(Ord('A'))+'+' else
            Result := Result+'(�'+Chr(Ord('A'))+'+';
        end else
        If i<InputCount-1 then
        begin
          If not Inputs[i] then
            Result := Result+Chr(Ord('A')+i)+'+' else
            Result := Result+'�'+Chr(Ord('A')+i)+'+';
        end else
        begin
          If not Inputs[InputCount-1] then
            Result := Result+Chr(Ord('A')+InputCount-1)+')' else
            Result := Result+'�'+Chr(Ord('A')+InputCount-1)+')';
        end;
      end;

      Result := Result+' � ';

      Null := False;
    end;

    Inc(R);
  end;

  If Null then Result := Result + '1' else
    Result := Copy(Result, 1, Length(Result)-3);
end;

end.
