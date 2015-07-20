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
    Element : array[0..MaxInputCount-1] of TNaborElement; // набор
    Cut : Boolean;
  end;
  TJarus = record
    NaborCount : Integer; // число наборов
    Nabor : array[1..100*MaxInputCount] of  TNabor;
  end;
  TBiNabor = array[0..MaxInputCount] of TJarus; // Двоичный набор ярусов
                                    // Индекс массива - число единиц

function GetSDNF(IOArr : TIOArr) : String;
function GetSCNF(IOArr : TIOArr) : String;
function GetMDNF(IOArr : TIOArr) : String;

implementation

uses TTUn, MainUn;

// Функция получения МДНФ - минимальной дизъюнктивной нормальной формы
// логической функции по методу Квайна - МакКласски
// Метод состоит из четырех шагов :
// 1) Представим наборы, на которых функция истинна, в виде двоичных
//  эквивалентов -> в BiNabor
// 2) Упорядочим двоичные эквиваленты по ярусам и проведем склейку наборов в
//  соседних ярусах, получая максимальные интервалы до тех пор, пока это
//  возможно; помечаем каждый набор, участвовавший в склейке. Склеиваются
//  только те наборы или интервалы, различие в которых заключается в значении
//  одного разряда : 001    001-     -01-
//                   000    101-     -11-
// 3) Поглощение повторяющихся наборов
// 4) Составление функции в виде бинарного набора
// 5) Составление функции в текстовом виде

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
    // Номер яруса и наборов 1-го и 2-го яруса
  ne : Integer;  // Конец набора (для вывода)
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
    For R := 0 to RowCount-1 do // Подготовка бинарного набора
    begin
      If IOArr[InputCount, R] then // Функция истинна
      begin
        Null := False;
        TC := 0; // Обнуление счетчика истин
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
//      For ji := 0 to InputCount-1 do // Число ярусов = InputCount+1
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
            If cdn=1 then // Если одно различие -> склеивание
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
        For ji := 0 to InputCount do // Добавление не склеенных наборов
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

        For dji := 0 to InputCount do // Поглощение повторяющихся наборов
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
                // Удаляем от ni2 до конца
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

        TStr := 'X = '; // Составление промежуточного результата, записываемого
                        // в LogUrMemo
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

        FillChar(BiNabor, SizeOf(BiNabor), 0); // Запись информации из
        For ji := 0 to InputCount do           // BiNabor2 в BiNabor
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

    Result := 'МДНФ : X = '; // МДНФ в виде двоичных эквивалентов
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

    Result := 'X = '; // МДНФ в виде текстовой функции
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
              If nei<>ne then Result := Result + Chr(Ord('A')+nei)+'•' else
                Result := Result + Chr(Ord('A')+nei);
            end else
            If BiNabor[ji].Nabor[ni].Element[nei]=neFalse then
            begin
              If nei<>ne then Result := Result+'¬'+Chr(Ord('A')+nei)+'•' else
                Result := Result+'¬'+Chr(Ord('A')+nei);
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

// Функция составления СДНФ - совершенной дизъюнктивной нормальной формы
// логической функции
// Получается из таблицы истинности этой функции путем записи через знак
// логического сложения всех наборов переменных, на которых функция определена
// как истинная
//    A    B    C    F(A, B, C)
//    0    0    1     1    <-
//    0    1    0     0         СДНФ = ¬A•¬B•C + A•¬B•¬C
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
            Result := Result+Chr(Ord('A')+i)+'•' else
            Result := Result+'¬'+Chr(Ord('A')+i)+'•';
        end else
        begin
          If Inputs[InputCount-1] then
            Result := Result+Chr(Ord('A')+InputCount-1) else
            Result := Result+'¬'+Chr(Ord('A')+InputCount-1);
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

// Функция составления СКНФ - совершенной конъюнктивной нормальной формы
// логической функции
// Получается из таблицы истинности этой функции путем записи через знак
// логического умножения всех наборов переменных, на которых функция определена
// как ложная
//    A    B    C    F(A, B, C)
//    0    0    1     1
//    0    1    0     0    <-     СКНФ = (A+¬B+C)•(A+¬B+¬C)
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
            Result := Result+'(¬'+Chr(Ord('A'))+'+';
        end else
        If i<InputCount-1 then
        begin
          If not Inputs[i] then
            Result := Result+Chr(Ord('A')+i)+'+' else
            Result := Result+'¬'+Chr(Ord('A')+i)+'+';
        end else
        begin
          If not Inputs[InputCount-1] then
            Result := Result+Chr(Ord('A')+InputCount-1)+')' else
            Result := Result+'¬'+Chr(Ord('A')+InputCount-1)+')';
        end;
      end;

      Result := Result+' • ';

      Null := False;
    end;

    Inc(R);
  end;

  If Null then Result := Result + '1' else
    Result := Copy(Result, 1, Length(Result)-3);
end;

end.
