unit INNKey;

interface

function ValidINNKey(const INN: string): Boolean;

implementation

function ValidINNKey(const INN: string): Boolean;
var
  B: array[1..12] of Byte;
  I: Integer;
  Sum: Integer;
  S: string;
begin
  if (Length(INN) = 0) or (INN = '0') then
  begin
    Result := True;
    Exit;
  end;

  if INN[1] = 'F' then
  begin
    S := INN;
    Delete(S, 1, 1);
    Result := ValidINNKey(S);
    Exit;
  end;

  for I := 1 to Length(INN) do
    B[I] := Byte(INN[I]) - 48; //Asc('0')
  if Length(INN) = 10 then
  begin
    Sum := 0;
    Inc(Sum, B[1] * 2);
    Inc(Sum, B[2] * 4);
    Inc(Sum, B[3] * 10);
    Inc(Sum, B[4] * 3);
    Inc(Sum, B[5] * 5);
    Inc(Sum, B[6] * 9);
    Inc(Sum, B[7] * 4);
    Inc(Sum, B[8] * 6);
    Inc(Sum, B[9] * 8);
    Sum := Sum mod 11 mod 10;
    Result := B[10] = Sum;
  end
  else if Length(INN) = 12 then
  begin
    Sum := 0;
    Inc(Sum, B[1] * 7);
    Inc(Sum, B[2] * 2);
    Inc(Sum, B[3] * 4);
    Inc(Sum, B[4] * 10);
    Inc(Sum, B[5] * 3);
    Inc(Sum, B[6] * 5);
    Inc(Sum, B[7] * 9);
    Inc(Sum, B[8] * 4);
    Inc(Sum, B[9] * 6);
    Inc(Sum, B[10] * 8);
    Sum := Sum mod 11 mod 10;
    if B[11] <> Sum then
      Result := False
    else
    begin
      //B[11] := Sum;
      Sum := 0;
      Inc(Sum, B[1] * 3);
      Inc(Sum, B[2] * 7);
      Inc(Sum, B[3] * 2);
      Inc(Sum, B[4] * 4);
      Inc(Sum, B[5] * 10);
      Inc(Sum, B[6] * 3);
      Inc(Sum, B[7] * 5);
      Inc(Sum, B[8] * 9);
      Inc(Sum, B[9] * 4);
      Inc(Sum, B[10] * 6);
      Inc(Sum, B[11] * 8);
      Sum := Sum mod 11 mod 10;
      Result := B[12] = Sum;
    end;
  end
  else
    Result := False;
end;

end.
