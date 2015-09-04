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
    ('��� ', '������ ', '������ ',
     '��������� ', '������� ', '�������� ',
     '������� ', '��������� ', '��������� ');
  nXX: array[2..9] of string =
    ('�������� ', '�������� ',
     '����� ', '��������� ', '���������� ',
     '��������� ', '����������� ', '��������� ');
  nX: array[1..19] of string =
     ('���� ', '��� ', '��� ',
      '������ ', '���� ', '����� ',
      '���� ', '������ ', '������ ',
      '������ ', '����������� ', '���������� ',
      '���������� ', '������������ ', '���������� ',
      '����������� ', '���������� ', '������������ ',
      '������������ ');

function RCurrToText(v: Currency): string;
var
  n: Integer;
begin
  Result := '';
  if v >= 1000000000000 then
    Exit;

  n := Trunc(v / 1000000000);
  if n > 0 then
    Result := Result + R999ToStr(n) + '��������' + REndStr(n, ' ', '� ', '�� ');

  n := Trunc(v / 1000000) mod 1000;
  if n > 0 then
    Result := Result + R999ToStr(n) + '�������' + REndStr(n, ' ', '� ', '�� ');

  n := Trunc(v / 1000) mod 1000;
  if n > 0 then
    Result := Result + R999ToStr(n, False) + '�����' + REndStr(n, '� ', '� ', ' ');

  n := Trunc(v) mod 1000;
  if n > 0 then
    Result := Result + R999ToStr(n);

  if Length(Result) = 0 then
    Result := '���� ';

  Result := Result + '����' + REndStr(n, '� ', '� ', '�� ');

  n := Trunc(v * 100) mod 100;
  Result := Result + Format('%2.2d ', [n]) + '����' + REndStr(n, '���.', '���.', '��.');
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
    Result := Result + '���� '
  else if (n = 2) and b then
    Result := Result + '��� '
  else if n > 0 then
    Result := Result + nX[n];
end;

end.
