unit CheckUn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, LogEdit;

type
  TMainForm = class(TForm)
    LogUrIn: TLogEdit;
    LogUrOut: TLogEdit;
    CheckBtn: TBitBtn;
    Memo: TMemo;
    CreateBtn: TBitBtn;
    procedure CheckBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CreateBtnClick(Sender: TObject);
  private
  public
    { Public declarations }
  end;

  function CheckFunc(WorkStr : String) : String;

var
  MainForm: TMainForm;
  LOList : TList;

implementation

{$R *.dfm}

type
  TLogOp = (loNone, loOr, loAnd, loNot);
  PLogOper = ^TLogOper;
  TLogOper = record
    ParLOper : PLogOper;
    i1Str, i2Str : String[250];
    i1, i2 : PLogOper;
    lo : TLogOp;
    c1, c2 : String[1];
  end;

function CopyB(Str : String; divi : Integer) : String;
var
  i, uv : Integer;
  Ok : Boolean;
begin
  Result := ''; Ok := True; uv := 0;
  If (divi<1) or (divi>Length(Str)) then Exit;
  i := divi;
  While (i>0) and Ok do
  begin
    If Str[i]='(' then Inc(uv);
    If Str[i]=')' then Dec(uv);
    If uv>0 then Ok := False else
      Result := Str[i] + Result;
    Dec(i);
  end;

end;

function CopyE(Str : String; divi : Integer) : String;
var
  i, uv : Integer;
  Ok : Boolean;
begin
  Result := ''; Ok := True; uv := 0;
  If (divi<1) or (divi>Length(Str)) then Exit;
  i := divi;
  While (i<=Length(Str)) and Ok do
  begin
    If Str[i]='(' then Inc(uv);
    If Str[i]=')' then Dec(uv);
    If uv<0 then Ok := False else
      Result := Result + Str[i];
    Inc(i);
  end;
end;

function CheckFunc(WorkStr : String) : String;
  function GetVal(C : Char) : Integer;
  begin
    Case C of
      '+' : Result := 3;
      '•' : Result := 2;
      '¬' : Result := 1;
      else Result := 0;
    end;
  end;
var
  i, rp : Integer;
  StatStr : String;

  function Recurse(Str : String; ParNode : PLogOper; uv : Integer) : PLogOper;
  var
    i, suv, suvmin, uvo, uvc, maxval, maxvaln, val, divi : Integer;
    LOper : PLogOper;
  begin
    LOper := nil;
    suv := uv; suvmin := 0; uvc := 0; uvo := 0;
    maxval := 0; maxvaln := 0;
    For i := 1 to Length(Str) do
    begin
      If Str[i]='(' then Inc(suv);
      If Str[i]=')' then Dec(suv);
  //X = (A+¬B+C)•¬(C+D)•¬A // + -> • -> ¬
      Case Str[i] of
        '•', '¬', '+' :
          begin
            If (suvmin=0) or (suv < suvmin) then
            begin
              suvmin := suv;
              uvc := 1;
              uvo := i;

              maxval := GetVal(Str[i]);
              maxvaln := i;
            end else if suv=suvmin then
            begin
              Inc(uvc);
//              uvo := i;

              // + -> • -> ¬
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
    If maxvaln=0 then maxvaln := uvo;
    divi := maxvaln;
    If uvc<>0 then
    begin
      LOper := New(PLogOper);

      With LOper^ do
      begin
        ParLOper := ParNode;
        Case Str[divi] of
          '+' : lo := loOr;
          '•' : lo := loAnd;
          else  lo := loNot; // '¬'
        end;

        If lo <> loNot then i1Str := CopyB(Str, divi-1) else
          i1Str := '';
        i2Str := CopyE(Str, divi+1);


        If lo = loNot then StatStr := '' else
          StatStr := i1Str+'<'+Str[divi]+'>';
        StatStr := StatStr+i2Str;

        MainForm.Memo.Lines.Add(StatStr);

        If Length(i1Str)>1 then
        begin
          i1 := Recurse(i1Str, LOper, uv+1);
        end else
        begin
          i1 := nil;
          c1 := i1Str;
        end;
        If Length(i2Str)>1 then
        begin
          i2 := Recurse(i2Str, LOper, uv+1);
        end else
        begin
          i2 := nil;
          c2 := i2Str;
        end;
      end;
      LOList.Add(LOper);
    end;
    Result := LOper;
  end;
begin
  With MainForm do
  begin
    Result := '';
    i := 1;
    While i<=Length(WorkStr) do // Óäàëåíèå ëèøíèõ ïðîáåëîâ
    begin
      If WorkStr[i] = ' ' then Delete(WorkStr, i, 1) else Inc(i);
    end;

    rp := Pos(WorkStr, '=');
    If rp=0 then rp := 2;
    WorkStr := Copy(WorkStr, rp+1, Length(WorkStr)-rp+1);
//    MessageBox(MainForm.Handle, PChar(WorkStr), '', mb_OK);

    Recurse(WorkStr, nil, 1);
  end;
end;

procedure TMainForm.CheckBtnClick(Sender: TObject);
begin
  Memo.Lines.Clear;
  CheckFunc(LogUrIn.Text);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  LOList := TList.Create;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  PLOper : PLogOper;
begin
  While LOList.Count>0 do
  begin
    PLOper := LOList.Items[0];
    Dispose(PLOper);
    LOlist.Delete(0);
  end;
  LOList.Free;
end;

function GetLogUr(Node : PLogOper) : String;
begin
  Result := '';
  If Node^.i1 = nil then
    Result := '('+Node^.c1 else Result := '('+GetLogUr(Node^.i1);
  If Result <> '' then
  Case Node^.lo of
    loAnd : Result := Result + '•';
    loOr  : Result := Result + '+';
    else Result := Result + '¬';
  end;
  If Node^.i2 = nil then
    Result := Result+Node^.c2+')' else Result := Result+GetLogUr(Node^.i2)+')';
end;

procedure TMainForm.CreateBtnClick(Sender: TObject);
begin
  If LOList.Count > 0 then
    LogUrOut.Text := 'X = '+GetLogUr(PLogOper(LOList.Last));
end;

end.


