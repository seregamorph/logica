unit MathComponent;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,math;

type
  TMathtype=(mtnil,mtoperator,mtlbracket,mtrbracket,mtoperand);

type
  TMathOperatortype=(monone,moadd,mosub,modiv,momul,mopow);

type
pmathchar = ^Tmathchar;
TMathChar = record 
  case mathtype: Tmathtype of 
   mtoperand:(data:extended); 
   mtoperator:(op:TMathOperatortype); 
end; 

type 
  TMathControl = class(TComponent) 
  private 
   input,output,stack:array of tmathchar; 
   fmathstring:string; 
   function getresult:extended; 
   function calculate(operand1,operand2,operator:Tmathchar):extended; 
   function getoperator(c:char):TMathOperatortype; 
   function getoperand(mid:integer;var len:integer):extended; 
   procedure processstring; 
   procedure convertinfixtopostfix; 
   function isdigit(c:char):boolean; 
   function isoperator(c:char):boolean; 
   function getprecedence(mop:TMathOperatortype):integer; 
  protected 
  published 
   property MathExpression:string read fmathstring write fmathstring;
   property MathResult:extended read getresult; 
  end; 

procedure Register; 

implementation

function Tmathcontrol.calculate(operand1,operand2,operator:Tmathchar):extended; 
begin 
result:=0; 
case operator.op of 
  moadd: 
   result:=operand1.data + operand2.data; 
  mosub: 
   result:=operand1.data - operand2.data; 
  momul: 
   result:=operand1.data * operand2.data; 
  modiv: 
   if (operand1.data<>0) and (operand2.data<>0) then 
    result:=operand1.data / operand2.data 
   else 
    result:=0; 
  mopow: result:=power(operand1.data,operand2.data);
end; 
end; 

function Tmathcontrol.getresult:extended; 
var 
i:integer;
tmp1,tmp2,tmp3:tmathchar; 
begin 
convertinfixtopostfix; 
setlength(stack,0); 
for i:=0 to length(output)-1 do 
  begin 
   if output[i].mathtype=mtoperand then 
    begin 
     setlength(stack,length(stack)+1); 
     stack[length(stack)-1]:=output[i]; 
    end 
   else if output[i].mathtype=mtoperator then 
    begin 
      tmp1:=stack[length(stack)-1]; 
      tmp2:=stack[length(stack)-2]; 
      setlength(stack,length(stack)-2); 
      tmp3.mathtype:=mtoperand;
      tmp3.data:=calculate(tmp2,tmp1,output[i]); 
      setlength(stack,length(stack)+1); 
      stack[length(stack)-1]:=tmp3; 
    end; 
  end; 
result:=stack[0].data;
setlength(stack,0); 
setlength(input,0); 
setlength(output,0); 
end; 

function Tmathcontrol.getoperator(c:char):TMathOperatortype; 
begin 
result:=monone; 
if c='+' then 
  result:=moadd 
else if c='*' then 
  result:=momul 
else if c='/' then 
  result:=modiv 
else if c='-' then 
  result:=mosub 
else if c='^' then
  result:=mopow; 
end; 

function Tmathcontrol.getoperand(mid:integer;var len:integer):extended; 
var 
i,j:integer;
tmpnum:string; 
begin 
j:=1; 
for i:=mid to length(fmathstring)-1 do 
  begin 
   if isdigit(fmathstring[i]) then 
    begin 
     if j<=20 then 
      tmpnum:=tmpnum+fmathstring[i]; 
     j:=j+1; 
    end 
   else 
    break; 
  end; 
result:=strtofloat(tmpnum); 
len:=length(tmpnum); 
end;

procedure Tmathcontrol.processstring; 
var 
i:integer; 
numlen:integer; 
begin
i:=0; 
numlen:=0; 
setlength(output,0); 
setlength(input,0); 
setlength(stack,0); 
fmathstring:='('+fmathstring+')'; 
setlength(input,length(fmathstring)); 
while i<=length(fmathstring)-1 do 
  begin 
   if fmathstring[i+1]='(' then 
    begin 
     input[i].mathtype:=mtlbracket; 
     i:=i+1; 
    end 
   else if fmathstring[i+1]=')' then 
    begin 
     input[i].mathtype:=mtrbracket;
     i:=i+1; 
    end 
   else if isoperator(fmathstring[i+1]) then 
    begin 
     input[i].mathtype:=mtoperator; 
     input[i].op:=getoperator(fmathstring[i+1]);
     i:=i+1; 
    end 
   else if isdigit(fmathstring[i+1]) then 
    begin 
     input[i].mathtype:=mtoperand; 
     input[i].data:=getoperand(i+1,numlen); 
     i:=i+numlen; 
    end; 
  end; 
end; 


function Tmathcontrol.isoperator(c:char):boolean; 
begin 
result:=false; 
if (c='+') or (c='-') or (c='*') or (c='/') or (c='^') then 
  result:=true;
end; 

function Tmathcontrol.isdigit(c:char):boolean; 
begin 
result:=false; 
if ((integer(c)> 47) and (integer(c)< 58)) or (c='.') then
  result:=true; 
end; 

function Tmathcontrol.getprecedence(mop:TMathOperatortype):integer; 
begin 
result:=-1; 
case mop of 
  moadd:result:=1; 
  mosub:result:=1; 
  momul:result:=2; 
  modiv:result:=2; 
  mopow:result:=3; 
end; 
end; 

procedure Tmathcontrol.convertinfixtopostfix; 
var
i,j,prec:integer; 
begin 
processstring; 
for i:=0 to length(input)-1 do 
  begin 
   if input[i].mathtype=mtoperand then
    begin 
     setlength(output,length(output)+1); 
     output[length(output)-1]:=input[i]; 
    end 
   else if input[i].mathtype=mtlbracket then 
    begin 
     setlength(stack,length(stack)+1); 
     stack[length(stack)-1]:=input[i]; 
    end 
   else if input[i].mathtype=mtoperator then 
    begin 
     prec:=getprecedence(input[i].op); 
     j:=length(stack)-1; 
     if j>=0 then 
      begin 
       while(getprecedence(stack[j].op)>=prec) and (j>=0) do 
        begin
         setlength(output,length(output)+1); 
         output[length(output)-1]:=stack[j]; 
         setlength(stack,length(stack)-1); 
         j:=j-1; 
        end; 
       setlength(stack,length(stack)+1);
       stack[length(stack)-1]:=input[i]; 
      end; 
    end 
   else if input[i].mathtype=mtrbracket then 
    begin 
     j:=length(stack)-1; 
     if j>=0 then 
      begin 
       while(stack[j].mathtype<>mtlbracket) and (j>=0) do 
        begin 
         setlength(output,length(output)+1); 
         output[length(output)-1]:=stack[j]; 
         setlength(stack,length(stack)-1); 
         j:=j-1; 
        end; 
       if j>=0 then 
        setlength(stack,length(stack)-1);
      end; 
    end; 
  end; 
end; 


procedure Register;
begin
  RegisterComponents('Samples', [TMathControl]);
end;

end.



end.
