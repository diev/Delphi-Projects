unit SumFuncs;

interface
uses SysUtils;

function RCurrToText(v: Currency): string;
function R999ToStr(n: Integer; b: Boolean = True): string;

implementation

uses
  Russian;

const
  nXXX: array[1..9] of string =
    ('сто ', 'двести ', 'триста ',
     'четыреста ', 'пятьсот ', 'шестьсот ',
     'семьсот ', 'восемьсот ', 'девятьсот ');
  nXX: array[2..9] of string =
    ('двадцать ', 'тридцать ',
     'сорок ', 'пятьдесят ', 'шестьдесят ',
     'семьдесят ', 'восемьдесят ', 'девяносто ');
  nX: array[1..19] of string =
     ('одна ', 'две ', 'три ',
      'четыре ', 'пять ', 'шесть ',
      'семь ', 'восемь ', 'девять ',
      'десять ', 'одиннадцать ', 'двенадцать ',
      'тринадцать ', 'четырнадцать ', 'пятнадцать ',
      'шестнадцать ', 'семнадцать ', 'восемнадцать ',
      'девятнадцать ');

function RCurrToText(v: Currency): string;
var
  n: Integer;
begin
  Result := '';
  if v >= 1000000000000 then
    Exit;

  n := Trunc(v / 1000000000);
  if n > 0 then
    Result := Result + R999ToStr(n) + 'миллиард' + REndStr(n, ' ', 'а ', 'ов ');

  n := Trunc(v / 1000000) mod 1000;
  if n > 0 then
    Result := Result + R999ToStr(n) + 'миллион' + REndStr(n, ' ', 'а ', 'ов ');

  n := Trunc(v / 1000) mod 1000;
  if n > 0 then
    Result := Result + R999ToStr(n, False) + 'тысяч' + REndStr(n, 'а ', 'и ', ' ');

  n := Trunc(v) mod 1000;
  if n > 0 then
    Result := Result + R999ToStr(n);

  if Length(Result) = 0 then
    Result := 'ноль ';

  Result := Result + 'рубл' + REndStr(n, 'ь ', 'я ', 'ей ');

  n := Trunc(v * 100) mod 100;
  Result := Result + Format('%2.2d ', [n]) + 'копе' + REndStr(n, 'йка.', 'йки.', 'ек.');
  RUpper1st(Result);
end;

function R999ToStr(n: Integer; b: Boolean = True): string;
begin
  if n > 99 then
  begin
    Result := nXXX[n div 100];
    n := n mod 100;
  end
  else
    Result := '';

  if n > 19 then
  begin
    Result := Result + nXX[n div 10];
    n := n mod 10;
  end;

  if (n = 1) and b then
    Result := Result + 'один '
  else if (n = 2) and b then
    Result := Result + 'два '
  else if n > 0 then
    Result := Result + nX[n];
end;

end.
