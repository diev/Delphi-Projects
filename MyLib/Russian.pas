unit Russian;

interface

function RNeedDosToWin(const S: string): Boolean;
function RWin(const S: string): string;
function RDos(const S: string): string;
procedure RDosToWin(var S: string);
procedure RWinToDos(var S: string);

function RUpper(const S: string): string;
function RLower(const S: string): string;
procedure RUpper1st(var S: string);

function RStrToCurr(const S: string): Currency;
function RStrToCurrStr(const S: string): string;
function RStrToInt(const S: string): Integer;
function RStrToDate(const S: string): TDateTime;
function RStrToDateStr(const S: string): string;

function RCurrToStr(const V: Currency; const Delim: string = '.'): string;
function RDateToStr(const D: TDateTime): string; overload;
function RDateToStr(const S: string): string; overload;
function RDateToS(const D: TDateTime): string; overload;
function RDateToS(const S: string): string; overload;

function REndStr(N: Integer; const S1, S2, S: string): string;

implementation

uses
  SysUtils;

function RNeedDosToWin(const S: string): Boolean;
var
  B: Byte;
  I, IWin, IDos: Integer;
begin
  IWin := 0;
  IDos := 0;
  for I := 1 to Length(S) do
  begin
    B := Byte(S[I]);
    if B > 127 then
      if B < 176 then //DOS А128..Яа..п175
        Inc(IDos)
      else if B > 191 then //WIN А192..Я223
        if (B < 224) or (B > 239) then //WIN р240..я255
          Inc(IWin);
      //common DOS р224..я239 & WIN а224..п239 ignored
  end;
  Result := IDos > IWin;
end;

function RWin(const S: string): string;
begin
  Result := S;
  RDosToWin(Result);
end;

function RDos(const S: string): string;
begin
  Result := S;
  RWinToDos(Result);
end;

procedure RDosToWin(var S: string);
var
  B: Byte;
  I: Integer;
begin
  for I := 1 to Length(S) do
  begin
    B := Byte(S[I]);
    if B > 127 then
      if B < 176 then //А128..Яа..п175
        Inc(S[I], 64)
      else if B > 223 then //р224..я239
      begin
        if B < 240 then
          Inc(S[I], 16)
        else if B = 240 then //Ё240
          S[I] := #168 //'Е'
        else if B = 241 then //ё241
          S[I] := #184 //'е'
      end
      else if B in [193, 194, 196] then
        S[I] := #45 //'-'
      else if B in [179, 180, 195, 197] then
        S[I] := #124 //'|'
      else if B in [191, 192, 217, 218] then
        S[I] := #43; //'+'
  end;
end;

procedure RWinToDos(var S: string);
var
  B: Byte;
  I: Integer;
begin
  for I := 1 to Length(S) do
  begin
    B := Byte(S[I]);
    if B > 127 then
      if B > 239 then //р240..я255
        Dec(S[I], 16)
      else if B > 191 then //А191..Яа..п239
        Dec(S[I], 64)
      else if B = 168 then //Ё240
        S[I] := #133 //Е133
      else if B = 184 then //ё241
        S[I] := #165 //ё165
      else if B = 185 then //No
        S[I] := #78 //N
      else if B in [150, 151] then
        S[I] := #45; //--
  end;
end;

function RUpper(const S: string): string;
var
  I: Integer;
begin
  Result := S;
  for I := 1 to Length(S) do
    if S[I] >= #224 then
      Dec(Result[I], 32);
end;

function RLower(const S: string): string;
var
  I: Integer;
begin
  Result := S;
  for I := 1 to Length(S) do
    if (S[I] >= #192) and (S[I] <= #223) then
      Inc(Result[I], 32);
end;

procedure RUpper1st(var S: string);
begin
  if S[1] >= #224 then
    Dec(S[1], 32);
end;

{Читает всю строку с цифрами и возвращает денежное значение,
независимо от наличия пробелов и букв в этой строке,
но дробная часть отделяется после *последней* точки,
запятой, знака равенства или минуса...}
function RStrToCurr(const S: string): Currency;
const
  ValidChars = '1234567890.,-=';
var
  I, C, N, P: Integer;
begin
  Result := 0;
  N := 0;
  P := 0;
  for I := 1 to Length(S) do
  begin
    C := Pos(S[I], ValidChars);
    if C > 10 then
      P := N
    else if C = 10 then begin
      Result := Result * 10;
      Inc(N);
    end
    else if C > 0 then begin
      Result := Result * 10 + C;
      Inc(N);
    end;
  end;
  if P > 0 then
    while N > P do
    begin
      Result := Result / 10;
      Dec(N);
    end;
  if S[1] = '-' then Result := -Result;
end;

function RStrToInt(const S: string): Integer;
const
  ValidChars = '1234567890';
var
  I, C: Integer;
begin
  Result := 0;
  if S = '' then
    Exit;
  for I := 1 to Length(S) do
  begin
    C := Pos(S[I], ValidChars);
    if C = 10 then
      Result := Result * 10
    else if C > 0 then
      Result := Result * 10 + C;
  end;
  if S[1] = '-' then Result := -Result;
end;

{Читает дату почти в любом возможном числовом написании}
function RStrToDate(const S: string): TDateTime;
const
  ValidChars = '1234567890./-';
var
  I, P, C: Integer;
  SS: array[0..2] of string;
  DD, MM, YY: Word;
begin
  P := 0;
  SS[0] := '';
  SS[1] := '';
  SS[2] := '';
  for I := 1 to Length(S) do
  begin
    C := Pos(S[I], ValidChars);
    if C > 10 then
      Inc(P)
    else if C > 0 then
      SS[P] := SS[P] + S[I];
  end;

  DecodeDate(Date, YY, MM, DD); //this year by default
  if Length(SS[0]) = 8 then //YYYYMMDD
  begin
    I := StrToInt(SS[0]);
    DD := I mod 100;
    MM := I div 100 mod 100;
    YY := I div 10000;
  end
  else if Length(SS[0]) = 4 then begin //YYYY-MM-DD
    DD := StrToInt(SS[2]);
    MM := StrToInt(SS[1]);
    YY := StrToInt(SS[0]);
  end
  else if Length(SS[2]) > 0 then begin //DD.MM.[[YY]YY]
    DD := StrToInt(SS[0]);
    MM := StrToInt(SS[1]);
    if Length(SS[2]) = 4 then
      YY := StrToInt(SS[2])
    else if Length(SS[2]) = 2 then
    begin
      I := StrToInt(SS[2]);
      YY := YY div 100 * 100 + I;
      if I < TwoDigitYearCenturyWindow then
        Dec(YY, 100);
    end;
  end;
  Result := EncodeDate(YY, MM, DD);
end;

function RStrToDateStr(const S: string): string;
begin
  Result := DateToStr(RStrToDate(S));
end;

function RStrToCurrStr(const S: string): string;
begin
  Result := Format('%.2n', [RStrToCurr(S)]);
end;

function RCurrToStr(const V: Currency; const Delim: string = '.'): string;
begin
  Result := Format('%.2f', [V]);
  Result[Length(Result)-2] := Delim[1];
end;

function RDateToStr(const D: TDateTime): string;
begin
  Result := FormatDateTime('dd.mm.yyyy', D);
end;

function RDateToStr(const S: string): string;
begin
  Result := FormatDateTime('dd.mm.yyyy', RStrToDate(S));
end;

function RDateToS(const D: TDateTime): string;
begin
  Result := FormatDateTime('yyyymmdd', D);
end;

function RDateToS(const S: string): string;
begin
  Result := FormatDateTime('yyyymmdd', RStrToDate(S));
end;

function REndStr(N: Integer; const S1, S2, S: string): string;
begin
  if N > 100 then
    N := N mod 100;
  if N > 19 then
    N := N mod 10;
  case N of
    1:    Result := S1;
    2..4: Result := S2;
  else
    Result := S;
  end;
end;

end.
