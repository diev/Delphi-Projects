unit BICLSKey;

interface

function CalcLSKey(const BIC, LS: string): Char;
function CalcKSKey(const BIC, KS: string): Char;
function ValidLSKey(const BIC, LS: string): Boolean;
function ValidKSKey(const BIC, KS: string): Boolean;
function IsRKC(const BIC: string): Boolean;

implementation
uses
  SysUtils, StrUtils;

function InternalCalcLSKey(const BICLS: string): Char;
var
  B: array[1..23] of Byte;
  I: Integer;
  Sum: Integer;
begin
  for I := 1 to 23 do
    B[I] := Byte(BICLS[I]) - 48; //Asc('0')
  B[12] := 0; //default key = 0 for recalculation
  Sum := 0;
  for I := 1 to 23 do
  begin
    if (I mod 3) = 1 then
      Inc(Sum, B[I] * 7 mod 10)
    else if (I mod 3) = 2 then
      Inc(Sum, B[I] {* 1} mod 10)
    else {I mod 3 = 0}
      Inc(Sum, B[I] * 3 mod 10);
  end;
  Result := Char(Sum * 3 mod 10 + 48);
end;

function CalcLSKey(const BIC, LS: string): Char;
begin
  if IsRKC(BIC) then
    Result := InternalCalcLSKey('0' + Copy(BIC, 5, 2) + LS)
  else
    Result := InternalCalcLSKey(Copy(BIC, 7, 3) + LS);
end;

function CalcKSKey(const BIC, KS: string): Char;
begin
  if not IsRKC(BIC) then //inverted to LS
    Result := InternalCalcLSKey('0' + Copy(BIC, 5, 2) + KS)
  else
    Result := InternalCalcLSKey(Copy(BIC, 7, 3) + KS);
end;

function ValidLSKey(const BIC, LS: string): Boolean;
begin
  if IsRKC(BIC) then
    Result := (InternalCalcLSKey('0' + Copy(BIC, 5, 2) + LS) = LS[9])
  else
    Result := (InternalCalcLSKey(Copy(BIC, 7, 3) + LS) = LS[9]);
end;

function ValidKSKey(const BIC, KS: string): Boolean;
begin
  if not IsRKC(BIC) then
    Result := (InternalCalcLSKey('0' + Copy(BIC, 5, 2) + KS) = KS[9])
  else
    Result := (InternalCalcLSKey(Copy(BIC, 7, 3) + KS) = KS[9]);
end;

function IsRKC(const BIC: string): Boolean;
begin
  Result := StrToInt(AnsiRightStr(BIC, 3)) < 5;
end;

end.
